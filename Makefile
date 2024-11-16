# initial setup
SRC := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
ISWSL := $(shell uname -a | grep -i microsoft)
BIN_DIR := /nix/var/nix/profiles/default/bin

all: home-manager

nix: ${BIN_DIR}/nix

${BIN_DIR}/nix:
	@echo non NIXOS
	curl --proto '=https' --tlsv1.2 -sSf \
		-L https://install.determinate.systems/nix | sh -s -- install

home-manager:
	which nh && env FLAKE=$$(realpath .) nh home switch ${UPDATE} || \
	nix run home-manager/master -- switch --flake .

os:
	which nh && env FLAKE=$$(realpath .) nh os switch ${UPDATE} || \
	sudo nixos-rebuild switch --flake .

add-unstable:
	@echo NIXOS
	nix-channel --add https://nixos.org/channels/nixos-unstable nixpkgs
	nix-channel --update

yazi: ~/.config/yazi/plugins/yazi-rs
~/.config/yazi/plugins/yazi-rs:
	ya pack -a yazi-rs/plugins:hide-preview

nvim: ~/.local/bin/nvim ~/.config/nvim
~/.local/bin/nvim:
	mkdir -p ~/.local/bin/
	curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim.appimage
	chmod u+x nvim.appimage
	mv nvim.appimage ~/.local/bin/nvim

resh:
	curl -fsSL https://raw.githubusercontent.com/curusarn/resh/master/scripts/rawinstall.sh | bash

PHONY: all yazi home-manager nix add-unstable
