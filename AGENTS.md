# Dotfiles Knowledge Base

**Generated:** 2025-12-30
**Commit:** b4e3acd
**Branch:** master

## Overview

NixOS/home-manager dotfiles managing multi-machine configurations (desktop, laptops, Raspberry Pi, USB boot). Nix flakes + home-manager for declarative system/user separation.

## Structure

```
.dotfiles/
├── flake.nix         # Entry point - inputs/outputs
├── homes/            # Home-manager user configs (per-machine)
├── hosts/            # NixOS system configs (per-machine)
├── k8s/              # Kubernetes manifests + Terraform
├── vim/nvim/         # Neovim (LazyVim-based)
├── zsh/              # Zsh shell config + zinit plugins
├── x/                # Wayland/X11 (Hyprland, Waybar, Niri, i3)
├── wezterm/          # Terminal emulator config
├── kanata/           # Keyboard remapping
├── secrets/          # Agenix-encrypted secrets
└── Makefile          # Build/deploy targets
```

## Where to Look

| Task | Location | Notes |
|------|----------|-------|
| Add system package | `hosts/base.nix` or `hosts/gui.nix` | Use `environment.systemPackages` |
| Add user package | `homes/modules/base.nix` or `gui.nix` | Use `home.packages` |
| New machine config | `hosts/<name>/` + `homes/<name>/` | Import in `default.nix` |
| Hyprland keybinds | `x/hyprland/general.conf` | |
| Neovim plugins | `vim/nvim/lua/plugins/` | LazyVim format |
| Shell aliases | `zsh/alias.zsh` | |
| Secrets | `secrets/` | Encrypted with agenix |

## Commands

```bash
make all              # Full rebuild (NixOS + home-manager)
make home-manager     # User config only
make os               # System config only (NixOS)
make update           # Update flake.lock + app hashes
make clean            # GC + optimize nix store
pre-commit run --all  # Lint/format checks
```

## Conventions

- **Nix style**: 2-space indent, camelCase vars, `inputs@{ ... }` pattern
- **Commits**: Conventional commits (`feat:`, `fix:`, `refactor:`)
- **Module hierarchy**: `base.nix` → `gui.nix` → `dev.nix` (progressive enhancement)
- **Host configs**: Import shared modules + hardware-specific overrides
- **Secrets**: Never commit plaintext; use agenix

## Anti-Patterns

- **Hardcoded paths**: Use `lib.mkDefault`, relative paths
- **Host-specific in shared**: Use `lib.mkIf` for conditional logic
- **Skipping pre-commit**: Always run before commit
- **Direct package versions**: Let flake.lock manage versions

## Unique Patterns

- **Cross-compilation**: ARM (aarch64-linux) images built on x86 via `crossPkgs`
- **Cachix integration**: `make` targets use `cachix watch-exec` when available
- **nh tool**: Faster switching via `nh` if installed (falls back to `nix run`)
- **App hash updates**: `make up` auto-updates app hashes in `homes/apps/*.nix`

## Module Dependencies

```
flake.nix
├── hosts/default.nix ──> hosts/{minf,x360,spi,...}/default.nix
│                         └── imports: base.nix, gui.nix, hardware
└── homes/default.nix ──> homes/{minf,x360,spi,...}/default.nix
                          └── imports: modules/{base,gui,dev,wsl}.nix
```

## Notes

- **FIXME**: hyprexpo plugin incompatibility in `homes/modules/gui.nix`
- **tmp dirs**: `k8s/tmp/` is gitignored, may contain build artifacts
- **WSL support**: `homes/modules/wsl.nix` for Windows Subsystem for Linux
- **Multiple WMs**: Hyprland (primary), Niri, i3 configs coexist in `x/`
