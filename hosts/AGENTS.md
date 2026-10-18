# NixOS Host Configurations

System-level configurations for each machine. Defines hardware, services, boot, networking.

## Structure

```
hosts/
├── default.nix       # Entry: defines all nixosConfigurations
├── base.nix          # Shared base (boot, networking, users)
├── gui.nix           # Shared desktop (Hyprland, audio, fonts)
└── {minf,spi,...}/   # Per-host hardware + overrides
    ├── default.nix
    └── hardware-configuration.nix
```

## Where to Look

| Task | Location |
|------|----------|
| System package | `base.nix` or host-specific |
| Desktop/Wayland | `gui.nix` |
| Hardware config | `<host>/hardware-configuration.nix` |
| Boot options | `base.nix` (shared) or host-specific |

## Host Types

| Host | Arch | Type | Notes |
|------|------|------|-------|
| minf | x86 | Desktop | Full GUI |
| x360 | x86 | Laptop | HP convertible |
| tp | x86 | Server | ThinkPad headless |
| spi | aarch64 | RPi | Raspberry Pi, cross-compiled; production `spi` advertises a Tailscale exit node, while `spi_first` builds the initial SD image |
| usb | x86 | Portable | Bootable USB |

## Conventions

- **forServer**: `base.nix` accepts `{ host, forServer ? false }` for server mode
- **Hardware modules**: Use `nixos-hardware` flake for device-specific fixes
- **Cross-compilation**: aarch64 builds use `crossPkgs` from flake

## Key Patterns

- `lib.mkIf (!forServer)`: Skip GUI services on servers
- `specialArgs`: Pass flake inputs to modules
- `imports`: Hardware config + shared modules

## minf Fingerprint Reader

- `minf/fingerprint.nix` installs the experimental FT9201 (`2808:93a9`) driver, pinned to Deetss PR #1 commit `da599b389f41827617df8c1836926eff580f3733` on libfprint 1.94.10.
- `minf/ft9201-identify.patch` adds multi-finger identification using the existing vendor verifier, re-feeding the captured frame for each enrolled template without changing the matching threshold. Existing enrollments are compatible.
- `minf/test-ft9201-identify.c` runs in the library's install-check phase against the patched driver with a substitute vendor matcher: covers either gallery entry, no match, consumed probes, frame rejection and malformed/empty templates. It does not measure biometric accuracy.
- Firmware and the Windows matcher DLL are proprietary, hash-pinned build inputs; do not publish the resulting packages to public binary caches without redistribution permission.
- The matcher runs inside fprintd, not a sandbox. Keep the daemon's upstream hardening enabled.
- Fingerprint authentication is only for local `login` (inherited by greetd), with password fallback. All other PAM services, including sudo, Polkit, screen lockers and SSH, default off. Preserve passwordless sudo from `base.nix`; do not require fingerprints for privilege escalation.
- Build: `nix build .#nixosConfigurations.minf.config.system.build.toplevel`. Driver/library and daemon retain their upstream install checks.
- `fprintd-verify` without `-f` must request any finger. Check each enrolled finger and a non-enrolled finger. After activating configuration changes, `sudo -k -n id -u` must print `0` without a fingerprint/password prompt; only `/etc/pam.d/login` should contain `pam_fprintd.so`. These checks do not establish false-accept rates.
- Enroll interactively with `fprintd-enroll -f right-index-finger`; verify with `fprintd-verify -f right-index-finger`. Fingerprint data lives in `/var/lib/fprint`; remove enrollment with `fprintd-delete "$USER"`.
- Fingerprint login cannot supply the password needed to unlock an encrypted GNOME keyring; unlock it separately when required.

## x360 Fingerprint Reader

- `x360/default.nix` packages the experimental `synatlsmoc` driver for the built-in Synaptics `06cb:00c9` reader. The driver is pinned to hardware-tested commit `28d391839b9d9f71e2952528894d730c28d3ec4b`; fprintd's persistent-pairing patch is pinned to `b700a346e735e429f757828bffe7fbbdaf9f9415`.
- Authentication is enabled only for local `login` (inherited by greetd), with password fallback. Do not enable it for sudo, Polkit, screen lockers, or SSH without an explicit request.
- Enroll with `sudo fprintd-enroll -f right-index-finger tshm`; verify with `fprintd-verify -f right-index-finger tshm`. Pairing and enrollment data are stored below root-only `/var/lib/fprint`.
- Build with `nix build .#nixosConfigurations.x360.config.system.build.toplevel`. Verify the actual path with `nix shell nixpkgs#pamtester -c pamtester login tshm authenticate`.

## Child DOX Index

No child DOX files.
