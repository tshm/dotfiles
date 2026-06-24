SHELL := $(shell command -v bash 2>/dev/null || command -v sh)
.SHELLFLAGS := -euo pipefail -c
.ONESHELL:

.PHONY: all dev skills openchamber markitdown agent-browser agents pi pi-ext pi-local-extensions task-factory omp claudecode litellm omo clean-tools opencode merge-config

.DEFAULT_GOAL := all

CONFIG_DIR ?= ${PWD}/config
OUTPUT_FILE ?= ${PWD}/opencode.jsonc
BACKUP_FILE ?= ${OUTPUT_FILE}.backup
NPM_OPT ?= -g --prefix ~/.npm-globals/
PI_AGENT_EXT_DIRS ?= ~/.pi/agent/extensions
CLAUDE_CODE_INSTALL_URL ?= https://claude.ai/install.sh
CLAUDE_CODE_INSTALL_ARGS ?=
CLAUDE_SETTINGS_DIR ?= ~/.claude
CLAUDE_SETTINGS_FILE ?= ${CLAUDE_SETTINGS_DIR}/settings.json
LITELLM_PROXY_URL ?= http://127.0.0.1:4000
LITELLM_PROXY_API_KEY ?=

all: dev

dev: opencode

skills: agent-browser

.PHONY: graphify
graphify:
	uv tool install graphifyy

.PHONY: hermes
hermes:
	curl -fsSL https://raw.githubusercontent.com/NousResearch/hermes-agent/main/scripts/install.sh | bash

.PHONY: multica
multica:
	curl -fsSL https://raw.githubusercontent.com/multica-ai/multica/main/scripts/install.sh | bash

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

.PHONY: understand
understand:
	curl -fsSL https://raw.githubusercontent.com/Lum1104/understand-Anything/main/install.sh | bash

.PHPNY: chorus
chorus:
	@echo "installing chorus..."
	mkdir -p ~/.npm-globals/
	npm install ${NPM_OPT} @chorus-aidlc/chorus

.PHONY: agents
agents:
	curl -fsSL https://raw.githubusercontent.com/darrenhinde/OpenAgentsControl/main/install.sh | bash -s full --install-dir ~/.config/opencode

.PHONY: pi
pi:
	npm install -f ${NPM_OPT} @mariozechner/pi-coding-agent

.PHONY: pi-ext pi-local-extensions pi-rtk-optimizer pi-codemapper pi-fork pi-observational-memory pi-minimal-subagent
pi-ext: pi-rtk-optimizer pi-codemapper pi-fork pi-observational-memory pi-minimal-subagent

pi-observational-memory:
	pi install npm:pi-observational-memory

pi-minimal-subagent:
	pi install git:github.com/elpapi42/pi-minimal-subagent

pi-fork:
	pi install git:github.com/elpapi42/pi-fork

pi-codemapper:
	pipx install git+https://github.com/MikeyBeez/codemapper.git
	pi install git:git@github.com:elpapi42/pi-codemapper.git

pi-rtk-optimizer:
	pi install npm:pi-rtk-optimizer

.PHONY: task-factory
task-factory:
	npm install ${NPM_OPT} task-factory

.PHONY: omp
omp:
	curl -fsSL https://raw.githubusercontent.com/can1357/oh-my-pi/main/scripts/install.sh | sh -s -- --binary

.PHONY: claudecode
claudecode:
	@echo "installing Claude Code..."
	if [ -z "${LITELLM_PROXY_API_KEY}" ]; then
		echo "LITELLM_PROXY_API_KEY is required; set it to the LiteLLM proxy key before configuring Claude Code"
		exit 1
	fi
	if [ -n "${CLAUDE_CODE_INSTALL_ARGS}" ]; then
		curl -fsSL ${CLAUDE_CODE_INSTALL_URL} | bash -s -- ${CLAUDE_CODE_INSTALL_ARGS}
	else
		curl -fsSL ${CLAUDE_CODE_INSTALL_URL} | bash
	fi
	@python_bin=$$(command -v python3 || command -v python)
	if [ -z "$$python_bin" ]; then
		echo "python3 or python is required to configure Claude Code"
		exit 1
	fi
	mkdir -p ${CLAUDE_SETTINGS_DIR}
	printf '%s\n' \
		'import json' \
		'from pathlib import Path' \
		'import sys' \
		'' \
		'settings_path = Path(sys.argv[1]).expanduser()' \
		'proxy_url = sys.argv[2].rstrip("/") or sys.argv[2]' \
		'proxy_api_key = sys.argv[3]' \
		'' \
		'settings = {}' \
		'if settings_path.exists():' \
		'    with settings_path.open() as fh:' \
		'        settings = json.load(fh)' \
		'    if not isinstance(settings, dict):' \
		'        raise SystemExit(f"Expected JSON object in {settings_path}")' \
		'' \
		'env = settings.get("env")' \
		'if env is None:' \
		'    env = {}' \
		'elif not isinstance(env, dict):' \
		'    raise SystemExit(f"Expected ''env'' object in {settings_path}")' \
		'' \
		'env["ANTHROPIC_BASE_URL"] = proxy_url' \
		'env["ANTHROPIC_API_KEY"] = proxy_api_key' \
		'settings["env"] = env' \
		'' \
		'with settings_path.open("w") as fh:' \
		'    json.dump(settings, fh, indent=2)' \
		'    fh.write("\\n")' \
	| "$$python_bin" - "${CLAUDE_SETTINGS_FILE}" "${LITELLM_PROXY_URL}" "${LITELLM_PROXY_API_KEY}"
	echo "Claude Code configured to use LiteLLM at ${LITELLM_PROXY_URL}."
