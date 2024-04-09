
HOME_MANAGER_DIR := ~/.config/home-manager
HOME_MANAGER := ~/.nix-profile/bin/home-manager
BIN_DIR := /nix/var/nix/profiles/default/bin
DIRENV := ~/.config/direnv/lib/local.sh

all: nix conf ${DIRENV}

PHONY: nix conf
conf: ${HOME_MANAGER_DIR}/base.nix ${HOME_MANAGER_DIR}/home.nix
nix: ${BIN_DIR}/nix ${HOME_MANAGER} conf

${BIN_DIR}/nix:
	curl --proto '=https' --tlsv1.2 -sSf \
		-L https://install.determinate.systems/nix | sh -s -- install
	. /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh && { \
		nix-channel --add https://nixos.org/channels/nixpkgs-unstable nixpkgs \
		nix-channel --update; \
	}

${HOME_MANAGER_DIR}/base.nix: base.nix
	cd ${HOME_MANAGER_DIR} && ln -sf ~/.dotfiles/nix/$<

${HOME_MANAGER_DIR}/home.nix: home.nix
	cd ${HOME_MANAGER_DIR} && cp ~/.dotfiles/nix/$< .

${HOME_MANAGER}: ${BIN_DIR}/nix conf
	. /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh && { \
		nix run home-manager/master -- init; \
		home-manager switch --impure; \
	}

BKUP${HOME_MANAGER}: ${BIN_DIR}/nix conf
	. /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh && { \
		nix-channel --add \
		  https://github.com/nix-community/home-manager/archive/master.tar.gz \
			home-manager; \
		nix-channel --update; \
		nix-shell '<home-manager>' -A install; \
		home-manager switch; \
	}

${DIRENV}:
	mkdir -p ~/.config/direnv/lib
	echo source_env_if_exists .local.envrc > $@
