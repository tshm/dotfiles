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


.PHONY: pi-dev pi-base pi-mono-cache pi-extensions pi-ext-subagent pi-ext-plan pi-ext-todo pi-ext-permission pi-ext-preset pi-ext-git-checkpoint pi-skills pi-config pi-clean

pi-dev: pi-base pi-mono-cache pi-extensions pi-skills pi-config
	@echo "pi-dev: full setup complete (installing base pi, caching pi-mono, linking extensions/skills/config)"

pi-base:
	@echo "Installing/upgrading @mariozechner/pi-coding-agent"
	mkdir -p ~/.npm-globals/
	npm install ${NPM_OPT} @mariozechner/pi-coding-agent

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

pi-extensions: pi-ext-subagent pi-ext-plan pi-ext-todo pi-ext-permission pi-ext-preset pi-ext-git-checkpoint
	@echo "Linked extensions into ~/.pi/agent/extensions"

pi-ext-subagent:
	@echo "Linking subagent extension"
	mkdir -p ~/.pi/agent/extensions
	ln -sf ~/.cache/pi-mono/packages/coding-agent/examples/extensions/subagent ~/.pi/agent/extensions/subagent

pi-ext-plan:
	@echo "Linking plan-mode extension"
	mkdir -p ~/.pi/agent/extensions
	ln -sf ~/.cache/pi-mono/packages/coding-agent/examples/extensions/plan-mode ~/.pi/agent/extensions/plan-mode

pi-ext-todo:
	@echo "Linking todo.ts"
	mkdir -p ~/.pi/agent/extensions
	ln -sf ~/.cache/pi-mono/packages/coding-agent/examples/extensions/todo.ts ~/.pi/agent/extensions/todo.ts

pi-ext-permission:
	@echo "Linking permission-gate.ts"
	mkdir -p ~/.pi/agent/extensions
	ln -sf ~/.cache/pi-mono/packages/coding-agent/examples/extensions/permission-gate.ts ~/.pi/agent/extensions/permission-gate.ts

pi-ext-preset:
	@echo "Linking preset.ts"
	mkdir -p ~/.pi/agent/extensions
	ln -sf ~/.cache/pi-mono/packages/coding-agent/examples/extensions/preset.ts ~/.pi/agent/extensions/preset.ts

pi-ext-git-checkpoint:
	@echo "Linking git-checkpoint.ts"
	mkdir -p ~/.pi/agent/extensions
	ln -sf ~/.cache/pi-mono/packages/coding-agent/examples/extensions/git-checkpoint.ts ~/.pi/agent/extensions/git-checkpoint.ts

pi-skills:
	@echo "Linking skills (cartography, find-skills, markitdown, skill-creator) into ~/.pi/agent/skills"
	mkdir -p ~/.pi/agent/skills
	[ -d ${CURDIR}/skills/markitdown ] && ln -sf ${CURDIR}/skills/markitdown ~/.pi/agent/skills/markitdown || true
	[ -d ~/.omp/skills/cartography ] && ln -sf ~/.omp/skills/cartography ~/.pi/agent/skills/cartography || true
	[ -d ~/.omp/skills/find-skills ] && ln -sf ~/.omp/skills/find-skills ~/.pi/agent/skills/find-skills || true
	[ -d ~/.omp/skills/skill-creator ] && ln -sf ~/.omp/skills/skill-creator ~/.pi/agent/skills/skill-creator || true
	# fallback: check ~/.agents/skills
	[ -d ~/.agents/skills/cartography ] && ln -sf ~/.agents/skills/cartography ~/.pi/agent/skills/cartography || true
	[ -d ~/.agents/skills/find-skills ] && ln -sf ~/.agents/skills/find-skills ~/.pi/agent/skills/find-skills || true
	[ -d ~/.agents/skills/skill-creator ] && ln -sf ~/.agents/skills/skill-creator ~/.pi/agent/skills/skill-creator || true

pi-config:
	@echo "Linking AGENTS.md and ensuring settings.json"
	mkdir -p ~/.pi/agent
	ln -sf ${PWD}/BASE_AGENTS.md ~/.pi/agent/AGENTS.md
	# preserve existing settings.json if present; otherwise write a minimal one
	if [ -f ~/.pi/agent/settings.json ]; then \
		echo "settings.json already exists, leaving unchanged"; \
	else \
		printf '%s\n' '{' '  "quietStartup": true,' '  "defaultThinkingLevel": "off"' '}' > ~/.pi/agent/settings.json; \
	fi

pi-clean:
	@echo "Cleaning pi cache and pi config symlinks (careful!)"
	rm -rf ~/.cache/pi-mono
	rm -rf ~/.pi/agent/extensions
	rm -rf ~/.pi/agent/skills
	rm -f ~/.pi/agent/AGENTS.md
