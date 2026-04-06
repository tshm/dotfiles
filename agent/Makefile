SHELL := $(shell command -v bash 2>/dev/null || command -v sh)
.SHELLFLAGS := -euo pipefail -c
.ONESHELL:

CONFIG_DIR ?= ${PWD}/config
OUTPUT_FILE ?= ${PWD}/opencode.jsonc
BACKUP_FILE ?= ${OUTPUT_FILE}.backup
NPM_OPT ?= -g --prefix ~/.npm-globals/

dev: opencode

.PHONY: skills
skills: agent-browser

.PHONY: openchamber
openchamber:
	bun add -g @openchamber/web

.PHONY: markitdown
markitdown:
	npx skills add https://github.com/davila7/claude-code-templates --skill markitdown

.PHONY: agent-browser
agent-browser:
	@echo "installing agent-browser..."
	mkdir -p ~/.npm-globals/
	npm install ${NPM_OPT} agent-browser
# 	npx -g --prefix ~/.npm-globals/ skills add vercel-labs/agent-browser

clavix: ~/.npm-globals/bin/clavix
	@echo "installing clavix..."
	mkdir -p ~/.npm-globals/
	npm install ${NPM_OPT} clavix

beads: ~/.local/bin/bd
	@echo "installing bd..."
	mkdir -p ~/.local/bin/
	# for more details
	bd upgrade || curl -fsSL https://raw.githubusercontent.com/steveyegge/beads/main/scripts/install.sh | bash

.PHONY: clawdbot
clawdbot:
	npm install ${NPM_OPT} clawdbot

.PHONY: tokenscope
tokenscope:
	curl -sSL https://raw.githubusercontent.com/ramtinJ95/opencode-tokenscope/main/plugin/install.sh | bash

.PHONY: agents
agents:
	curl -fsSL https://raw.githubusercontent.com/darrenhinde/OpenAgentsControl/main/install.sh | bash -s full --install-dir ~/.config/opencode

.PHONY: pi
pi:
	npm install ${NPM_OPT} @mariozechner/pi-coding-agent

.PHONY: omp
omp:
	curl -fsSL https://raw.githubusercontent.com/can1357/oh-my-pi/main/scripts/install.sh | sh

.PHONY: omo
omo:
	@echo "installing oh-my-opencode-slim..."
	#bunx oh-my-opencode install
	bunx oh-my-opencode-slim@latest install

.PHONY: clean-tools
clean-tools:
	rm -rf ~/.config/opencode/node_modules

.PHONY: opencode
opencode: ~/.opencode/bin/opencode
	@echo "installing opencode..."
	[ -x ~/.opencode/bin/opencode ] && ~/.opencode/bin/opencode upgrade || (curl -fsSL https://opencode.ai/install | bash)
	@echo update config
	mkdir -p ~/.config/opencode/config
	ln -sf ${PWD}/BASE_AGENTS.md ~/.config/opencode/AGENTS.md
	for i in ${PWD}/config/*.jsonc; do \
	  ln -sf $$i ~/.config/opencode/config/$$(basename $$i); \
	done
	${MAKE} merge-config CONFIG_DIR=~/.config/opencode/config OUTPUT_FILE=~/.config/opencode/opencode.jsonc

.PHONY: merge-config
.SILENT: merge-config
merge-config:
	RED='\033[0;31m'
	GREEN='\033[0;32m'
	YELLOW='\033[1;33m'
	NC='\033[0m'
	log_info() { printf "%b\n" "$${GREEN}[INFO]$${NC} $$1"; }
	log_warn() { printf "%b\n" "$${YELLOW}[WARN]$${NC} $$1"; }
	log_error() { printf "%b\n" "$${RED}[ERROR]$${NC} $$1"; }

	merge_named() {
		local file="$$1"
		local key="$$2"
		local path="${CONFIG_DIR}/$$file.jsonc"
		if [ -f "$$path" ]; then
			log_info "  + $$file.jsonc"
			BASE_CONFIG=$$(echo "$$BASE_CONFIG" | yq --slurpfile data <(cat "$$path" | grep -v '^[[:blank:]]*//'| yq) ". + {\"$$key\": \$$data[0]}")
		fi
	}
	if [ ! -d "${CONFIG_DIR}" ]; then
		log_error "Config directory not found: ${CONFIG_DIR}"
		exit 1
	fi
	if [ -f "${OUTPUT_FILE}" ]; then
		log_info "Backing up existing ${OUTPUT_FILE} to ${BACKUP_FILE}"
		cp "${OUTPUT_FILE}" "${BACKUP_FILE}"
	fi
	log_info "Merging config files from: ${CONFIG_DIR}"
	BASE_CONFIG='{
	  "$$schema": "https://opencode.ai/config.json"
	}'
	merge_named tools tools
	merge_named mcp mcp
	merge_named plugins plugin
	merge_named providers provider
	for config_file in "${CONFIG_DIR}"/*.jsonc; do
		filename=$$(basename "$$config_file" .jsonc)
		case "$$filename" in \
			tools|mcp|plugins|providers) continue ;;
		esac
		log_info "  + $$filename.jsonc"
		BASE_CONFIG=$$(echo "$$BASE_CONFIG" | yq --slurpfile data <(cat "$$config_file" | grep -v '^[[:blank:]]*//'| yq) ". + {\"$$filename\": \$$data[0]}")
	done
	echo "$$BASE_CONFIG" | yq '.' > "${OUTPUT_FILE}"
	log_info "Successfully generated: ${OUTPUT_FILE}"
	log_info "Done!"


