# initial setup

SRC := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
ISWSL := $(shell uname -a | grep -i microsoft)

PHONY: all shell tools git nix

all: shell tools
shell: ~/.zshrc
tools: ~/.tmux.conf git nvim

~/.tmux.conf:
	echo "source-file ~/.dotfiles/tmux.conf" > $@

nix:
	cd nix && make

git: ~/.config/git/ignore ~/.gitconfig
~/.config/git/ignore:
	mkdir -p ~/.config/git
	ln -sf gitignore $@

nvim: ~/.local/bin/nvim ~/.config/nvim
~/.local/bin/nvim:
	mkdir -p ~/.local/bin/
	curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim.appimage
	chmod u+x nvim.appimage
	mv nvim.appimage ~/.local/bin/nvim

~/.config/nvim: ./vim/nvim
	mkdir -p ~/.config
	ln -s ~/.dotfiles/vim/nvim $@

~/.gitconfig:
	echo "[include]\n  path = ~/.dotfiles/gitconfig" > $@

~/.zshrc:
	echo 'source ~/.dotfiles/zsh/zshrc' > $@

ifdef ISWSL
~/.local/bin/wsl-open:
	curl -o $@ https://raw.githubusercontent.com/4U6U57/wsl-open/master/wsl-open.sh
	chmod +x $@
endif

resh:
	curl -fsSL https://raw.githubusercontent.com/curusarn/resh/master/scripts/rawinstall.sh | bash

hishtory:
	curl https://hishtory.dev/install.py | python3 -
