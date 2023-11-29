
HOME_MANAGER_DIR := ~/.config/home-manager
HOME_MANAGER := ~/.nix-profile/bin/home-manager
BIN_DIR := /nix/var/nix/profiles/default/bin

PHONY: conf nix
conf: ${HOME_MANAGER_DIR}/base.nix ${HOME_MANAGER_DIR}/home.nix
nix: ${BIN_DIR}/nix ${HOME_MANAGER} conf

${BIN_DIR}/nix:
	sh <(curl -L https://nixos.org/nix/install) --daemon

${HOME_MANAGER_DIR}/base.nix: base.nix
	cd ${HOME_MANAGER_DIR} && ln -sf ~/.dotfiles/nix/$<

${HOME_MANAGER_DIR}/home.nix: home.nix
	cd ${HOME_MANAGER_DIR} && cp ~/.dotfiles/nix/$< .

${HOME_MANAGER}: ${BIN_DIR}/nix
	nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
	nix-channel --update
	nix-shell '<home-manager>' -A install
	home-manager switch

