NIXOS=$(shell which nix | grep run)
HOME_MANAGER_DIR := ~/.config/home-manager
HOME_MANAGER := ~/.nix-profile/bin/home-manager
BIN_DIR := /nix/var/nix/profiles/default/bin

PHONY: nix conf unstable
conf: ${HOME_MANAGER_DIR}/base.nix ${HOME_MANAGER_DIR}/home.nix
nix: ${BIN_DIR}/nix ${HOME_MANAGER} conf

ifdef NIXOS
all: unstable
else
all: nix conf
endif

unstable:
	nix-channel --add https://nixos.org/channels/nixpkgs-unstable nixpkgs
	nix-channel --add \
		https://github.com/nix-community/home-manager/archive/master.tar.gz \
		home-manager;
	nix-channel --update;
	nix-shell '<home-manager>' -A install;
	home-manager switch;

${BIN_DIR}/nix:
	curl --proto '=https' --tlsv1.2 -sSf \
		-L https://install.determinate.systems/nix | sh -s -- install
	. /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh && { \
		nix-channel --add https://nixos.org/channels/nixpkgs-unstable nixpkgs \
		nix-channel --update; \
	}

${HOME_MANAGER_DIR}/base.nix: base.nix
	mkdir -p ${HOME_MANAGER_DIR} && cd ${HOME_MANAGER_DIR} && ln -sf ~/.dotfiles/nix/$<

${HOME_MANAGER_DIR}/home.nix: home.nix
	mkdir -p ${HOME_MANAGER_DIR} && cd ${HOME_MANAGER_DIR} && cp ~/.dotfiles/nix/$< .

BKUP${HOME_MANAGER}: ${BIN_DIR}/nix conf
	. /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh && { \
		nix run home-manager/master -- init; \
		home-manager switch --impure; \
	}

${HOME_MANAGER}: ${BIN_DIR}/nix conf
	. /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh && { \
		nix-channel --add \
		  https://github.com/nix-community/home-manager/archive/master.tar.gz \
			home-manager; \
		nix-channel --update; \
		nix-shell '<home-manager>' -A install; \
		home-manager switch; \
	}

