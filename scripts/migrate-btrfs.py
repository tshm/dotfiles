#!/usr/bin/env python3
"""Offline, encrypted ext4-to-Btrfs migration; never formats without confirmation."""
import argparse
from contextlib import ExitStack
import fcntl
import getpass
import hashlib
import json
import os
from pathlib import Path
import re
import secrets
import subprocess
import sys
import uuid


BASE = Path("/run/btrfs-migration")
SOURCE = BASE / "source"
TARGET = Path("/mnt")
SHARE = BASE / "share"
VERIFY = BASE / "verify"


def run(*args, capture=False, env=None):
    return subprocess.run(
        [str(arg) for arg in args], check=True, text=True,
        stdout=subprocess.PIPE if capture else None, env=env,
    ).stdout


def digest(path):
    with Path(path).open("rb") as stream:
        return hashlib.file_digest(stream, "sha256").hexdigest()


def load_config(path):
    config = json.loads(Path(path).read_text())
    for key in ("disk", "serial", "source_uuid", "server", "share", "username",
                "domain", "repository", "system", "hardware_file",
                "hardware_sha256", "hardware_replacement"):
        if not isinstance(config.get(key), str) or not config[key]:
            raise ValueError(f"Missing configuration: {key}")
        if any(char in config[key] for char in "\n\r\0"):
            raise ValueError(f"Invalid configuration: {key}")
    if not config["disk"].startswith("/dev/disk/by-id/"):
        raise ValueError("disk must use a stable /dev/disk/by-id/ identifier")
    for key in ("disk_size", "source_size"):
        if type(config.get(key)) is not int or config[key] <= 0:
            raise ValueError(f"Invalid size: {key}")
    if not re.fullmatch(r"[A-Za-z0-9][A-Za-z0-9_.-]*", config["repository"]):
        raise ValueError("repository must be a single directory name")
    relative = Path(config["hardware_file"])
    if relative.is_absolute() or ".." in relative.parts:
        raise ValueError("hardware_file must be relative to the source root")
    if not config["share"].startswith("//"):
        raise ValueError("share must be an SMB UNC path")
    if not re.fullmatch(r"[0-9a-f]{64}", config["hardware_sha256"]):
        raise ValueError("Invalid hardware configuration digest")
    system = Path(config["system"])
    if not str(system).startswith("/nix/store/") or not (system / "bin/switch-to-configuration").is_file():
        raise ValueError("The prebuilt NixOS system is missing from the USB")
    if not Path(config["hardware_replacement"]).is_file():
        raise ValueError("The replacement hardware configuration is missing")
    return config


def disk_partition(config, *, resume=False, expected_uuid=None):
    disks = json.loads(run(
        "lsblk", "--json", "--bytes", "--paths", "--output",
        "NAME,TYPE,SIZE,SERIAL,TRAN,RM,LABEL,PTTYPE,MOUNTPOINTS", capture=True,
    ))["blockdevices"]
    disk = next((item for item in disks
                 if Path(item["name"]).resolve() == Path(config["disk"]).resolve()), None)
    if disk is None or disk["type"] != "disk":
        raise ValueError("Configured target disk is absent")
    if (disk["serial"] != config["serial"] or disk["size"] != config["disk_size"]
            or disk["tran"] == "usb" or disk["rm"]):
        raise ValueError("Disk identity mismatch, removable disk, or USB target refused")
    if disk["pttype"] != "dos":
        raise ValueError("Expected the existing BIOS/MBR disk layout; will not repartition")
    partitions = disk.get("children", [])
    if len(partitions) != 1 or partitions[0]["type"] != "part":
        raise ValueError("Expected exactly one existing root partition; will not repartition")
    partition = partitions[0]
    def check_labels(items):
        for item in items:
            if item.get("label") == "nixos-root" and item["name"] != partition["name"]:
                raise ValueError("Another filesystem already has the target label nixos-root")
            check_labels(item.get("children", []))
    check_labels(disks)
    if partition.get("children"):
        raise ValueError("Layered block devices are not supported")
    if any(point for item in (disk, partition) for point in item.get("mountpoints", []) if point):
        raise ValueError("Target is mounted: boot the dedicated USB before running migration")
    filesystem = json.loads(run(
        "blkid", "--probe", "--output", "json", partition["name"], capture=True,
    ))["blkid"][0]
    expected_type = "btrfs" if resume else "ext4"
    expected_uuid = expected_uuid if resume else config["source_uuid"]
    if (partition["size"] != config["source_size"] or filesystem.get("type") != expected_type
            or filesystem.get("uuid") != expected_uuid
            or (resume and filesystem.get("label") != "nixos-root")):
        raise ValueError(
            f"Root partition mismatch: observed {partition['size']} bytes, {filesystem}; "
            f"expected {config['source_size']} bytes, {expected_type}, UUID {expected_uuid}"
        )
    return partition["name"]


