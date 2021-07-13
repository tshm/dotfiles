# initial setup

SRC := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))

PHONY: all shell

all: shell tools

shell: ~/.zinit ~/.nix-profile/bin/nix-env ~/.zshrc

tools: ~/.gitconfig ~/.tmux.conf ~/.vimrc ~/.tridactylrc
 
~/.zinit:
	sh -c "$(curl -fsSL https://raw.githubusercontent.com/zdharma/zinit/master/doc/install.sh)"

~/.nix-profile/bin/nix-env:
	curl -L https://nixos.org/nix/install | sh
	echo "source ${HOME}/.nix-profile/etc/profile.d/nix.sh" >> ~/.zshrc

~/.zshrc:
	echo "source ${SRC}/zsh/zshrc" >> $@

~/.zlogin:
	echo "source ${SRC}/zsh/zlogin" > $@

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

~/.config/i3/config:
	mkdir -p ~/.config/i3
	ln -s x/i3/config $@

~/bin/wsl-open:
	curl -o $@ https://raw.githubusercontent.com/4U6U57/wsl-open/master/wsl-open.sh
