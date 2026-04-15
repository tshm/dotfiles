# Repository Guidelines

## Project Overview

This repo is a Nix Flake-based dotfiles monorepo. The primary outputs are NixOS system configs from `hosts/` and Home Manager configs from `homes/`, with separate operational areas for Kubernetes (`k8s/`), Neovim (`vim/nvim/`), and local OpenCode/Oh My Pi tooling (`agent/`).

Treat `flake.nix` and `Makefile` as the authoritative entry points. `README.md` is orientation; the flake, module files, and Makefiles define actual behavior.

## Architecture & Data Flow

1. `flake.nix` declares upstream inputs, cache settings, and `crossPkgs` for `aarch64-linux`, then passes `flakeInputs` into `./hosts` and `./homes`.
2. `hosts/default.nix` builds `nixosConfigurations` with `nixpkgs.lib.nixosSystem`, layering per-host modules on top of shared modules such as `hosts/base.nix` and `hosts/gui.nix`.
3. `homes/default.nix` builds `homeConfigurations` for `user@host` pairs with `home-manager.lib.homeManagerConfiguration`, forwarding `extraSpecialArgs` like `user` and the flake inputs.
4. Shared base modules carry most behavior:
   - `homes/modules/base.nix` sets common CLI/dev tooling, Agenix, and repo-backed symlinks into `~/.config`.
   - `hosts/base.nix` sets shared system services, networking, secrets, users, and host/role conditionals.
5. Later imports override earlier ones. In practice, shared modules establish defaults and per-host files stay thin unless the change is genuinely machine-specific.
6. `k8s/` and `agent/` are separate subsystems with their own tooling and process rules; do not treat them like ordinary root Nix edits.

## Read Before Editing

Read the local guide before touching these areas:

- `homes/AGENTS.md`
- `hosts/AGENTS.md`
- `k8s/AGENTS.md`
- `vim/nvim/AGENTS.md`

Also read `agent/BASE_AGENTS.md` before changing agent-specific automation or assistant configuration.

## Key Directories

| Path | Purpose |
| --- | --- |
| `homes/` | Home Manager entrypoints, shared modules, and per-machine user configs |
| `hosts/` | NixOS entrypoints, shared modules, hardware configs, and host overrides |
| `homes/apps/` | App package definitions with URL/hash maintenance targets |
| `k8s/` | Kubernetes manifests, bootstrap scripts, Flux/GitOps workflow, devbox toolchain |
| `agent/` | OpenCode / Oh My Pi bootstrap, JSONC config merge, local extension wiring |
| `vim/nvim/` | LazyVim-based Neovim config |
| `x/` | Desktop session, Wayland, and UI config consumed by Home Manager |
| `zsh/` | Shell config consumed by Home Manager symlinks/includes |
| `secrets/` | Agenix-encrypted secrets only; never plaintext |

## Important Files

- `flake.nix` — root composition, inputs, cache/substituter settings, cross-arch wiring
- `Makefile` — preferred operator interface for apply/update/build workflows
- `homes/default.nix` — Home Manager output assembly
- `hosts/default.nix` — NixOS output assembly
- `homes/modules/base.nix` — shared user packages, symlink strategy, common program defaults
- `hosts/base.nix` — shared system services, secrets, user setup, host role conditionals
- `.pre-commit-config.yaml` — repo-wide hooks
- `.github/workflows/cachix.yaml` — CI build matrix for selected Home Manager and NixOS targets
- `k8s/devbox.json` — pinned Kubernetes toolchain
- `agent/Makefile` and `agent/merge-config.sh` — local OpenCode install/config merge flow

## Development Commands

Prefer `make` targets over ad hoc Nix commands.

### State-changing commands

```bash
make home-manager   # apply Home Manager config
make os             # apply NixOS config
make all            # on NixOS: home-manager + os
make update         # nix flake update
make up             # flake update + app hash refresh
make dev            # enter agent/ and run its bootstrap makefile
```

`Makefile` is environment-aware: it prefers `nh` when available, wraps commands in `cachix watch-exec` when `cachix` is installed, and falls back to raw `nix`/`nixos-rebuild` otherwise.

### Validation commands

```bash
pre-commit run --all-files
nix run home-manager/master -- build --flake .#tshm@minf
nix build '.#nixosConfigurations.x360.config.system.build.toplevel'
cd k8s && devbox shell && make check
```

Adjust the Home Manager or NixOS target to the host you changed.

### Maintenance commands

