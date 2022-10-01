# initial setup

SRC := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
ISWSL := $(shell uname -a | grep -i microsoft)

PHONY: all shell tools git

all: shell tools
shell: ~/.zshrc ~/.nix-profile/bin/home-manager ~/bin/e
tools: ~/.tmux.conf git nvim

~/.tmux.conf:
	echo "source-file ~/.dotfiles/tmux.conf" > $@

git: ~/.config/git/ignore ~/.gitconfig
~/.config/git/ignore:
	mkdir -p ~/.config/git
	ln -s gitignore $@

nvim: ~/.config/nvim ~/.config/nvim/lua/user/init.lua
~/.config/nvim:
	git clone https://github.com/AstroNvim/AstroNvim $@

~/.config/nvim/lua/user/init.lua:
	mkdir -p ~/.config/nvim/lua/user
	cd ~/.config/nvim/lua/user && ln -s ~/.dotfiles/vim/astrovim.init.lua $@
	nvim +PackerSync

~/.gitconfig:
	echo "[include]\n  path = ~/.dotfiles/gitconfig" > $@

# ~/.config/direnv/direnvrc: zsh/direnvrc

~/.nix-profile/bin/nix-env:
	curl -L https://nixos.org/nix/install | sh
	mkdir -p  ~/.config/nixpkgs
	[ -f ~/.config/nixpkgs/home.nix ] || ln -s home.nix ~/.config/nixpkgs/home.nix

~/.nix-profile/bin/home-manager: export NIX_PATH=${HOME}/.nix-defexpr/channels:/nix/var/nix/profiles/per-user/root/channels${NIX_PATH:+:$NIX_PATH}
~/.nix-profile/bin/home-manager: ~/.nix-profile/bin/nix-env
	nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
	nix-channel --update
	nix-shell '<home-manager>' -A install

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