def mount(stack, device, destination, options, kind=None):
    destination.mkdir(parents=True, exist_ok=True)
    if subprocess.run(["mountpoint", "--quiet", str(destination)]).returncode == 0:
        raise ValueError(f"Already mounted: {destination}; inspect and unmount before retrying")
    if kind == "cifs":
        run("mount.cifs", device, destination, "-o", options)
    else:
        args = ["mount", "-o", options]
        if kind:
            args += ["-t", kind]
        run(*args, device, destination)
    stack.callback(run, "umount", destination)


def write_state(path, state):
    temporary = path.with_name(".state-" + secrets.token_hex(8))
    with temporary.open("x") as stream:
        json.dump(state, stream, indent=2)
        stream.write("\n")
        stream.flush()
        os.fsync(stream.fileno())
    temporary.replace(path)


def password_file(stack, name, password):
    path = BASE / name
    with open(path, "w", opener=lambda file, flags: os.open(file, flags, 0o600)) as stream:
        stream.write(password)
    stack.callback(path.unlink, missing_ok=True)
    return path


def restic_base(repository, password):
    return ["restic", "--repo", str(repository), "--password-file", str(password), "--no-cache"]


def backup(command):
    snapshot = None
    with subprocess.Popen(command + ["backup", "--json", "--one-file-system", str(SOURCE)],
                          stdout=subprocess.PIPE, text=True) as process:
        for line in process.stdout:
            message = json.loads(line)
            if message.get("message_type") == "summary":
                snapshot = message.get("snapshot_id")
                print(f"Backup summary: {line.strip()}", flush=True)
            elif message.get("message_type") == "status":
                print(f"Backed up {message.get('bytes_done', 0)} bytes; "
                      f"{message.get('files_done', 0)} files", flush=True)
        if process.wait() != 0:
            raise RuntimeError("Backup was incomplete; the SSD has not been formatted")
    if not snapshot or not re.fullmatch(r"[0-9a-f]{64}", snapshot):
        raise RuntimeError("No complete snapshot ID returned by restic")
    return snapshot


def verify_backup(command, snapshot, config):
    if not re.fullmatch(r"[0-9a-f]{64}", snapshot):
        raise ValueError("Invalid saved snapshot identifier")
    print("Reading and checking every encrypted backup pack before any SSD changes.", flush=True)
    run(*command, "check", "--read-data")
    VERIFY.mkdir(exist_ok=True)
    if any(VERIFY.iterdir()):
        raise ValueError(f"Sample restore directory is not empty: {VERIFY}")
    run(*command, "restore", f"{snapshot}:{SOURCE}", "--target", VERIFY,
        "--include", "/" + config["hardware_file"], "--verify")
    sample = VERIFY / config["hardware_file"]
    if not sample.is_file() or digest(sample) != config["hardware_sha256"]:
        raise ValueError("Sample restore does not match the original hardware configuration")
    # Only the small, explicitly selected sample is ever restored into RAM.
    import shutil
    shutil.rmtree(VERIFY)


def install(command, snapshot, partition, config, state, state_path):
    with ExitStack() as target_stack:
        mount(target_stack, partition, TARGET, "compress=zstd:3", "btrfs")
        run(*command, "restore", f"{snapshot}:{SOURCE}", "--target", TARGET,
            "--verify", "--sparse")
        hardware = TARGET / config["hardware_file"]
        original = digest(hardware)
        replacement = Path(config["hardware_replacement"])
        if original not in (config["hardware_sha256"], digest(replacement)):
            raise ValueError("Restored hardware configuration differs from the prepared migration")
        with hardware.open("wb") as stream:
            stream.write(replacement.read_bytes())
            stream.flush()
            os.fsync(stream.fileno())
        run("nixos-install", "--root", TARGET, "--system", config["system"],
            "--no-root-password", "--no-channel-copy")
        run("sync", "-f", TARGET)
        run("btrfs", "filesystem", "usage", TARGET)
    state["phase"] = "complete"
    write_state(state_path, state)
    print("COMPLETE: SSD restored and bootloader installed. Keep the server backup.\n"
          "Remove the USB and reboot manually. Do not run the migration again.", flush=True)


