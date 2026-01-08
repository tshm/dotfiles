# Dotfiles Knowledge Base

**Generated:** 2026-01-08
**Context:** NixOS + Home Manager Configuration

## Overview
NixOS/home-manager dotfiles managing multi-machine configurations (desktop, laptops, Raspberry Pi, USB boot).
Uses **Nix Flakes** for declarative system/user separation and **Agenix** for secret management.

## Development Workflow

### Build & Deploy
| Command | Description |
|---------|-------------|
| `make all` | Full rebuild (NixOS system + Home Manager user) |
| `make os` | Rebuild NixOS system only (requires sudo) |
| `make home-manager` | Rebuild Home Manager user config only |
| `make xx` | Build target system (defined by `TARGET` env var) |
| `make sd-burn` | Build and burn Raspberry Pi image (requires `spi.img`) |

### Maintenance
| Command | Description |
|---------|-------------|
| `make update` | Update `flake.lock` inputs |
| `make up` | Update flake inputs AND app hashes (`homes/apps/*.nix`) |
| `make clean` | Garbage collect old generations & optimize store |
| `make zi` | Update Zinit plugins (Zsh) |

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

| Task | Location |
|------|----------|
| **Add System Pkg** | `hosts/<host>/default.nix` or `hosts/modules/base.nix` |
| **Add User Pkg** | `homes/modules/base.nix` or `homes/modules/gui.nix` |
| **Hyprland Config** | `x/hyprland/` |
| **Neovim Plugins** | `vim/nvim/lua/plugins/` |
| **Shell Aliases** | `zsh/alias.zsh` |
| **App Versions** | `homes/apps/*.nix` (managed by `make up`) |

<!-- CLAVIX:START -->
# Clavix Instructions for GitHub Copilot

These instructions enhance GitHub Copilot's understanding of Clavix prompt optimization workflows available in this project.

---

## ⛔ CLAVIX MODE ENFORCEMENT

**CRITICAL: Know which mode you're in and STOP at the right point.**

**OPTIMIZATION workflows** (NO CODE ALLOWED):
- Fast/deep optimization - Prompt improvement only
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

**Troubleshooting:**
- `troubleshooting/jumped-to-implementation.md` - If you started coding during planning
- `troubleshooting/skipped-file-creation.md` - If files weren't created
- `troubleshooting/mode-confusion.md` - When unclear about planning vs implementation

**When detected:** Reference the corresponding `.clavix/instructions/workflows/{workflow}.md` file.

**⚠️ GitHub Copilot Limitation:** If Write tool unavailable, provide file content with clear "save to" instructions for user.

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
All workflows are executed via slash commands:

| Slash Command | Purpose |
|---------------|---------|
| `/clavix:improve` | Optimize prompts (auto-selects depth) |
| `/clavix:prd` | Generate PRD through guided questions |
| `/clavix:plan` | Create task breakdown from PRD |
| `/clavix:implement` | Execute tasks or prompts (auto-detects source) |
| `/clavix:start` | Begin conversational session |
| `/clavix:summarize` | Extract requirements from conversation |

### Agentic Utilities (Project Management)
| Utility | Purpose |
|---------|---------|
| `/clavix:verify` | Check implementation against PRD requirements |
| `/clavix:archive` | Archive completed work to `.clavix/archive/` |

---

## 🔄 Prompt Lifecycle Workflow

**Prompt Lifecycle:**
1. **Optimize**: `/clavix:improve` → Analyzes and improves your prompt
2. **Review**: Agent reads `.clavix/outputs/prompts/*.md` to list saved prompts
3. **Execute**: `/clavix:implement --latest` → Implement when ready
4. **Cleanup**: Agent deletes old prompt files from `.clavix/outputs/prompts/`

---

## 🔄 Standard Workflow

**Clavix follows this progression:**

```
PRD Creation → Task Planning → Implementation → Archive
```

**Detailed steps:**

1. **Planning Phase** - `/clavix:prd` or `/clavix:start` → `/clavix:summarize`
2. **Task Preparation** - `/clavix:plan` transforms PRD into tasks.md
3. **Implementation Phase** - `/clavix:implement` executes tasks systematically
4. **Completion** - `/clavix:archive` archives completed work

**Key principle:** Planning workflows create documents. Implementation workflows write code.

---

## 🎯 Quality Dimensions

When analyzing prompts, consider these 5 dimensions:

- **Clarity**: Is the objective clear and unambiguous?
- **Efficiency**: Concise without losing critical information?
- **Structure**: Information organized logically (context → requirements → constraints → output)?
- **Completeness**: All specs provided (persona, format, tone, success criteria)?
- **Actionability**: Can AI take immediate action?

**Reference:** See `workflows/improve.md` for complete quality assessment patterns

---

## 💡 Best Practices for GitHub Copilot

1. **Suggest appropriate workflow** - `/clavix:improve` for prompts, `/clavix:prd` for strategic planning
2. **Reference instruction files** - Point to `.clavix/instructions/workflows/*.md` instead of recreating steps
3. **Respect mode boundaries** - Planning mode = no code, Implementation mode = write code
4. **Use quality dimensions** - Apply 5-dimension assessment principles in responses
5. **Guide users to slash commands** - Recommend appropriate `/clavix:*` commands for their needs

---

## ⚠️ Common Mistakes

### ❌ Jumping to implementation during planning
**Wrong:** User discusses feature → Copilot generates code immediately

**Right:** User discusses feature → Suggest `/clavix:prd` or `/clavix:start` → Create planning docs first

### ❌ Not suggesting Clavix workflows
**Wrong:** User asks "How should I phrase this?" → Copilot provides generic advice

**Right:** User asks "How should I phrase this?" → Suggest `/clavix:improve` for quality assessment

### ❌ Recreating workflow steps inline
**Wrong:** Copilot explains entire PRD generation process in chat

**Right:** Copilot references `.clavix/instructions/workflows/prd.md` and suggests running `/clavix:prd`

---

## 🔗 Integration with GitHub Copilot

When users ask for help with prompts or requirements:

1. **Detect need** - Identify if user needs planning, optimization, or implementation
2. **Suggest slash command** - Recommend appropriate `/clavix:*` command
3. **Explain benefit** - Describe expected output and value
4. **Help interpret** - Assist with understanding Clavix-generated outputs
5. **Apply principles** - Use quality dimensions in your responses

**Example flow:**
```
User: "I want to build a dashboard but I'm not sure how to phrase the requirements"
Copilot: "I suggest running `/clavix:start` to begin conversational requirements gathering.
This will help us explore your needs naturally, then we can extract structured requirements
with `/clavix:summarize`. Alternatively, if you have a rough idea, try:
`/clavix:improve 'Build a dashboard for...'` for quick optimization."
```

---

**Artifacts stored under `.clavix/`:**
- `.clavix/outputs/<project>/` - PRDs, tasks, prompts
- `.clavix/config.json` - Project configuration

---

**For complete workflows:** Always reference `.clavix/instructions/workflows/{workflow}.md`

**For troubleshooting:** Check `.clavix/instructions/troubleshooting/`

**For mode clarification:** See `.clavix/instructions/core/clavix-mode.md`

<!-- CLAVIX:END -->
