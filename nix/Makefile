
HOME_MANAGER_DIR := ~/.config/home-manager

PHONY: conf nix
conf: ${HOME_MANAGER_DIR}/base.nix ${HOME_MANAGER_DIR}/home.nix
nix: ~/.nix-profile/bin/nix ~/.nix-profile/bin/home-manager conf

xx:; echo ${HOME_MANAGER_DIR}


~/.nix-profile/bin/nix:
	curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install

${HOME_MANAGER_DIR}/base.nix: base.nix
	cd ${HOME_MANAGER_DIR} && ln -sf ~/.dotfiles/nix/$<

${HOME_MANAGER_DIR}/home.nix: home.nix
	cd ${HOME_MANAGER_DIR} && cp ~/.dotfiles/nix/$< .

BIN := ~/.nix-profile/bin/home-manager
${BIN}: export NIX_PATH=${HOME}/.nix-defexpr/channels:/nix/var/nix/profiles/per-user/root/channels${NIX_PATH:+:$NIX_PATH}
${BIN}: ~/.nix-profile/bin/nix-env
	nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
	nix-channel --update
	nix-shell '<home-manager>' -A install
	home-manager switch

