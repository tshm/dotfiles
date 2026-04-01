# Repository Guidelines

## Project Overview

This repository is a Nix Flake-based dotfiles monorepo for managing multiple NixOS machines, Home Manager user environments, Kubernetes infrastructure, editor/runtime configs, and local AI-agent tooling.

The root outputs are:
- `nixosConfigurations` from `hosts/`
- `homeConfigurations` from `homes/`

Use `flake.nix` and `Makefile` as the authoritative entry points. `README.md` is a quick orientation doc, but the flake and module files define real behavior.

## Repository Map

Start here before editing:
- `codemap.md` — repository-wide directory map
- `homes/AGENTS.md` — Home Manager conventions
- `hosts/AGENTS.md` — NixOS host conventions
- `k8s/AGENTS.md` — Kubernetes/Terraform/GitOps rules
- `vim/nvim/AGENTS.md` — Neovim/LazyVim rules

## Architecture & Data Flow

1. `flake.nix` declares inputs, cache settings, and `crossPkgs` for ARM builds.
2. `flake.nix` exports:
   - `nixosConfigurations = import ./hosts flakeInputs`
   - `homeConfigurations = import ./homes flakeInputs`
3. `hosts/default.nix` assembles per-machine NixOS systems from shared modules plus host-specific overrides and hardware configs.
4. `homes/default.nix` assembles per-machine Home Manager profiles keyed like `tshm@x360`.
5. Shared module layers carry most behavior:
   - `homes/modules/base.nix` → core CLI, secrets, symlinked dotfiles
   - `homes/modules/gui.nix` → desktop apps, Wayland, GUI config
   - `homes/modules/dev.nix` → development tools
   - `hosts/base.nix` → boot, networking, users, services, secrets
   - `hosts/gui.nix` → desktop/audio/fonts/input stack
6. `k8s/` is a separate GitOps + Terraform subsystem.
7. `agent/` is a separate OpenCode / Oh My Pi setup area with symlink-heavy local automation.

## Key Directories

| Path | Purpose |
| --- | --- |
| `homes/` | Home Manager entrypoint, shared modules, and per-host user overrides |
| `hosts/` | NixOS entrypoint, shared modules, hardware configs, and per-host system overrides |
| `homes/apps/` | App package definitions with pinned download hashes |
| `k8s/` | Kubernetes manifests, Flux/GitOps bootstrap, Terraform, devbox toolchain |
| `vim/nvim/` | LazyVim-based Neovim config |
| `x/` | Hyprland/Waybar and desktop session helpers |
| `agent/` | OpenCode/OMP bootstrap scripts, modular JSONC config, local extensions |
| `secrets/` | Agenix-managed encrypted secrets |

## Important Files

- `flake.nix` — root composition and flake inputs
- `Makefile` — preferred operator interface for rebuild/update workflows
- `homes/default.nix` — Home Manager output assembly
- `hosts/default.nix` — NixOS output assembly
- `.pre-commit-config.yaml` — repo-wide lint/commit hooks
- `.github/workflows/cachix.yaml` — build validation for selected home and host targets
- `k8s/devbox.json` — pinned toolchain for Kubernetes work
- `agent/Makefile` — local agent tooling bootstrap and config merge entrypoint

## Development Commands

Prefer `make` targets over ad hoc commands.

### Root workflows

```bash
make home-manager   # apply Home Manager config
make os             # apply NixOS config
make all            # on NixOS: home-manager + os
make update         # nix flake update
make up             # update flake inputs + app hashes
make clean          # GC + optimize store
```

### Build validation

Use the same shapes as CI when validating non-trivial changes:

```bash
pre-commit run --all-files
nix run home-manager/master -- build --flake .#tshm@minf
nix build '.#nixosConfigurations.x360.config.system.build.toplevel'
```

Adjust the target to the host/home you changed.

### App hash maintenance

```bash
make update.<app-name>   # updates sha256 in homes/apps/<app-name>.nix
make apphash_update
```

