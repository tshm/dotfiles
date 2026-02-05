SHELL := $(shell command -v bash 2>/dev/null || command -v sh)
.SHELLFLAGS := -euo pipefail -c
.ONESHELL:

CONFIG_DIR ?= ${PWD}/config
OUTPUT_FILE ?= ${PWD}/opencode.jsonc
BACKUP_FILE ?= ${OUTPUT_FILE}.backup

.PHONY: dev clavix beads
dev: opencode beads

.PHONY: skills
skills: agent-browser

.PHONY: agent-browser
agent-browser:
	npx skills add vercel-labs/agent-browser

clavix: ~/.npm-globals/bin/clavix
	@echo "installing clavix..."
	mkdir -p ~/.npm-globals/
	npm install -g --prefix ~/.npm-globals/ clavix

beads: ~/.local/bin/bd
	@echo "installing bd..."
	mkdir -p ~/tshm/.local/bin/
	# for more details
	bd upgrade || curl -fsSL https://raw.githubusercontent.com/steveyegge/beads/main/scripts/install.sh | bash

.PHONY: clawdbot
clawdbot:
	npm install -g --prefix ~/.npm-globals/ clawdbot

.PHONY: tokenscope
tokenscope:
	curl -sSL https://raw.githubusercontent.com/ramtinJ95/opencode-tokenscope/main/plugin/install.sh | bash

.PHONY: agents
agents:
	curl -fsSL https://raw.githubusercontent.com/darrenhinde/OpenAgentsControl/main/install.sh | bash -s full --install-dir ~/.config/opencode

.PHONY: openclaw
openclaw:
	npm install -g --prefix ~/.npm-globals/ openclaw

oh-my-opencode: opencode
	@echo "installing oh-my-opencode..."
	bunx oh-my-opencode install

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

