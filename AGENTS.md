# Dotfiles Knowledge Base

**Generated:** 2026-01-08
**Context:** NixOS + Home Manager Configuration

## Overview

NixOS/home-manager dotfiles managing multi-machine configurations (desktop, laptops, Raspberry Pi, USB boot).
Uses **Nix Flakes** for declarative system/user separation and **Agenix** for secret management.

## Development Workflow

### Build & Deploy

| Command             | Description                                            |
| ------------------- | ------------------------------------------------------ |
| `make all`          | Full rebuild (NixOS system + Home Manager user)        |
| `make os`           | Rebuild NixOS system only (requires sudo)              |
| `make home-manager` | Rebuild Home Manager user config only                  |
| `make xx`           | Build target system (defined by `TARGET` env var)      |
| `make sd-burn`      | Build and burn Raspberry Pi image (requires `spi.img`) |

### Maintenance

| Command       | Description                                             |
| ------------- | ------------------------------------------------------- |
| `make update` | Update `flake.lock` inputs                              |
| `make up`     | Update flake inputs AND app hashes (`homes/apps/*.nix`) |
| `make clean`  | Garbage collect old generations & optimize store        |
| `make zi`     | Update Zinit plugins (Zsh)                              |

### Verification (Lint & Test)

There is no single "test" command. Verification is done via linting and successful builds.

- **Lint All Files**: `pre-commit run --all-files`
- **Lint Checks**:
  - `trailing-whitespace`: Trim trailing whitespace
  - `end-of-file-fixer`: Ensure single newline at EOF
  - `check-yaml`: Validate YAML syntax
  - `check-json`: Validate JSON syntax
  - `commitizen`: Ensure conventional commit messages
- **Node2Nix**: If modifying `homes/modules/node2nix/package.json`, run `make` in that directory to regenerate Nix expressions.

## Code Style & Conventions

### Nix Language

- **Indent**: 2 spaces (no tabs).
- **Naming**: `camelCase` for variables and attributes.
- **Inputs**: Use `inputs@{ ... }` pattern in modules.
- **Paths**: ALWAYS use relative paths. Avoid absolute paths.
- **Modularity**:
  - Use `lib.mkDefault` for overridable values.
  - Use `lib.mkIf` for conditional logic (e.g., host-specific configs).
  - Split configs into `base.nix` (shared), `gui.nix` (desktop), `dev.nix` (development).

### Secrets

- **Tool**: Agenix (`secrets/` directory).
- **Rule**: NEVER commit plaintext secrets. Ensure `.age` files are encrypted.

### Git & Commits

- **Format**: Conventional Commits (`feat:`, `fix:`, `chore:`, `refactor:`).
- **Enforcement**: Checked by `pre-commit` hook (Commitizen).

## Project Structure

```
.dotfiles/
├── flake.nix         # Entry point: inputs, outputs, system definitions
├── homes/            # User configurations (Home Manager)
│   ├── modules/      # Shared user modules (base, gui, dev, wsl)
│   ├── apps/         # App-specific configs (often with pinned hashes)
│   └── <host>/       # Per-machine user overrides
├── hosts/            # System configurations (NixOS)
│   ├── <host>/       # Per-machine system config (hardware, networking)
│   └── modules/      # Shared system modules
├── k8s/              # Kubernetes manifests & Terraform
├── vim/nvim/         # Neovim config (LazyVim based)
├── x/                # Window Managers (Hyprland, Waybar, Niri, i3)
├── secrets/          # Encrypted secrets
└── Makefile          # Task runner
```

## Where to Find Things

| Task                | Location                                               |
| ------------------- | ------------------------------------------------------ |
| **Add System Pkg**  | `hosts/<host>/default.nix` or `hosts/modules/base.nix` |
| **Add User Pkg**    | `homes/modules/base.nix` or `homes/modules/gui.nix`    |
| **Hyprland Config** | `x/hyprland/`                                          |
| **Neovim Plugins**  | `vim/nvim/lua/plugins/`                                |
| **Shell Aliases**   | `zsh/alias.zsh`                                        |
| **App Versions**    | `homes/apps/*.nix` (managed by `make up`)              |
