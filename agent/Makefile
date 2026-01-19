
.PHONY: dev
dev: opencode
	@echo "installing oh-my-opencode..."
	bunx oh-my-opencode install
	@echo "installing clavix..."
	mkdir -p ~/.npm-globals/
	npm install -g --prefix ~/.npm-globals/ clavix
	@echo "installing bd..."
	mkdir -p ~/tshm/.local/bin/
	curl -fsSL https://raw.githubusercontent.com/steveyegge/beads/main/scripts/install.sh | bash

.PHONY: clean-tools
clean-tools:
	rm -rf ~/.config/opencode/node_modules

.PHONY: opencode
opencode:
	@echo "installing opencode..."
	opencode --version || curl -fsSL https://opencode.ai/install | bash
	@echo update config
	ln -sf ${PWD}/BASE_AGENTS.md ~/.config/opencode/AGENTS.md
	mkdir -p ~/.config/opencode/config
	for i in ${PWD}/config/*.json; do \
	  ln -sf $$i ~/.config/opencode/config/$$(basename $$i); \
	done
	ln -sf ${PWD}/merge-config.sh ~/.config/opencode
	pushd ~/.config/opencode && ./merge-config.sh ; popd
