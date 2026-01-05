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


<!-- CLAVIX:START -->
# Clavix Instructions for Generic Agents

This guide is for agents that can only read documentation (no slash-command support). If your platform supports custom slash commands, use those instead.

---

## ⛔ CLAVIX MODE ENFORCEMENT

**CRITICAL: Know which mode you're in and STOP at the right point.**

**OPTIMIZATION workflows** (NO CODE ALLOWED):
- Improve mode - Prompt optimization only (auto-selects depth)
- Your role: Analyze, optimize, show improved prompt, **STOP**
- ❌ DO NOT implement the prompt's requirements
- ✅ After showing optimized prompt, tell user: "Run `/clavix:implement --latest` to implement"

**PLANNING workflows** (NO CODE ALLOWED):
- Conversational mode, requirement extraction, PRD generation
- Your role: Ask questions, create PRDs/prompts, extract requirements
- ❌ DO NOT implement features during these workflows

**IMPLEMENTATION workflows** (CODE ALLOWED):
- Only after user runs execute/implement commands
- Your role: Write code, execute tasks, implement features
- ✅ DO implement code during these workflows

**If unsure, ASK:** "Should I implement this now, or continue with planning?"

See `.clavix/instructions/core/clavix-mode.md` for complete mode documentation.

---

## 📁 Detailed Workflow Instructions

For complete step-by-step workflows, see `.clavix/instructions/`:

| Workflow | Instruction File | Purpose |
|----------|-----------------|---------|
| **Conversational Mode** | `workflows/start.md` | Natural requirements gathering through discussion |
| **Extract Requirements** | `workflows/summarize.md` | Analyze conversation → mini-PRD + optimized prompts |
| **Prompt Optimization** | `workflows/improve.md` | Intent detection + quality assessment + auto-depth selection |
| **PRD Generation** | `workflows/prd.md` | Socratic questions → full PRD + quick PRD |
| **Mode Boundaries** | `core/clavix-mode.md` | Planning vs implementation distinction |
| **File Operations** | `core/file-operations.md` | File creation patterns |
| **Verification** | `core/verification.md` | Post-implementation verification |

**Troubleshooting:**
- `troubleshooting/jumped-to-implementation.md` - If you started coding during planning
- `troubleshooting/skipped-file-creation.md` - If files weren't created
- `troubleshooting/mode-confusion.md` - When unclear about planning vs implementation

---

## 🔍 Workflow Detection Keywords

| Keywords in User Request | Recommended Workflow | File Reference |
|---------------------------|---------------------|----------------|
| "improve this prompt", "make it better", "optimize" | Improve mode → Auto-depth optimization | `workflows/improve.md` |
| "analyze thoroughly", "edge cases", "alternatives" | Improve mode (--comprehensive) | `workflows/improve.md` |
| "create a PRD", "product requirements" | PRD mode → Socratic questioning | `workflows/prd.md` |
| "let's discuss", "not sure what I want" | Conversational mode → Start gathering | `workflows/start.md` |
| "summarize our conversation" | Extract mode → Analyze thread | `workflows/summarize.md` |
| "refine", "update PRD", "change requirements", "modify prompt" | Refine mode → Update existing content | `workflows/refine.md` |
| "verify", "check my implementation" | Verify mode → Implementation verification | `core/verification.md` |

**When detected:** Reference the corresponding `.clavix/instructions/workflows/{workflow}.md` file.

---

## 📋 Clavix Commands (v5)

### Setup Commands (CLI)
| Command | Purpose |
|---------|---------|
| `clavix init` | Initialize Clavix in a project |
| `clavix update` | Update templates after package update |
| `clavix diagnose` | Check installation health |
| `clavix version` | Show version |

### Workflow Commands (Slash Commands)
All workflows are executed via slash commands that AI agents read and follow:

> **Command Format:** Commands shown with colon (`:`) format. Some tools use hyphen (`-`): Claude Code uses `/clavix:improve`, Cursor uses `/clavix-improve`. Your tool autocompletes the correct format.

| Slash Command | Purpose |
|---------------|---------|
| `/clavix:improve` | Optimize prompts (auto-selects depth) |
| `/clavix:prd` | Generate PRD through guided questions |
| `/clavix:plan` | Create task breakdown from PRD |
| `/clavix:implement` | Execute tasks or prompts (auto-detects source) |
| `/clavix:start` | Begin conversational session |
| `/clavix:summarize` | Extract requirements from conversation |
| `/clavix:refine` | Refine existing PRD or saved prompt |

