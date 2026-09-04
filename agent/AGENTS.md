# Agent Tooling

## Purpose

Local agent and assistant tooling: OpenCode configuration, Pi extensions, Claude Code/LiteLLM setup, install automation, generated config merge, notification extension, and user systemd service assets.

## Ownership

- Owns everything under `agent/`.
- `Makefile` owns installation/update workflows.
- `config/*.jsonc` owns OpenCode config fragments merged into `opencode.jsonc`.
- `BASE_AGENTS.md` owns the installed OpenCode base instruction file.
- `systemd/` owns user service units symlinked into `~/.config/systemd/user/`.

## Local Contracts

- Keep `Makefile`, `merge-config.sh`, and `config/*.jsonc` in sync when adding or renaming OpenCode config fragments.
- Generated OpenCode configurations default to `openai/gpt-5.6-sol` via `config/model.jsonc`.
- Do not commit API keys, provider credentials, LiteLLM keys, or host-local secrets; pass them through environment variables or ignored runtime config.
- Install targets may mutate user-level state under `~/.config`, `~/.local`, `~/.npm-globals`, and systemd user units; do not run them casually during verification.
- Preserve symlink-based install behavior unless intentionally changing the user's live config layout.
- `extensions/notify.ts` sends WezTerm notifications through the `OMP_NOTIFICATION` user var; `wezterm/wezterm_base.lua` owns its clickable Mango focus action.

## Work Guidance

- Prefer adding config as separate `config/*.jsonc` fragments and let `merge-config` compose them.
- Keep installer targets idempotent and fail-fast with explicit missing-prerequisite messages.
- For service changes, keep paths aligned with `systemd/litellm.service` and the wrapper created by the `litellm` target.

## Verification

- For config merge changes, run `make merge-config OUTPUT_FILE=/tmp/opencode.jsonc` from `agent/`.
- For TypeScript extension changes, run `bun build extensions/notify.ts --target=bun --outfile=/tmp/notify-extension.js` from `agent/`.

## Child DOX Index

No child DOX files.
