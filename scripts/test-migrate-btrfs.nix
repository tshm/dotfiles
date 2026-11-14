{ pkgs ? import <nixpkgs> { } }:

let
  consoleTest = pkgs.writeText "migration-console-test.py" ''
    import atexit
    import io
    import sys
    import pexpect

    resuming = "--resume" in sys.argv[3:]
    child = pexpect.spawn(
        sys.executable, ["/etc/migrate-btrfs.py", "--config", sys.argv[1], *sys.argv[3:]],
        encoding="utf8", timeout=120,
    )
    transcript = io.StringIO()
    child.logfile_read = transcript
    def show_transcript():
        for line in transcript.getvalue().splitlines():
            print(repr(line), flush=True)
    atexit.register(show_transcript)
    for prompt, answer in [
        ("SMB password: ", "migration-pass"),
        ("Backup password: ", "restic-pass"),
    ]:
        child.expect_exact(prompt)
        child.sendline(answer)
    if not resuming:
        child.expect_exact("Repeat backup password: ")
        child.sendline("restic-pass")
    action = "RESTORE" if resuming else "ERASE"
    child.expect_exact(f"Type {action} migration-test-disk: ")
    child.sendline(sys.argv[2])
    child.expect(pexpect.EOF, timeout=600)
    child.close()
    sys.exit(child.exitstatus if child.exitstatus is not None else 1)
  '';
  targetSystem = (import "${pkgs.path}/nixos" {
    configuration = { lib, ... }: {
      boot.loader.grub.enable = true;
      boot.loader.grub.device = "/dev/vdb";
      boot.loader.grub.extraConfig = ''
        serial --unit=0 --speed=115200
        terminal_input serial
        terminal_output serial
      '';
      boot.initrd.availableKernelModules = [ "virtio_pci" "virtio_blk" "ahci" ];
      boot.kernelParams = [ "console=ttyS0,115200" ];
      fileSystems."/" = {
        device = "/dev/disk/by-label/nixos-root";
        fsType = "btrfs";
        options = [ "compress=zstd:3" ];
      };
      networking.useDHCP = lib.mkDefault true;
      system.stateVersion = "25.05";
      systemd.services.migration-boot-proof = {
        wantedBy = [ "multi-user.target" ];
        path = [ pkgs.util-linux ];
        script = ''
          test "$(findmnt -no FSTYPE /)" = btrfs
          test "$(cat /home/test/original)" = fixture-content
          echo MIGRATED_ROOT_BOOT_OK > /dev/ttyS0
          systemctl --no-block poweroff
        '';
        serviceConfig.Type = "oneshot";
      };
    };
  }).config.system.build.toplevel;
  hardwareReplacement = pkgs.writeText "migration-hardware-configuration.nix" ''
    # VM fixture replacement; the migration test checks this exact file.
    { config, lib, pkgs, modulesPath, ... }:
    {
      imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];
      boot.initrd.availableKernelModules = [ "virtio_blk" ];
      fileSystems."/" = { device = "/dev/disk/by-label/nixos-root"; fsType = "btrfs"; options = [ "compress=zstd:3" ]; };
      boot.loader.grub.device = "/dev/vdb";
      swapDevices = [ ];
      networking.useDHCP = lib.mkDefault true;
      nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
    }
  '';
