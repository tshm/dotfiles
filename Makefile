# initial setup
ISNIXOS:=$(shell grep ID=nixos /etc/os-release)
NIX:=$(shell which nix)

home-manager: nix
	which nh && nh home switch || \
	nix run home-manager/master -- switch --flake .

ifdef NIX
nix:; @echo nix exists
else
nix:
	@echo no nix
	curl --proto '=https' --tlsv1.2 -sSf \
		-L https://install.determinate.systems/nix | sh -s -- install
endif

sudo:
	@sudo echo

ifdef ISNIXOS
all: sudo home-manager os
else
all: home-manager
endif

os: sudo
	which nh && nh os switch || \
	sudo nixos-rebuild switch --flake .

update:
	nix flake update

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

PHONY: all yazi home-manager nix update