### Kubernetes workflow

```bash
cd k8s
devbox shell
make check
```

`k8s/` is devbox-first. Use the tool versions from `k8s/devbox.json`.

## Code Conventions & Common Patterns

### Nix module structure

- Prefer composition through `imports = [ ... ]`; most files are composition modules, not option-schema modules.
- Keep the file's argument capture style (`@inputs`, `@args`) intact. These modules rely on flake wiring through `specialArgs` / `extraSpecialArgs`.
- Use `platformSystem = pkgs.stdenv.hostPlatform.system` when indexing flake-provided packages.
- Put user packages in `home.packages`; put system packages in `environment.systemPackages`.

### Dotfile symlinks

Shared Home Manager modules use this pattern for repo-backed config:

```nix
configPath = pathStr: config.lib.file.mkOutOfStoreSymlink "/home/${user}/.dotfiles${pathStr}";
```

Reuse that pattern instead of inventing new symlink logic.

### Conditionals and overrides

- Use `lib.mkIf`, `lib.mkDefault`, and `lib.optionals` for host/role/hardware gating.
- `hosts/base.nix` uses `forServer` and `host == "spi"` style guards extensively.
- Import order matters in `homes/`: later modules/host files override earlier shared modules.

### Secrets and sensitive data

- Secrets are managed with Agenix (`agenix` input, `secrets/`, `age.secrets.*`).
- Do not commit plaintext secrets.
- Reference generated secrets through `config.age.secrets.<name>.path` when wiring services.
- For `k8s/`, follow the two-phase model from `k8s/AGENTS.md`: create secrets/config first, then reconcile Flux-managed manifests.

### Desktop and service config

- Desktop config is split between Home Manager (`homes/modules/gui.nix`, `x/`, `vim/nvim/`) and NixOS (`hosts/gui.nix`).
- System services and activation work are usually defined inline in Nix modules; extend the closest existing module instead of adding detached shell glue.

## Runtime & Tooling Preferences

- Nix Flakes are the source of truth.
- Prefer `make` wrappers; they already account for `nh`, `cachix`, and host-specific behavior.
- If a subdirectory has `devbox.json`, use devbox there. This is mandatory in practice for `k8s/`.
- The repo uses:
  - `pre-commit` for lint/validation hooks
  - `commitizen` for commit message enforcement
  - `git-cliff` for changelog generation
  - `Renovate` for dependency updates
- `agent/` automation is symlink-first and writes into `~/.config/opencode` and `~/.omp/agent`; warn before running targets that overwrite user-local config.

## Testing & QA

There is no conventional unit/integration test suite at the repo root.

Current QA posture is:
- `pre-commit run --all-files` for static checks
- Nix build validation for affected Home Manager / NixOS targets
- GitHub Actions in `.github/workflows/cachix.yaml` build selected homes and hosts
- `k8s/Makefile` + `kubeconform` validation for Kubernetes manifests

Do not claim "tests passed" unless you ran a real build or validation command. For most changes here, the right verification is a targeted Nix build, not a generic test runner.

## Subsystem Notes

### `homes/` and `hosts/`
- Read the local `AGENTS.md` before editing.
- Shared modules carry most defaults; per-host files should stay thin unless the change is truly machine-specific.

### `k8s/`
- Read `k8s/AGENTS.md` first.
- Use `devbox shell`.
- Respect the two-phase deployment split:
  1. manual secret/config bootstrap
  2. GitOps reconciliation via Flux

### `vim/nvim/`
- Read `vim/nvim/AGENTS.md` first.
- This is a LazyVim-style config: plugin specs live in `lua/plugins/`, core settings in `lua/config/`.

### `agent/`
- `agent/Makefile` bootstraps OpenCode and Oh My Pi tooling.
- `agent/merge-config.sh` and `make merge-config` merge modular JSONC into a single OpenCode config.
- These commands create symlinks into home-directory config locations; treat them as user-environment mutations, not harmless local builds.
