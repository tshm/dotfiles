# My Dotfiles

This repository contains my personal collection of configuration files,
also known as dotfiles. It's tailored for my development environment,
primarily using NixOS, but with support for other systems as well.

## Structure

The repository is organized as follows:

- `homes/`: Contains Home Manager configurations for different user environments.
- `hosts/`: Contains NixOS configurations for different machines.
- `k8s/`: Kubernetes configurations and related tools.
- `vim/nvim/`: Neovim configuration.
- `zsh/`: Zsh shell configuration.
- `x/`: X11 and Wayland configurations.
- `flake.nix`: The entry point for the Nix configurations,
  managing dependencies and outputs.
- `Makefile`: Provides convenience targets for setting up and managing the dotfiles.

## Installation

These dotfiles are managed using Nix and Home Manager.

- For NixOS:

  ```bash
  make all
  ```

- For other systems (with Nix installed):

  ```bash
  make home-manager
  ```

The `Makefile` provides other useful targets:

- `make update`: Update all flake inputs.
- `make clean`: Clean up old Nix generations.

## Dependencies

This project uses [Nix Flakes](https://nixos.wiki/wiki/Flakes) to manage dependencies.
The main dependencies are:

- [nixpkgs](https://github.com/Nixos/nixpkgs)
- [home-manager](https://github.com/nix-community/home-manager)
- [catppuccin](https://github.com/catppuccin/nix)

Development dependencies are managed by [pre-commit](https://pre-commit.com/):

- [pre-commit-hooks](https://github.com/pre-commit/pre-commit-hooks)
- [commitizen](https://github.com/commitizen-tools/commitizen)

This repository also uses [Renovate](https://www.mend.io/free-developer-tools/renovate/)
to keep dependencies up to date.