.PHONY: pi-dev pi-base pi-mono-cache pi-extensions pi-ext-subagent pi-ext-plan pi-ext-todo pi-ext-permission pi-ext-preset pi-ext-git-checkpoint pi-ext-notify pi-skills pi-config pi-clean

OMP_AGENT_DIR ?= ${HOME}/.omp/agent
OMP_EXT_DIR ?= ${OMP_AGENT_DIR}/extensions
OMP_SKILL_DIR ?= ${OMP_AGENT_DIR}/skills
VSCODE_USER_DIR ?= ${HOME}/.config/Code/User
VSCODE_SETTINGS ?= ${VSCODE_USER_DIR}/settings.json

pi-dev: pi-base pi-mono-cache pi-extensions pi-skills pi-config
	@echo "pi-dev: full setup complete (installing base omp, caching pi-mono, linking extensions/skills/config)"

pi-base:
	@echo "Installing/upgrading @oh-my-pi/pi-coding-agent"
	bun install -g @oh-my-pi/pi-coding-agent

pi-mono-cache:
	@echo "Cloning pi-mono examples/extensions into ~/.cache/pi-mono"
	mkdir -p ~/.cache/pi-mono
	if [ -d ~/.cache/pi-mono/.git ]; then \
		git -C ~/.cache/pi-mono fetch --all --prune && git -C ~/.cache/pi-mono reset --hard origin/main || true; \
	else \
		git clone --filter=blob:none --no-checkout https://github.com/badlogic/pi-mono.git ~/.cache/pi-mono && \
		git -C ~/.cache/pi-mono sparse-checkout init --cone && \
		git -C ~/.cache/pi-mono sparse-checkout set examples/extensions && \
		git -C ~/.cache/pi-mono checkout; \
	fi

pi-extensions: pi-ext-subagent pi-ext-plan pi-ext-todo pi-ext-permission pi-ext-preset pi-ext-git-checkpoint pi-ext-notify
	@echo "Linked extensions into ${OMP_EXT_DIR}"

pi-ext-subagent:
	@echo "Linking subagent extension"
	mkdir -p ${OMP_EXT_DIR}
	ln -sf ~/.cache/pi-mono/packages/coding-agent/examples/extensions/subagent ${OMP_EXT_DIR}/subagent

pi-ext-plan:
	@echo "Linking plan-mode extension"
	mkdir -p ${OMP_EXT_DIR}
	ln -sf ~/.cache/pi-mono/packages/coding-agent/examples/extensions/plan-mode ${OMP_EXT_DIR}/plan-mode

