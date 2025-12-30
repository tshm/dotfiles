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
| spi | aarch64 | RPi | Raspberry Pi, cross-compiled |
| usb | x86 | Portable | Bootable USB |

## Conventions

- **forServer**: `base.nix` accepts `{ host, forServer ? false }` for server mode
- **Hardware modules**: Use `nixos-hardware` flake for device-specific fixes
- **Cross-compilation**: aarch64 builds use `crossPkgs` from flake

## Key Patterns

- `lib.mkIf (!forServer)`: Skip GUI services on servers
- `specialArgs`: Pass flake inputs to modules
- `imports`: Hardware config + shared modules
