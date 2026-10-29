# Home-Manager Configurations

User-level configurations for each machine. Defines packages, programs, and settings per-user.

## Structure

```
homes/
├── default.nix       # Entry: maps hosts to configs
├── modules/          # Shared modules (base, gui, dev, wsl)
├── apps/             # App-specific configs with version hashes
└── {minf,x360,...}/  # Per-host user overrides
```

## Where to Look

| Task | Location |
|------|----------|
| Add user package | `modules/base.nix` (all) or host-specific |
| GUI application | `modules/gui.nix` |
| Dev tools | `modules/dev.nix` |
| WSL-specific | `modules/wsl.nix` |
| App with pinned hash | `apps/*.nix` |

## Module Hierarchy

```
base.nix (shell, git, core tools)
    └── gui.nix (desktop apps, Wayland, themes)
        └── dev.nix (languages, editors, LSP)
```

Import order matters - later modules can override earlier.

## Conventions

- **Host config**: Import shared modules + add host-specific packages
- **Conditional**: Use `lib.mkIf` for optional features
- **XDG**: Prefer `xdg.configFile` for config symlinks
- **App hashes**: Updated via `make apphash_update`

## Key Patterns

- `extraSpecialArgs`: Pass flake inputs to modules
- `home.packages`: User-level packages
- `programs.<name>.enable`: Declarative program config
- `xdg.configHome`: XDG base directory integration
- WSL yazi: `modules/wsl.nix` sends Office/PDF-style GUI files to Windows via `cmd.exe /C start`
- Desktop yazi: `modules/gui.nix` opens MKV/MP4 directly with mpv, bypassing XDG MIME associations.
- Desktop Fcitx5: `modules/gui.nix` manages `fcitx5/config` and `fcitx5/profile` through `xdg.configFile`; edit these declarations rather than the generated files. Packages and service remain in `hosts/gui.nix`.
- spi Hermes backend: `spi/default.nix` runs `hermes serve` on the runtime-resolved Tailscale IPv4 address and couples its lifecycle to `hermes-gateway.service`
- Topgrade: `modules/base.nix` relies on built-in OpenCode and Hermes Agent steps; custom commands cover only `omp update` and `devbox global update`.

## Child DOX Index

No child DOX files.