in
pkgs.testers.nixosTest {
  name = "migrate-btrfs";

  nodes = {
    smb = { config, pkgs, ... }: {
      networking.firewall.allowedTCPPorts = [ 445 ];
      networking.interfaces.eth1.ipv4.addresses = [ { address = "192.168.100.2"; prefixLength = 24; } ];
      services.samba = {
        enable = true;
        settings = {
          global = {
            security = "user";
            "map to guest" = "never";
            "server min protocol" = "SMB2";
          };
          migration = {
            path = "/srv/migration";
            browseable = "yes";
            writable = "yes";
            "valid users" = "migration";
          };
        };
      };
      users.users.migration = { isSystemUser = true; group = "migration"; };
      users.groups.migration = { };
      systemd.tmpfiles.rules = [ "d /srv/migration 0770 migration migration -" ];
      environment.systemPackages = [ pkgs.samba ];
    };

    client = { config, pkgs, ... }: {
      networking.firewall.enable = false;
      networking.interfaces.eth1.ipv4.addresses = [ { address = "192.168.100.1"; prefixLength = 24; } ];
      environment.systemPackages = with pkgs; [
        btrfs-progs cifs-utils e2fsprogs jq restic util-linux attr nixos-install-tools compsize
        (python3.withPackages (ps: [ ps.pexpect ]))
      ];
      environment.etc."migrate-btrfs.py".source = ./migrate-btrfs.py;
      environment.etc."migration-console-test.py".source = consoleTest;
      virtualisation.additionalPaths = [ targetSystem ];
      boot.loader.grub.enable = true;
      boot.loader.grub.device = "/dev/vdb";
      virtualisation.emptyDiskImages = [ {
        size = 8192;
        driveConfig.deviceExtraOpts.serial = "migration-test-disk";
      } ];
      boot.kernelModules = [ "btrfs" ];
      # The migration target is the disposable second disk, never the VM root disk.
      virtualisation.qemu.options = [ "-device virtio-rng-pci" ];
    };
  };

  testScript = ''
    import json
    import shlex
    import subprocess
    from datetime import timedelta

    start_all()
    smb.wait_for_unit("samba-smbd.service")
    smb.succeed("printf 'migration-pass\nmigration-pass\n' | smbpasswd -a -s migration")
    client.wait_for_unit("multi-user.target")
    client.wait_until_succeeds("ping -c1 192.168.100.2")

    # Build the source exactly as a removable disk: one MBR Linux partition.
    client.succeed("""
      set -eu
      disk=/dev/vdb
      printf 'label: dos\n\nstart=2048, type=83\n' | sfdisk --wipe always "$disk"
      udevadm settle
      mkfs.ext4 -F "''${disk}1"
      mkdir -p /run/migration-fixture
      mount "''${disk}1" /run/migration-fixture
      mkdir -p /run/migration-fixture/etc /run/migration-fixture/home/test /run/migration-fixture/var/lib/state
      printf 'fixture-os\n' > /run/migration-fixture/etc/os-release
      printf 'fixture-content\n' > /run/migration-fixture/home/test/original
      python3 -c 'from pathlib import Path; Path("/run/migration-fixture/home/test/compressible").write_bytes(b"compressible-text" * 65536)'
      ln /run/migration-fixture/home/test/original /run/migration-fixture/home/test/hardlink
      ln -s original /run/migration-fixture/home/test/symlink
      setfattr -n user.migration -v preserved /run/migration-fixture/home/test/original
      printf 'state\n' > /run/migration-fixture/var/lib/state/value
      printf 'hardware-fixture\n' > /run/migration-fixture/etc/hardware-configuration.nix
      chown -R 1000:100 /run/migration-fixture/home /run/migration-fixture/var
      chmod 0640 /run/migration-fixture/home/test/original
      sha256sum /run/migration-fixture/etc/hardware-configuration.nix > /run/hardware.sha256
      sync
      umount /run/migration-fixture
    """)

    migration_config = {
      "disk": "/dev/disk/by-id/virtio-migration-test-disk",
      "serial": "migration-test-disk",
      "disk_size": int(client.succeed("blockdev --getsize64 /dev/vdb").strip()),
      "source_uuid": client.succeed("blkid -s UUID -o value /dev/vdb1").strip(),
      "source_size": int(client.succeed("blockdev --getsize64 /dev/vdb1").strip()),
      "server": "192.168.100.2",
      "share": "//192.168.100.2/migration",
      "username": "migration",
      "domain": "WORKGROUP",
      "repository": "repo",
      "system": "${targetSystem}",
      "hardware_file": "etc/hardware-configuration.nix",
      "hardware_sha256": client.succeed("cut -d' ' -f1 /run/hardware.sha256").strip(),
      "hardware_replacement": "${hardwareReplacement}",
    }
    client.succeed("printf %s " + shlex.quote(json.dumps(migration_config)) + " > /run/migration.json")

    # Mounted-source safety check: refusing the offline operation must leave
    # the ext4 partition and its content untouched.
    client.succeed("mount /dev/vdb1 /run/migration-fixture")
    client.fail("python3 /etc/migrate-btrfs.py --config /run/migration.json")
    client.succeed("test -f /run/migration-fixture/home/test/original && findmnt -no FSTYPE /dev/vdb1 | grep -qx ext4")
    client.succeed("umount /run/migration-fixture")
    client.succeed("jq '.repository = \"wrong-confirmation\"' /run/migration.json > /run/migration-wrong.json")
    client.fail("python3 /etc/migration-console-test.py /run/migration-wrong.json 'ERASE WRONG'", timeout=timedelta(seconds=300))
    client.succeed("blkid -s TYPE -o value /dev/vdb1 | grep -qx ext4")
    smb.succeed("test -f /srv/migration/wrong-confirmation/state.json")

    # Real SMB/restic/password/mkfs/mount/restore path.  Passwords are test
    # values only; the repository is created in the disposable Samba share.
    status, transcript = client.execute("python3 /etc/migration-console-test.py /run/migration.json 'ERASE migration-test-disk'", timeout=timedelta(seconds=660))
    if status != 0:
        print(transcript)
        raise AssertionError("Migration did not complete")

    client.succeed("""
      set -eu
      mkdir -p /run/verify
      mount -t btrfs -o subvol=/ /dev/vdb1 /run/verify
      test "$(findmnt -no FSTYPE /run/verify)" = btrfs
      test "$(cat /run/verify/home/test/original)" = fixture-content
      test "$(stat -c %a /run/verify/home/test/original)" = 640
      test "$(stat -c %u:%g /run/verify/home/test/original)" = 1000:100
      test "$(stat -c %i /run/verify/home/test/original)" = "$(stat -c %i /run/verify/home/test/hardlink)"
      test "$(readlink /run/verify/home/test/symlink)" = original
      test "$(getfattr --only-values -n user.migration /run/verify/home/test/original)" = preserved
      test "$(cat /run/verify/var/lib/state/value)" = state
      test -d /run/verify/boot/grub
    """)
    compression = client.succeed("compsize --bytes /run/verify/home/test/compressible")
    zstd = next(line.split() for line in compression.splitlines() if line.startswith("zstd"))
    assert int(zstd[2]) < int(zstd[3]), compression
    # Model an interruption after restore: recovery must repair data without
    # formatting again or losing files outside the snapshot.
    filesystem_uuid = client.succeed("blkid -s UUID -o value /dev/vdb1").strip()
    client.succeed("printf damaged > /run/verify/home/test/original; touch /run/verify/resume-survivor; umount /run/verify")
    state = json.loads(smb.succeed("cat /srv/migration/repo/state.json"))
    state["phase"] = "restoring"
    smb.succeed("printf %s " + shlex.quote(json.dumps(state)) + " > /srv/migration/repo/state.json")
    client.succeed("python3 /etc/migration-console-test.py /run/migration.json 'RESTORE migration-test-disk' --resume", timeout=timedelta(seconds=660))
    assert client.succeed("blkid -s UUID -o value /dev/vdb1").strip() == filesystem_uuid
    client.succeed("mount /dev/vdb1 /run/verify; test -f /run/verify/resume-survivor; test $(cat /run/verify/home/test/original) = fixture-content; umount /run/verify")

    # Boot the restored disk through BIOS/GRUB in a fresh, accelerated VM.
    client.shutdown()
    result = subprocess.run([
        "${pkgs.qemu_kvm}/bin/qemu-system-x86_64",
        "-accel", "kvm", "-m", "1024", "-display", "none", "-monitor", "none",
        "-serial", "stdio", "-no-reboot", "-nic", "none",
        "-drive", f"file={client.state_dir}/empty0.qcow2,format=qcow2,if=virtio,snapshot=on",
    ], capture_output=True, text=True, timeout=180)
    (client.out_dir / "migrated-boot.log").write_text(result.stdout + result.stderr)
    assert result.returncode == 0 and "MIGRATED_ROOT_BOOT_OK" in result.stdout, result.stdout + result.stderr
  '';
}
