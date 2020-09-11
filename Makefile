# initial setup

SRC := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))

PHONY: all

all: ~/.zinit ~/.nix-profile/bin/nix-env ~/.zshrc ~/.gitconfig ~/.tmux.conf ~/.vimrc ~/.tridactylrc

~/.zinit:
	sh -c "$(curl -fsSL https://raw.githubusercontent.com/zdharma/zinit/master/doc/install.sh)"

~/.nix-profile/bin/nix-env:
	curl -L https://nixos.org/nix/install | sh
	echo "source ${HOME}/.nix-profile/etc/profile.d/nix.sh" >> ~/.zshrc

~/.zshrc:
	echo "source ${SRC}/zsh/zshrc" > ~/.zshrc

~/.gitconfig: gitignore
	mkdir -p ~/.config/git
	cp gitignore ~/.config/git/ignore
	echo "[include]"                  > ~/.gitconfig
	echo "  path = ${SRC}/gitconfig" >> ~/.gitconfig

~/.tmux.conf:
	echo "source-file ${SRC}/tmux.conf" > ~/.tmux.conf

~/.vimrc:
	cp ${SRC}/vimrc ~/.vimrc

~/.tridactylrc:
	echo "source ${SRC}/tridactylrc" > ~/.tridactylrc