pi-ext-todo:
	@echo "Linking todo.ts"
	mkdir -p ${OMP_EXT_DIR}
	ln -sf ~/.cache/pi-mono/packages/coding-agent/examples/extensions/todo.ts ${OMP_EXT_DIR}/todo.ts

pi-ext-permission:
	@echo "Linking permission-gate.ts"
	mkdir -p ${OMP_EXT_DIR}
	ln -sf ~/.cache/pi-mono/packages/coding-agent/examples/extensions/permission-gate.ts ${OMP_EXT_DIR}/permission-gate.ts

pi-ext-preset:
	@echo "Linking preset.ts"
	mkdir -p ${OMP_EXT_DIR}
	ln -sf ~/.cache/pi-mono/packages/coding-agent/examples/extensions/preset.ts ${OMP_EXT_DIR}/preset.ts

pi-ext-git-checkpoint:
	@echo "Linking git-checkpoint.ts"
	mkdir -p ${OMP_EXT_DIR}
	ln -sf ~/.cache/pi-mono/packages/coding-agent/examples/extensions/git-checkpoint.ts ${OMP_EXT_DIR}/git-checkpoint.ts

pi-ext-notify:
	@echo "Linking notify.ts"
	mkdir -p ${OMP_EXT_DIR}
	ln -sf ${CURDIR}/extensions/notify.ts ${OMP_EXT_DIR}/notify.ts

pi-skills:
	@echo "Linking skills (cartography, find-skills, markitdown, skill-creator) into ${OMP_SKILL_DIR}"
	mkdir -p ${OMP_SKILL_DIR}
	[ -d ${CURDIR}/skills/markitdown ] && ln -sf ${CURDIR}/skills/markitdown ${OMP_SKILL_DIR}/markitdown || true
	[ -d ${HOME}/.omp/skills/cartography ] && ln -sf ${HOME}/.omp/skills/cartography ${OMP_SKILL_DIR}/cartography || true
	[ -d ${HOME}/.omp/skills/find-skills ] && ln -sf ${HOME}/.omp/skills/find-skills ${OMP_SKILL_DIR}/find-skills || true
	[ -d ${HOME}/.omp/skills/skill-creator ] && ln -sf ${HOME}/.omp/skills/skill-creator ${OMP_SKILL_DIR}/skill-creator || true
	# fallback: check ~/.agents/skills
	[ -d ${HOME}/.agents/skills/cartography ] && ln -sf ${HOME}/.agents/skills/cartography ${OMP_SKILL_DIR}/cartography || true
	[ -d ${HOME}/.agents/skills/find-skills ] && ln -sf ${HOME}/.agents/skills/find-skills ${OMP_SKILL_DIR}/find-skills || true
	[ -d ${HOME}/.agents/skills/skill-creator ] && ln -sf ${HOME}/.agents/skills/skill-creator ${OMP_SKILL_DIR}/skill-creator || true

pi-config:
	@echo "Linking AGENTS.md and configuring OMP notifications"
	mkdir -p ${OMP_AGENT_DIR}
	ln -sf ${PWD}/BASE_AGENTS.md ${OMP_AGENT_DIR}/AGENTS.md
	omp config set startup.quiet true
	omp config set completion.notify off
	omp config set ask.notify on
	@echo "Ensuring VS Code terminal bell is enabled in ${VSCODE_SETTINGS}"
	mkdir -p ${VSCODE_USER_DIR}
	env SETTINGS_FILE="${VSCODE_SETTINGS}" bun --eval 'const path = process.env.SETTINGS_FILE; if (!path) throw new Error("SETTINGS_FILE is required"); let data = {}; const file = Bun.file(path); if (await file.exists()) { const text = await file.text(); if (text.trim().length > 0) data = JSON.parse(text); } data["terminal.integrated.enableBell"] = true; data["terminal.integrated.bellDuration"] = 1000; await Bun.write(path, JSON.stringify(data, null, 2) + "\n");'

pi-clean:
	@echo "Cleaning pi cache and omp config symlinks (careful!)"
	rm -rf ~/.cache/pi-mono
	rm -rf ${OMP_EXT_DIR}
	rm -rf ${OMP_SKILL_DIR}
	rm -f ${OMP_AGENT_DIR}/AGENTS.md