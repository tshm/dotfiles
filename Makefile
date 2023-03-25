# initial setup

SRC := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
ISWSL := $(shell uname -a | grep -i microsoft)

PHONY: all shell tools git

all: shell tools
shell: ~/.zshrc ~/bin/e
tools: ~/.tmux.conf git nvim
nix: /usr/local/bin/devbox ~/.nix-profile/bin/home-manager 

~/.tmux.conf:
	echo "source-file ~/.dotfiles/tmux.conf" > $@

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

/usr/local/bin/devbox:
	curl -fsSL https://get.jetpack.io/devbox | bash

~/.nix-profile/bin/nix-env: ~/.config/nixpkgs
	curl -L https://nixos.org/nix/install | sh

~/.config/nixpkgs:
	mkdir -p $@
	cd $@ && { [ -f ./base.nix ] || ln -sf ~/.dotfiles/nix/base.nix; }
	cd $@ && { [ -f ./home.nix ] || cp ~/.dotfiles/nix/home.nix .; }

~/.nix-profile/bin/home-manager: export NIX_PATH=${HOME}/.nix-defexpr/channels:/nix/var/nix/profiles/per-user/root/channels${NIX_PATH:+:$NIX_PATH}
~/.nix-profile/bin/home-manager: ~/.nix-profile/bin/nix-env
	nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
	nix-channel --update
	nix-shell '<home-manager>' -A install
	home-manager switch

~/.zshrc:
	echo 'source ~/.dotfiles/zsh/zshrc' > $@
	mkdir -p ~/bin/

ifdef ISWSL
~/bin/e:
	curl -o $@ https://raw.githubusercontent.com/4U6U57/wsl-open/master/wsl-open.sh
	chmod +x $@
else
~/bin/e:
	which xdg-open && ln -s $$(which xdg-open) $@
endif

