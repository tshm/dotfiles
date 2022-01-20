# initial setup

SRC := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))

PHONY: all shell

~/.nix-profile/bin/nix-env:
	curl -L https://nixos.org/nix/install | sh
	echo "source ${HOME}/.nix-profile/etc/profile.d/nix.sh" >> ~/.zshrc

~/.config/i3/config:
	mkdir -p ~/.config/i3
	ln -s x/i3/config $@

~/bin/wsl-open:
	curl -o $@ https://raw.githubusercontent.com/4U6U57/wsl-open/master/wsl-open.sh
	chmod +x $@
	ln -s $@ ~/bin/e

~/.zinit:
	sh -c "$$(curl -fsSL https://git.io/zinit-install)"