```bash
make apphash_update          # refresh hashes in homes/apps/*.nix
make update.<app-name>       # refresh one app hash
```

### Environment bootstrapping

- `.envrc` exports `NH_FLAKE=$(realpath .)` and runs `make .git/hooks/pre-commit` on direnv load.
- The root repo assumes Nix is present or installable via the `nix` Make target.
- `k8s/` is devbox-first. Use the versions pinned in `k8s/devbox.json`.

## Code Conventions & Common Patterns

### Nix module patterns

- Prefer composition via `imports = [ ... ]`; most files are composition modules, not standalone schemas.
- Preserve the existing argument capture style (`@args`, `@inputs`) and the `specialArgs` / `extraSpecialArgs` plumbing. Many modules depend on those values being forwarded intact.
- Use `platformSystem = pkgs.stdenv.hostPlatform.system` when indexing flake-provided packages inside Home Manager modules.
- Put user packages in `home.packages`; put system packages in `environment.systemPackages`.

### Repo-backed symlink pattern

`homes/modules/base.nix` uses out-of-store symlinks into this repo for managed dotfiles. Reuse the same shape instead of inventing new path logic:

```nix
configPath = pathStr: config.lib.file.mkOutOfStoreSymlink "/home/${user}/.dotfiles${pathStr}";
```

### Conditionals and overrides

- Use `lib.mkIf`, `lib.mkDefault`, and `lib.optionals` for host/role/hardware gating.
- `hosts/base.nix` uses `host == "spi"` and `forServer` extensively; preserve those existing boundaries instead of scattering new booleans.
- Import order matters, especially under `homes/`: later imports win.

### Secrets and sensitive data

- Secrets are managed with Agenix. Reference them through `config.age.secrets.<name>.path` or the existing module wiring.
- Never commit plaintext secrets.
- In `k8s/`, `.env`, `.kubeconfig*`, and similar dotfiles are explicitly sensitive and must stay out of git.

### Subsystem-specific patterns

- `k8s/` follows a two-phase flow: manual secret/config bootstrap first, then Flux/GitOps reconciliation.
- `vim/nvim/` is LazyVim-style: add plugins under `vim/nvim/lua/plugins/*.lua`, keymaps in `lua/config/keymaps.lua`, options in `lua/config/options.lua`, and extras in `lazyvim.json`.
- `agent/` merges modular JSONC from `agent/config/*.jsonc` into one `opencode.jsonc`; preserve that merge-based layout.

## Runtime & Tooling Preferences

- Nix Flakes are the source of truth.
- Prefer `make` wrappers; they already encode host-specific behavior and tool detection.
- Use `devbox` anywhere a `devbox.json` exists. This is mandatory in practice for `k8s/`.
- Pre-commit currently enforces whitespace/YAML/JSON/basic file checks plus `commitizen`; shellcheck/checkmake hooks are present but commented out.
- Repo-wide automation also includes Renovate (`renovate.json`) and git-cliff (`cliff.toml`).
- Home Manager base tooling includes `bun`, `devbox`, `pre-commit`, `yq`, `jj`, `atuin`, `direnv`, and related CLI utilities, so prefer existing tooling before introducing new dependencies.

## Testing & QA

There is no conventional unit/integration test suite at the repo root. Verification is mostly static checks and real builds.

- `pre-commit run --all-files` for repo-wide hygiene
- Targeted Home Manager builds for changed homes
- Targeted NixOS builds for changed hosts
- `cd k8s && devbox shell && make check` for manifest validation via `kubectl kustomize | kubeconform`
- GitHub Actions in `.github/workflows/cachix.yaml` build selected Home Manager targets (`tshm@PN0093`, `tshm@minf`, `tshm@x360`, `tshm@PD0056`, `tshm@spi`) and NixOS hosts (`x360`, `minf`)
- `.github/workflows/app-update.yaml` runs `make apphash_update` on a schedule and opens a PR

Do not claim "tests passed" unless you ran the relevant build or validation command yourself.

## Operational Cautions

- `make home-manager`, `make os`, and many `agent/Makefile` targets mutate the local machine or user environment. Treat them as stateful operations, not harmless checks.
- `agent/Makefile` writes into `~/.config/opencode`, `~/.opencode`, and `~/.npm-globals`; `merge-config` also creates a backup of the previous output file.
- `k8s/Makefile` targets such as `init`, `config`, `n8n`, or `webdl` create secrets/config maps from environment variables and apply them to a real cluster.
- For documentation or config questions, prefer the subsystem guides over guessing from one file in isolation.
