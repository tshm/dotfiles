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
