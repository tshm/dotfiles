# initial setup

SRC := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
ISWSL := $(shell uname -a | grep -i microsoft)

PHONY: all home-manager

all: ~/.config/yazi/plugins/yazi-rs home-manager

home-manager:
	nix run home-manager/master -- switch --flake .

~/.config/yazi/plugins/yazi-rs:
	ya pack -a yazi-rs/plugins:hide-preview

nix:
	cd nix && make

nvim: ~/.local/bin/nvim ~/.config/nvim
~/.local/bin/nvim:
	mkdir -p ~/.local/bin/
	curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim.appimage
	chmod u+x nvim.appimage
	mv nvim.appimage ~/.local/bin/nvim

~/.config/nvim: ./vim/nvim
	mkdir -p ~/.config
	ln -s ~/.dotfiles/vim/nvim $@

resh:
	curl -fsSL https://raw.githubusercontent.com/curusarn/resh/master/scripts/rawinstall.sh | bash

~/.config/nnn/plugins:
	mkdir -p ~/.config/nnn/plugins
	sh -c "$$(curl -Ls https://raw.githubusercontent.com/jarun/nnn/master/plugins/getplugs)"

