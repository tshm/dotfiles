# initial setup

SRC := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
ISWSL := $(shell uname -a | grep Microsoft)

PHONY: all shell tools git

all: shell tools
shell: ~/.nix-profile/bin/home-manager ~/bin/e ~/.zinit
tools: ~/.tmux.conf git

~/.tmux.conf:
	echo "source-file ~/.dotfiles/tmux.conf" > $@

git: ~/.config/git/ignore ~/.gitconfig
~/.config/git/ignore:
	mkdir -p ~/.config/git
	ln -s gitignore $@

~/.gitconfig:
	echo "[include]\n  path = ~/.dotfiles/gitconfig" > $@

# ~/.config/direnv/direnvrc: zsh/direnvrc

~/.nix-profile/bin/nix-env:
	curl -L https://nixos.org/nix/install | sh
	echo "source ${HOME}/.nix-profile/etc/profile.d/nix.sh"
	mkdir -p  ~/.config/nixpkgs
	ln -s home.nix ~/.config/nixpkgs/home.nix

~/.nix-profile/bin/home-manager: export NIX_PATH=${HOME}/.nix-defexpr/channels:/nix/var/nix/profiles/per-user/root/channels${NIX_PATH:+:$NIX_PATH}
~/.nix-profile/bin/home-manager: ~/.nix-profile/bin/nix-env
	nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
	nix-channel --update
	nix-shell '<home-manager>' -A install

~/.zshrc:
	echo 'source ~/.dotfiles/zsh/zshrc' > $@

ifdef ISWSL
~/bin/e:
	curl -o $@ https://raw.githubusercontent.com/4U6U57/wsl-open/master/wsl-open.sh
	chmod +x $@
else
~/bin/e:
	which xdg-open && ln -s $$(which xdg-open) $@
endif

~/.zinit:
	sh -c "$$(curl -fsSL https://git.io/zinit-install)"