def migrate(config, resume):
    # Check before requesting credentials, mounting SMB, or changing any disk.
    if not resume:
        partition = disk_partition(config)
    elif not Path(config["disk"]).exists():
        raise ValueError("Configured target disk is absent")
    with ExitStack() as stack:
        credentials = password_file(stack, "smb-credentials", "username=" + config["username"]
                                    + "\ndomain=" + config["domain"] + "\npassword="
                                    + getpass.getpass("SMB password: ") + "\n")
        # A credentials file cannot represent embedded newlines in a password.
        if len(credentials.read_text().splitlines()) != 3:
            raise ValueError("SMB credentials contain unsupported newline characters")
        mount(stack, config["share"], SHARE,
              f"credentials={credentials},vers=3.1.1,seal,ip={config['server']},nosuid,nodev,noexec",
              "cifs")
        bundle = SHARE / config["repository"]
        if resume and not bundle.is_dir():
            raise ValueError("No saved migration exists; refusing resume")
        bundle.mkdir(exist_ok=True)
        state_path = bundle / "state.json"
        repository = bundle / "repo"
        password = getpass.getpass("Backup password: ")
        if not password or any(char in password for char in "\n\r\0"):
            raise ValueError("A nonempty, single-line backup password is required")
        new_repository = not (repository / "config").exists()
        if new_repository and resume:
            raise ValueError("No backup repository exists; refusing resume")
        if new_repository and password != getpass.getpass("Repeat backup password: "):
            raise ValueError("Backup passwords do not match")
        secret = password_file(stack, "restic-password", password + "\n")
        command = restic_base(repository, secret)
        fingerprint = hashlib.sha256(json.dumps(config, sort_keys=True).encode()).hexdigest()
        if resume:
            state = json.loads(state_path.read_text())
            if state["fingerprint"] != fingerprint or state["phase"] not in ("formatting", "restoring"):
                raise ValueError("Saved migration is incompatible or already complete")
            partition = disk_partition(config, resume=True, expected_uuid=state["btrfs_uuid"])
            if input(f"Resume restoring ONLY {config['serial']}? Type RESTORE {config['serial']}: ") != f"RESTORE {config['serial']}":
                raise ValueError("Resume not confirmed; no SSD changes made")
            verify_backup(command, state["snapshot"], config)
            install(command, state["snapshot"], partition, config, state, state_path)
            return
        if state_path.exists() and json.loads(state_path.read_text()).get("phase") == "complete":
            raise ValueError("This migration already completed; refusing another erase")
        run("e2fsck", "-f", "-n", partition)
        with ExitStack() as source_stack:
            mount(source_stack, partition, SOURCE, "ro,noload", "ext4")
            original = SOURCE / config["hardware_file"]
            if not original.is_file() or original.is_symlink() or digest(original) != config["hardware_sha256"]:
                raise ValueError("Hardware configuration changed since USB preparation; rebuild the USB")
            probe = bundle / (".write-test-" + secrets.token_hex(8))
            data = secrets.token_bytes(4096)
            try:
                with probe.open("xb") as stream:
                    stream.write(data)
                    stream.flush()
                    os.fsync(stream.fileno())
                if probe.read_bytes() != data:
                    raise ValueError("File server write/read verification failed")
            finally:
                probe.unlink(missing_ok=True)
            usage = os.statvfs(SOURCE)
            required = (usage.f_blocks - usage.f_bfree) * usage.f_frsize * 11 // 10
            available = os.statvfs(SHARE)
            if available.f_bavail * available.f_frsize < required:
                raise ValueError("File server needs at least 110% of the SSD's used bytes free")
            if new_repository:
                run(*command, "init", "--repository-version", "2")
            snapshot = backup(command)
            verify_backup(command, snapshot, config)
            state = {"fingerprint": fingerprint, "snapshot": snapshot,
                     "btrfs_uuid": str(uuid.uuid4()), "phase": "verified"}
            write_state(state_path, state)
            print(f"Verified encrypted backup: {bundle}\n"
                  f"Target disk: {config['disk']}\nSerial: {config['serial']}\n"
                  f"Partition: {partition}\n"
                  "WARNING: its ext4 filesystem will now be destroyed. "
                  "Keep the backup password outside this computer.", flush=True)
            if input("Type ERASE " + config["serial"] + ": ") != "ERASE " + config["serial"]:
                raise ValueError("Erase not confirmed; SSD is unchanged and backup remains available")
        # Recheck identity and mount state after the source mount is gone.
        partition = disk_partition(config)
        state["phase"] = "formatting"
        write_state(state_path, state)
        run("wipefs", "--all", partition)
        run("mkfs.btrfs", "--force", "--label", "nixos-root", "--uuid", state["btrfs_uuid"], partition)
        run("udevadm", "trigger", "--action=change", "--name-match=" + partition)
        run("udevadm", "settle")
        partition = disk_partition(config, resume=True, expected_uuid=state["btrfs_uuid"])
        state["phase"] = "restoring"
        write_state(state_path, state)
        install(command, snapshot, partition, config, state, state_path)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--config", default="/etc/btrfs-migration.json")
    parser.add_argument("--resume", action="store_true", help="restore saved snapshot without formatting again")
    args = parser.parse_args()
    if os.geteuid() != 0:
        parser.error("Run as root from the dedicated USB")
    os.umask(0o077)
    BASE.mkdir(mode=0o700, exist_ok=True)
    # Disallow a second console starting another migration concurrently.
    with (BASE / "lock").open("w") as lock:
        fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
        for key in list(os.environ):
            if key.startswith("RESTIC_"):
                del os.environ[key]
        try:
            migrate(load_config(args.config), args.resume)
        except (OSError, ValueError, KeyError, RuntimeError, EOFError, subprocess.CalledProcessError) as error:
            print(f"STOPPED: {error}\nNo automatic retry, reformat, or reboot. "
                  "Keep the server backup and inspect the failure before proceeding.", file=sys.stderr)
            return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
