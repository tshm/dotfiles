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
	echo "source ${SRC}/zsh/zshrc" > $@

~/.gitconfig:
	mkdir -p ~/.config/git
	cp gitignore ~/.config/git/ignore
	echo "[include]"                  > $@
	echo "  path = ${SRC}/gitconfig" >> $@

~/.tmux.conf:
	echo "source-file ${SRC}/tmux.conf" > $@

~/.vimrc:
	cp ${SRC}/vimrc $@

~/.tridactylrc:
	echo "source ${SRC}/tridactylrc" > $@
