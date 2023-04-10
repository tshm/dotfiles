
PHONY: conf nix
conf: ~/.config/home-manager/base.nix ~/.config/home-manager/home.nix
nix: /usr/local/bin/devbox ~/.nix-profile/bin/home-manager conf

HOME_MANAGER_DIR := ~/.config/home-manager

/usr/local/bin/devbox:
	(which devbox >/dev/null) || curl -fsSL https://get.jetpack.io/devbox | bash

~/.config/home-manager/base.nix: base.nix
	cd HOME_MANAGER_DIR && ln -sf ~/.dotfiles/nix/$<

~/.config/home-manager/home.nix: home.nix
	cd HOME_MANAGER_DIR && cp ~/.dotfiles/nix/$< .

~/.nix-profile/bin/home-manager: export NIX_PATH=${HOME}/.nix-defexpr/channels:/nix/var/nix/profiles/per-user/root/channels${NIX_PATH:+:$NIX_PATH}
~/.nix-profile/bin/home-manager: ~/.nix-profile/bin/nix-env
	nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
	nix-channel --update
	nix-shell '<home-manager>' -A install
	home-manager switch