### Agentic Utilities (Project Management)
These utilities provide structured workflows for project completion:

| Utility | Purpose |
|---------|---------|
| `/clavix:verify` | Check implementation against PRD requirements, run validation |
| `/clavix:archive` | Archive completed work to `.clavix/archive/` for reference |

**Quick start:**
```bash
npm install -g clavix
clavix init
```

**How it works:** Slash commands are markdown templates. When invoked, the agent reads the template and follows its instructions using native tools (Read, Write, Edit, Bash).

---

## 🔄 Standard Workflow

**Clavix follows this progression:**

```
PRD Creation → Task Planning → Implementation → Archive
```

**Detailed steps:**

1. **Planning Phase**
   - Run: `/clavix:prd` or `/clavix:start` → `/clavix:summarize`
   - Output: `.clavix/outputs/{project}/full-prd.md` + `quick-prd.md`
   - Mode: PLANNING

2. **Task Preparation**
   - Run: `/clavix:plan` transforms PRD into curated task list
   - Output: `.clavix/outputs/{project}/tasks.md`
   - Mode: PLANNING (Pre-Implementation)

3. **Implementation Phase**
   - Run: `/clavix:implement`
   - Agent executes tasks systematically
   - Mode: IMPLEMENTATION
   - Agent edits tasks.md directly to mark progress (`- [ ]` → `- [x]`)

4. **Completion**
   - Run: `/clavix:archive`
   - Archives completed work
   - Mode: Management

**Key principle:** Planning workflows create documents. Implementation workflows write code.

---

## 💡 Best Practices for Generic Agents

1. **Always reference instruction files** - Don't recreate workflow steps inline, point to `.clavix/instructions/workflows/`

2. **Respect mode boundaries** - Planning mode = no code, Implementation mode = write code

3. **Use checkpoints** - Follow the CHECKPOINT pattern from instruction files to track progress

4. **Create files explicitly** - Use Write tool for every file, verify with ls, never skip file creation

5. **Ask when unclear** - If mode is ambiguous, ask: "Should I implement or continue planning?"

6. **Track complexity** - Use conversational mode for complex requirements (15+ exchanges, 5+ features, 3+ topics)

7. **Label improvements** - When optimizing prompts, mark changes with [ADDED], [CLARIFIED], [STRUCTURED], [EXPANDED], [SCOPED]

---

## ⚠️ Common Mistakes

### ❌ Jumping to implementation during planning
**Wrong:** User discusses feature → agent generates code immediately

**Right:** User discusses feature → agent asks questions → creates PRD/prompt → asks if ready to implement

### ❌ Skipping file creation
**Wrong:** Display content in chat, don't write files

**Right:** Create directory → Write files → Verify existence → Display paths

### ❌ Recreating workflow instructions inline
**Wrong:** Copy entire fast mode workflow into response

**Right:** Reference `.clavix/instructions/workflows/improve.md` and follow its steps

### ❌ Not using instruction files
**Wrong:** Make up workflow steps or guess at process

**Right:** Read corresponding `.clavix/instructions/workflows/*.md` file and follow exactly

---

**Artifacts stored under `.clavix/`:**
- `.clavix/outputs/<project>/` - PRDs, tasks, prompts
- `.clavix/templates/` - Custom overrides

---

**For complete workflows:** Always reference `.clavix/instructions/workflows/{workflow}.md`

**For troubleshooting:** Check `.clavix/instructions/troubleshooting/`

**For mode clarification:** See `.clavix/instructions/core/clavix-mode.md`

<!-- CLAVIX:END -->

## Landing the Plane (Session Completion)

**When ending a work session**, you MUST complete ALL steps below. Work is NOT complete until `git push` succeeds.

**MANDATORY WORKFLOW:**

1. **File issues for remaining work** - Create issues for anything that needs follow-up
2. **Run quality gates** (if code changed) - Tests, linters, builds
3. **Update issue status** - Close finished work, update in-progress items
4. **PUSH TO REMOTE** - This is MANDATORY:
   ```bash
   git pull --rebase
   bd sync
   git push
   git status  # MUST show "up to date with origin"
   ```
5. **Clean up** - Clear stashes, prune remote branches
6. **Verify** - All changes committed AND pushed
7. **Hand off** - Provide context for next session

**CRITICAL RULES:**
- Work is NOT complete until `git push` succeeds
- NEVER stop before pushing - that leaves work stranded locally
- NEVER say "ready to push when you are" - YOU must push
- If push fails, resolve and retry until it succeeds
