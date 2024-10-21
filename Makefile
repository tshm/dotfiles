# initial setup

SRC := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
ISWSL := $(shell uname -a | grep -i microsoft)

PHONY: all shell tools nix

all: ~/.config/yazi/plugins

~/.config/yazi/plugins:
	mkdir -p ~/.config/yazi/plugins
	cd $@ && ln -s ~/.dotfiles/yazi/plugins/tab.yazi
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

