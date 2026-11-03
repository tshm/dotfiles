# Repository guidance

Personal dotfiles managed primarily with Nix flakes and Home Manager, with NixOS,
standalone Linux, WSL, and Windows configuration. Keep changes scoped to the
requested machine or tool; shared modules affect multiple environments.

## Layout

- `flake.nix` / `flake.lock`: inputs and outputs; imports `hosts/` and `homes/`.
- `hosts/default.nix`: NixOS configuration selectors. `tp` uses `hosts/t440p/`;
  other selectors include `minf`, `x360`, `usb`, `spi`, `spi_first`, and `installer`.
- `hosts/base.nix` / `hosts/gui.nix`: shared system configuration.
- `homes/default.nix`: composes per-machine Home Manager configurations.
  Read the relevant machine module for the exact username/hostname selector.
- `homes/modules/`: shared user modules; `homes/apps/`: application packages.
- `vim/nvim/`, `zsh/`, `x/`, `wezterm/`, `yazi/`, `kanata/`, `ahk/`, `wsl/`:
  tool and desktop configuration.
- `agent/`: AI-tool configuration, extensions, skills, and installation targets.
- `k8s/`: infrastructure and Kubernetes configuration; consult its own README
  and security documentation before changes.
- `secrets/`: encrypted age secrets and recipient configuration.
- `docs/nixos-install-iso.md`: installer build and manual installation guide.

## Editing conventions

- Follow the surrounding file's style; avoid unrelated formatting changes.
- Trace imports and consumers before changing shared configuration. Keep
  machine-specific settings in machine modules rather than shared defaults.
- Prefer existing Nix modules and package definitions over duplicate shell setup.
- Keep `flake.lock` unchanged unless dependency changes are part of the task.
- Never expose or commit plaintext secrets, private keys, or local `.env` values.
- Update existing documentation when changing documented commands or behavior.

## Validation

Run the narrowest relevant check; report unavailable tools rather than claiming
verification. Syntax parsing does not establish successful Nix evaluation.

- Parse changed Nix files: `nix-instantiate --parse path/to/file.nix`.
- Run configured hooks: `pre-commit run --files path/to/changed-file ...`.
  `.pre-commit-config.yaml` defines whitespace, YAML/JSON, Nix syntax, commitizen,
  scoped ShellCheck, and Makefile checks.
- Build a selected NixOS configuration without activation:
  `nix build '.#nixosConfigurations.<host>.config.system.build.toplevel' --no-link`.
- Build a selected Home Manager configuration without activation:
  `nix build '.#homeConfigurations.<selector>.activationPackage' --no-link`.
- Run relevant existing script checks and exercise changed behavior when possible.
  Builds may require downloads and an appropriate target architecture.

## Commands with side effects

Do not use deployment or installation commands as routine validation.

- `make all` activates Home Manager and, on NixOS, runs the OS boot deployment.
- `make home-manager` switches the live home configuration; `make os` changes the
  boot configuration. OS targets prefer `~/.dotfiles-private` when present.
- `make dev` delegates to `agent/Makefile`, which contains tool installers.
- `make update` updates flake inputs; `make up` also updates application hashes.
- `make clean` removes old generations; `make sd-burn` writes a disk image.
  Require explicit user intent before destructive or host-changing operations.
- `make installer-iso` builds an ISO in `result-installer/iso/` without installing it.

Home Manager activation expects this checkout at `~/.dotfiles` and manages
`~/.config/home-manager/flake.nix` as a symlink to its `flake.nix`.

<!-- trail:start -->
## Trail — repo context graph

This repo is indexed in `.trail/cache/`: small linked markdown nodes that explain each
system and carry exact file:line spans, kept in sync with the code through git.

For ANY task here — understanding how something works, finding where code lives,
or scoping a change — get context from the graph before grepping or opening
source files. Re-ask freely (it's cheap) and reuse literal identifiers you
already have (symbol, error string, file name) as the query. New to this repo?
Run `trail map` first — a token-budgeted orientation (dir clusters, hubs,
hotspots), no LLM, no key.

- Run `trail ask "<your question>" --source` → ranked nodes with the relevant
  code spans inlined (each hit's ≤8-line crux by default; `--full` for whole
  definitions when the crux isn't enough). Match the tool to the task shape:
  for understanding or editing, the top node IS the answer — cite its
  `covers:` file:line spans and edit straight from `--source`. For
  exhaustive tasks ("every occurrence / every caller of this pattern"), ranked
  results are top-N, not complete — run `trail grep "<literal>"` instead
  (exhaustive over indexed files, grouped by enclosing symbol), falling back
  to raw `grep -rn` only for unindexed files.
- `trail skeleton <file>` → every definition's signature + span, ~10× cheaper
  than reading the file; use it to skim an API surface.
- `trail callers <symbol>` gives precomputed, exact edges — who calls this.
  Add `--direction out` for what it calls, or `--depth N` to walk
  transitively for the full blast radius. For structural questions, skip
  ranking and use this directly.
- Or browse: `.trail/cache/INDEX.md` lists every node; follow the links.
- Monorepos and folders of multiple repos rank fairly across sub-projects —
  hits carry `[scope/]` labels naming which one they're from. Narrow with
  `trail ask "<task>" --in <scope>/` once you know where you're working.

If a returned span is truncated ("+N more lines"), open the file at that exact
range before finalizing. Only open source files when a node genuinely lacks a
needed detail, and then at the exact file:line the node points to — never
re-read whole files.

After big code changes, refresh the graph with `trail build` (deterministic,
no API key, $0).
<!-- trail:end -->