.PHONY: litellm
litellm:
	@echo "installing litellm..."
	@python_bin=$$(command -v python3 || command -v python); \
	if [ -z "$$python_bin" ]; then \
		echo "python3 or python is required to install litellm"; \
		exit 1; \
	fi; \
	if ! "$$python_bin" -c 'import sys; raise SystemExit(0 if sys.version_info >= (3, 9) else 1)'; then \
		echo "Python 3.9+ is required to install litellm"; \
		exit 1; \
	fi; \
	if command -v uv >/dev/null 2>&1; then \
		uv_bin=$$(command -v uv); \
	elif [ -x "$$HOME/.local/bin/uv" ]; then \
		uv_bin="$$HOME/.local/bin/uv"; \
	else \
		curl -LsSf https://astral.sh/uv/install.sh | env UV_NO_MODIFY_PATH=1 sh; \
		uv_bin="$$HOME/.local/bin/uv"; \
	fi; \
	litellm_config="$$HOME/.config/litellm/litellm_config.yaml"; \
	if [ ! -f "$$litellm_config" ]; then \
		echo "LiteLLM config not found at $$litellm_config"; \
		exit 1; \
	fi; \
	mkdir -p "$$HOME/.local/bin" "$$HOME/.config/systemd/user"; \
	litellm_wrapper="$$HOME/.local/bin/litellm"; \
	litellm_bin="$$litellm_wrapper.uv"; \
	rm -f "$$litellm_wrapper" "$$litellm_bin"; \
	"$$uv_bin" tool install --python "$$python_bin" --force 'litellm[proxy]'; \
	if [ ! -x "$$litellm_wrapper" ]; then \
		echo "litellm executable not found at $$litellm_wrapper after installation"; \
		exit 1; \
	fi; \
	mv -f "$$litellm_wrapper" "$$litellm_bin"; \
	printf '%s\n' \
		'#!/usr/bin/env sh' \
		'set -eu' \
		'script_path=$$0' \
		'case "$$script_path" in' \
		'  */*) ;;' \
		'  *) script_path=$$(command -v -- "$$script_path") ;;' \
		'esac' \
		'if [ -n "$${NIX_LD_LIBRARY_PATH:-}" ]; then' \
		'  export LD_LIBRARY_PATH="$${NIX_LD_LIBRARY_PATH}$${LD_LIBRARY_PATH:+:$${LD_LIBRARY_PATH}}"' \
		'elif [ -d /run/current-system/sw/share/nix-ld/lib ]; then' \
		'  export LD_LIBRARY_PATH="/run/current-system/sw/share/nix-ld/lib$${LD_LIBRARY_PATH:+:$${LD_LIBRARY_PATH}}"' \
		'fi' \
		'exec "$${script_path}.uv" "$$@"' > "$$litellm_wrapper"; \
	chmod +x "$$litellm_wrapper"; \
	ln -sf "$(CURDIR)/systemd/litellm.service" "$$HOME/.config/systemd/user/litellm.service"; \
	systemctl --user daemon-reload; \
	systemctl --user enable --now litellm.service; \
	echo "LiteLLM service enabled. Check status with 'systemctl --user status litellm.service'."

.PHONY: omo
omo:
	@echo "installing oh-my-opencode-slim..."
	#bunx oh-my-opencode install
	bunx oh-my-opencode-slim@latest install

.PHONY: clean-tools
clean-tools:
	rm -rf ~/.config/opencode/node_modules

.PHONY: opencode
opencode:
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
