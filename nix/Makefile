BIN_DIR := /nix/var/nix/profiles/default/bin

nix: ${BIN_DIR}/nix

nixos:
	nix-channel --add https://github.com/NixOS/nixos-hardware/archive/master.tar.gz nixos-hardware
	nix-channel --update
	pushd /etc/nixos && \
		mv configuration.nix _bkup.nix && \
		ln -s ~/.dotfiles/nix/baseos.nix && \
		cp ~/.dotfiles/nix/configuration.nix .

unstable:
	@echo NIXOS
	nix-channel --add https://nixos.org/channels/nixos-unstable nixpkgs
	nix-channel --update

${BIN_DIR}/nix:
	@echo non NIXOS
	curl --proto '=https' --tlsv1.2 -sSf \
		-L https://install.determinate.systems/nix | sh -s -- install

PHONY: nix unstable
