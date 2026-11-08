# My Dotfiles

This repository contains my personal collection of configuration files,
also known as dotfiles. It's tailored for my development environment,
primarily using NixOS, but with support for other systems as well.

## Structure

The repository is organized as follows:

- `homes/`: Contains Home Manager configurations for different user environments.
 - `hosts/`: Contains NixOS configurations for different machines, including minf, spi, usb, x360, and t440p.
- `k8s/`: Kubernetes configurations and related tools.
- `vim/nvim/`: Neovim configuration.
- `zsh/`: Zsh shell configuration.
- `x/`: X11 and Wayland configurations.
- `flake.nix`: The entry point for the Nix configurations,
  managing dependencies and outputs.
- `Makefile`: Provides convenience targets for setting up and managing the dotfiles.

## Installation

These dotfiles are managed using Nix and Home Manager.
For a complete manual installation from the repository's x86_64 installer ISO, see [`docs/nixos-install-iso.md`](docs/nixos-install-iso.md).

- For NixOS:

  ```bash
  make all
  ```

- For other systems (with Nix installed):

  ```bash
  make home-manager
  ```

After Home Manager activation (`switch`, not just `build`), every home configuration
manages `~/.config/home-manager/flake.nix` as a symlink to
`~/.dotfiles/flake.nix`. Plain `home-manager news`, `build`, and `switch` then
discover this repository and select the configuration by username and hostname;
`--flake` still overrides that default. Keep the checkout at `~/.dotfiles`.

The `Makefile` provides other useful targets:

- `make installer-iso`: Build the shared x86_64 installation ISO in `result-installer/iso/`.

- `make update`: Update all flake inputs.
- `make clean`: Clean up old Nix generations.

## Home backup (`tp`)

`hosts/t440p/default.nix` backs up `/home/tshm` and the root-only USB
key/header directory `/var/lib/usb-cold` to
`sftp:dmz:/tank/bkup` daily at 03:00, with up to 30 minutes of jitter
and catch-up after downtime. No snapshots are automatically deleted.
The root service uses `tshm`'s existing SSH configuration and keys.
Live databases and containers are not quiesced; this is a file-level backup.

The repository password is stored outside Nix at
`/var/lib/restic/home-password` (root-only). Keep a separate secure copy:
losing this file makes the encrypted backups unrecoverable.

```bash
sudo systemctl start restic-backups-home.service
sudo journalctl -u restic-backups-home.service
sudo restic-home snapshots
sudo restic-home check
sudo restic-home restore latest --path /home/tshm --target /tmp/home-restore
```

## Cold USB storage (`tp`)

The USB partition with LUKS UUID `ff5c12c7-d770-4f2d-8a39-0799bd4d0499`
unlocks with `/var/lib/usb-cold/key` and mounts ext4 at `/mnt/cold` on access.
The automount does not require the USB at boot. Its underlying mountpoint
has mode `0000` to prevent user writes to the SSD when unmounted.

Cold data under `/mnt/cold/tshm` retains its original directory paths through
symlinks:

- Hermes snapshot `20260716-215739-pre-update` and Multica backup
  `omp-rollback-dV07cK`: restic snapshot `7b4406d7`, including the LUKS key/header.
- OpenCode's legacy JSON `storage` directory at `opencode-legacy-storage`,
  and Hermes checkpoint `legacy-20260508-192942` under `hermes-checkpoints`:
  restic snapshot `01aebb61`, retaining the original SSD paths.
- `/home/tshm/work/emplus` and `/home/tshm/work/platform` now point to
  `work/emplus` and `work/platform` on USB. Snapshot `0c598ebe` preserves both
  pre-migration trees, including uncommitted and untracked files. After editing
  these projects, explicitly back up their USB paths; the home backup does not
  follow the symlinks.

Keep active work, databases, and application runtimes on SSD. In particular,
OpenCode's current SQLite database remains local. Ordinary home backups do not
follow archive symlinks; these cold archives must remain immutable or receive
an explicit new backup. The regular home job continues backing up the key/header.
Keep the restic repository password separately; losing both the local key
and access to its backup makes the USB unreadable.

Unused SQL Server, Azurite, Memcached, and Alpine image tags are saved in
`container-images/registry-runtimes-20261106.tar`, with every layer digest
verified and a second copy in restic snapshot `366e068d`. No container volumes
were removed. Restore the image tags when needed:
```bash
podman load -i /mnt/cold/tshm/container-images/registry-runtimes-20261106.tar
```

Before unplugging:
```bash
sudo systemctl stop mnt-cold.automount mnt-cold.mount systemd-cryptsetup@cold.service
```
After reconnecting, re-enable on-access mounting:
```bash
sudo systemctl start mnt-cold.automount
```


## Dependencies

This project uses [Nix Flakes](https://nixos.wiki/wiki/Flakes) to manage dependencies.
The main dependencies are:

- [nixpkgs](https://github.com/Nixos/nixpkgs)
- [home-manager](https://github.com/nix-community/home-manager)
- [catppuccin](https://github.com/catppuccin/nix)

Development dependencies are managed by [pre-commit](https://pre-commit.com/):

- [pre-commit-hooks](https://github.com/pre-commit/pre-commit-hooks)
- local Nix syntax checking via `nix-instantiate --parse`
- [commitizen](https://github.com/commitizen-tools/commitizen)

This repository also uses [Renovate](https://www.mend.io/free-developer-tools/renovate/)
to keep dependencies up to date.
