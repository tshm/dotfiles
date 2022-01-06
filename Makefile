# initial setup

SRC := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))

PHONY: all shell awesome

all: shell tools

shell: ~/.zinit ~/.nix-profile/bin/nix-env ~/.zshrc ~/.config/direnv/direnvrc

tools: ~/.gitconfig ~/.tmux.conf ~/.vimrc ~/.tridactylrc

$HOME/.config/lvim/config.lua: ~/.dotfiles/lvim.config.lua
	mkdir -p ~/.config/lvim
	ln -s $< $@
	
awesome: ~/.config/awesome/rc.lua
~/.config/awesome/rc.lua: ~/.dotfiles/x/awesome/rc.lua
	mkdir -p ~/.config/awesome
	ln -s $< $@

~/.config/direnv/direnvrc: ~/.dotfiles/zsh/direnvrc
	mkdir -p ~/.config/direnv
	ln -s $< $@

~/.zinit:
	sh -c "$$(curl -fsSL https://git.io/zinit-install)"
	#sh -c "$$(curl -fsSL https://raw.githubusercontent.com/zdharma-continuum/zinit/master/doc/install.sh)"

~/.nix-profile/bin/nix-env:
	curl -L https://nixos.org/nix/install | sh
	echo "source ${HOME}/.nix-profile/etc/profile.d/nix.sh" >> ~/.zshrc

~/.zshrc:
	echo "source ${SRC}/zsh/zshrc" >> $@
	touch ~/.zshrc_local

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
	chmod +x $@
	ln -s $@ ~/bin/e

