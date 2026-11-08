# Changelog

All notable changes to this project will be documented in this file.

## [Unreleased]

### Added

- _(t440p)_ Add encrypted, on-access USB archive storage with protected unlock-key backups and verified symlink migration of inactive backups.
- _(nix)_ Add a manually started Btrfs migration USB with encrypted SMB-backed restic backups, pre-erase verification, stable disk identity checks, offline NixOS installation, and non-formatting recovery.
- _(minf)_ Install TwinDesk through its official Nix flake and NixOS module, with Wayland mouse/keyboard input permissions and connection/discovery firewall ports; keep Wi-Fi Direct privileges disabled.
- _(home-manager)_ Manage the default flake symlink on every home configuration so commands discover the repository without `--flake` after activation.
- _(waybar)_ Show the current Mango layout's full name and `Super+Space` cycle shortcut in the layout indicator tooltip.
- _(nix)_ Add the shared x86_64 minimal installer, `make installer-iso`, and a README-linked manual installation guide covering disk selection, host hardware configuration, first-boot secrets, and Home Manager.

### Changed

- _(nixos)_ Default to weekly SSD TRIM in the shared host configuration with `lib.mkDefault`, allowing per-host overrides.
- _(twindesk)_ Follow the upstream default branch on `nix flake update` instead of pinning a release tag; `flake.lock` still records the exact revision for reproducible builds.
- _(topgrade)_ Remove custom OpenCode and Hermes update commands already covered by built-in steps; retain the omp and Devbox commands.
- _(t440p)_ Remove the Orca system user and group declarations.
- _(speakoflow)_ Manage the Japanese editing cleanup prompt from a tracked text file, applying it before desktop startup with a 30-second cleanup timeout.
- _(speakoflow)_ Bump SpeakoFlow from 2.0.0 to 2.0.1 with the matching AppImage hash
- _(minf)_ Restrict fingerprint authentication to local login and restore passwordless sudo; disable fingerprint prompts for desktop authorization and screen lockers.
- _(bluetooth)_ Reconnect paired, trusted keyboards after desktop suspend/resume without restarting Bluetooth or disturbing connected devices.

### Fixed

- _(speakoflow)_ Include `libgpg-error` in the AppImage runtime so SpeakoFlow 2.2.0 launches instead of exiting with a missing shared library.
- _(x360)_ Restore the saved WirePlumber sound-card profile to Analog Stereo Duplex; output-only mode disabled the internal microphone and caused SpeakoFlow dictation to stop immediately.
- _(wayland)_ Launch ordered startup applications as Mango children through IPC, keeping Beeper alive after the startup script exits; retain shell waiting for Niri and other background applications using Nix FHS wrappers with `--die-with-parent`.
- _(home-manager)_ Remove the unused AGS package, which is no longer available in nixpkgs and prevented GUI home configurations from evaluating.
- _(x360)_ Blacklist the tiny ACPI power-button driver, which bypassed logind and triggered immediate shutdown when waking from suspend.
- _(home-manager)_ Keep non-NixOS GPU integration off on NixOS hosts and explicitly preserve Nushell's existing session-variable behavior, removing activation and evaluation warnings from `make`.
- _(mango)_ Make `Super+R` leave maximized/fullscreen mode before cycling the scroller width preset.
- _(mango)_ Allow Beeper notification activation requests to focus its window on tag 2 while preserving silent startup and other applications' focus protection
- - (x360) Blacklist the tiny ACPI power-button driver, which bypassed logind and triggered immediate shutdown when waking from suspend
- _(wayland)_ Launch ordered startup applications as Mango children through IPC, keeping Beeper alive after the startup script exits; retain shell waiting for Niri and other background applications using Nix FHS wrappers with `--die-with-parent`
- _(home-manager)_ Remove the unused AGS package, which is no longer available in nixpkgs and prevented GUI home configurations from evaluating
- _(wayland)_ Launch ordered startup applications as Mango children through IPC, keeping Beeper alive after the startup script exits; retain shell waiting for Niri and other background applications using Nix FHS wrappers with `--die-with-parent`.
- _(home-manager)_ Remove the unused AGS package, which is no longer available in nixpkgs and prevented GUI home configurations from evaluating.
- _(x360)_ Blacklist the tiny ACPI power-button driver, which bypassed logind and triggered immediate shutdown when waking from suspend.
- _(home-manager)_ Keep non-NixOS GPU integration off on NixOS hosts and explicitly preserve Nushell's existing session-variable behavior, removing activation and evaluation warnings from `make`.
- _(mango)_ Make `Super+R` leave maximized/fullscreen mode before cycling the scroller width preset.
- _(mango)_ Allow Beeper notification activation requests to focus its window on tag 2 while preserving silent startup and other applications' focus protection
- - (x360) Blacklist the tiny ACPI power-button driver, which bypassed logind and triggered immediate shutdown when waking from suspend
- _(wayland)_ Launch ordered startup applications as Mango children through IPC, keeping Beeper alive after the startup script exits; retain shell waiting for Niri and other background applications using Nix FHS wrappers with `--die-with-parent`

- # _(home-manager)_ Remove the unused AGS package, which is no longer available in nixpkgs and prevented GUI home configurations from evaluating

- _(wayland)_ Launch ordered startup applications as Mango children through IPC, keeping Beeper alive after the startup script exits; retain shell waiting for Niri and other background applications using Nix FHS wrappers with `--die-with-parent`.
- _(home-manager)_ Remove the unused AGS package, which is no longer available in nixpkgs and prevented GUI home configurations from evaluating.
- _(t440p)_ Preserve the existing TS3 backup-share automount's boot enablement when rebuilding the private host configuration.
- _(x360)_ Blacklist the tiny ACPI power-button driver, which bypassed logind and triggered immediate shutdown when waking from suspend.
- _(home-manager)_ Keep non-NixOS GPU integration off on NixOS hosts and explicitly preserve Nushell's existing session-variable behavior, removing activation and evaluation warnings from `make`.
- _(mango)_ Make `Super+R` leave maximized/fullscreen mode before cycling the scroller width preset.
- _(mango)_ Allow Beeper notification activation requests to focus its window on tag 2 while preserving silent startup and other applications' focus protection
- - (x360) Blacklist the tiny ACPI power-button driver, which bypassed logind and triggered immediate shutdown when waking from suspend
- _(wayland)_ Launch ordered startup applications as Mango children through IPC, keeping Beeper alive after the startup script exits; retain shell waiting for Niri and other background applications using Nix FHS wrappers with `--die-with-parent`
- _(home-manager)_ Remove the unused AGS package, which is no longer available in nixpkgs and prevented GUI home configurations from evaluating

## [1.2.0] - 2025-02-27

### 🚀 Features

- _(gitconfigf)_ Auto update refs in rebase

### 🐛 Bug Fixes

- _(git)_ Bump explicitly fail when dirty
- _(kanata)_ Remove shift map
- _(nix)_ Use localias
- _(tmux)_ Disable mouse

### ⚙️ Miscellaneous Tasks

- Update
- Update
- Bump version
- Use git-cliff
- Bump version

## [1.1.0] - 2025-02-14

### 🚀 Features

- _(util)_ Add utility rofi script
- _(k8s)_ Add proxmox sample

### 🐛 Bug Fixes

- _(zsh)_ Add neovide
- _(nix)_ Enable iio
- _(direnv)_ Add alias hack
- _(gui)_ Add sleep cmd
- _(nh)_ Broken beeper use x11 mode
- _(hm)_ Alias hack
- _(git)_ Keep gitignore for windows usage
- _(nh)_ Disable nh service
- _(kanata)_ Setup for wsl setup
- Lazyvim use fzf
- Missed sudo rule
- _(gui)_ Support hyprshade
- _(git)_ Install pre-commit hook via envrc
- _(gui)_ Allow overwrap
- _(kanata)_ Add caps keymap
- _(kanata)_ Experiment space -> alt mapping
- _(yazi)_ Allow kj to warp
- _(yaxi)_ Update new plugin
- _(git)_ Verbump support

### ⚙️ Miscellaneous Tasks

- _(nh)_ Update
- Update flake
- Flake update
- Add kanata
- Update
- Add pre-commit hook
- _(nix)_ Update
- _(nix)_ Update
- Update
- Update
- Update flake
- Update pre-commit
- Update flake
- Update
- Bump version

## [1.0.0] - 2024-12-03

### 🚀 Features

- Tmux nested session
- _(lf)_ Add lfrc
- _(tmux)_ Session switcher
- _(backup)_ Backup script
- _(nvim)_ Autochdir for telescope relative
- _(neovim)_ Use Neogit
- _(neovim)_ Add yanky
- _(k9s)_ Add shortcuts
- _(nix)_ Use flake for hm

### 🐛 Bug Fixes

- _(k8s)_ Update version
- Remove bin/e
- _(nix)_ Fix path
- _(nix)_ Add default direnv
- Use nix-installer
- Use resh
- Add zt cmd
- Nnn pager
- _(zsh)_ Add zz compl
- Disable leap
- _(git)_ Remove git abort
- Add scr alias
- Wezterm
- _(wezterm)_ Mkdir config dir
- Colorscheme
- _(nnn)_ Use nnn
- _(nvim)_ Disable flash
- _(tig)_ Add diff shortcut
- _(nnn)_ Use plugins
- Remove nix-env --install
- Fzf completion
- _(nix)_ Installation
- _(wsl)_ Add config
- _(wsl)_ Add swap=0
- Ff better line handling
- _(git)_ Fix search alias
- _(zsh)_ Expand aliases
- _(zsh)_ Use whence instead of which
- _(topgrade)_ Add zinit updater
- _(git)_ Add rerere
- _(git)_ Use explicit option
- _(tmux)_ Splitw uses -h flag now
- _(terraform)_ Update
- _(git)_ Adjust config
- _(nix)_ Use flake installer
- _(git)_ Makefile
- _(nix)_ Use yazi
- Add mpv conf
- _(nix)_ Use ctpv
- _(nix)_ Handle tmux from home-manager
- Remove tmux.conf
- _(zsh)_ Escape fix
- _(tmux)_ Mark sessions
- Home manager switch
- _(git)_ Nuke
- Suport waylant
- _(nix)_ Typo
- Use atuin
- Sshconfig
- _(zsh)_ Adjust path of clip
- Mpv conf
- _(wezterm)_ Add mouse binding
- Add hyprland config
- _(zsh)_ Use mcfly for now
- _(hyprland)_ Master switch
- _(nix)_ Enable unfree apps
- _(tmux)_ Bind C-k for popup
- _(home-manager)_ Use topgrade
- _(hyprland)_ Add waybar
- _(zsh)_ Use atuin
- _(hyprland)_ Add media keys
- _(tmux)_ Bind g
- _(yazi)_ Use yazi plugins
- _(home-manager)_ Configure git
- Use git cliff
- _(nix)_ Remove mime type
- Cleanup
- _(zsh)_ Scptar
- _(nix)_ Manage more conf files in hm
- _(hyprland)_ Manage config via homemanager
- Adjust for nixos
- Add waybar into hm
- _(yazi)_ Handle custom plugin in hm
- Add beeper
- _(waybar)_ Power menu
- _(nix)_ IME support
- _(nix)_ Integrate with nix-index-database
- _(hypr)_ Adjust icons
- _(nix)_ Symlink fonts for flatpak apps
- _(hypr)_ Adjust layout
- _(nix)_ Powerbutton
- _(hyprland)_ Fix low contrast theme
- _(nix)_ Use nixos-hardware
- _(nixos)_ Enable flake
- _(home-manager)_ Split host based config
- _(nix)_ Add pi
- _(gui)_ Waybar toggling
- _(hm)_ Use symlink
- _(x)_ Adjust IME config
- _(x)_ Use zen-browser via flake
- _(home)_ Add nh
- _(hm)_ Split dev dependency
- _(nix)_ Support hibernation
- _(hm)_ Add gui tools
- _(nix)_ Use flake
- _(hyprland)_ Add screenshot
- _(tmux)_ Use sensible plugin
- _(nixos)_ Split gui out of base
- _(hm)_ Add carapace
- _(nix)_ Cleanup
- _(nix)_ Use realpath for avoiding symlinks
- _(nix)_ Update hw
- _(nvim)_ Update
- _(gui)_ Use cursor for now
- _(hm)_ Update flake
- _(hm)_ Add onefetch
- _(vim)_ Update
- _(zsh)_ Completion problem
- _(nix)_ Refactor
- _(hyprland)_ Add hyprswitch
- _(fzf)_ Add zsh binding
- _(nix)_ Cleanup
- _(mpv)_ Put config in nix
- _(gui)_ Use swaync
- _(hm)_ Add info
- Update info.sh
- Update aliases
- _(nix)_ Restruct
- Update aliases
- _(nix)_ Use db
- _(nix)_ Mime
- _(hm)_ Integrate atuin
- _(nix)_ Install feh
- _(nix)_ Update flake
- _(tmux)_ Use mouse input
- _(nix)_ Update flake
- _(hypr)_ Adjust sensitivity
- _(hm)_ Theming up
- _(tmux)_ Adjust color
- _(hm)_ Simplify Makefile
- _(nixos)_ Add terminal login session
- _(hm)_ Add PN0093

### 💼 Other

- Use git-absorb
- Use loginExtra
- Manage nixos config here

### ⚙️ Miscellaneous Tasks

- Remove old aliases
- Use mcfly
- Use fzf for interactive grep
- Update lazy.nvim
- Update nvim

## [1.0] - 2023-10-24

### 🚀 Features

- Add alias for git flow
- Add rebasex alias
- Use tmux plugins
- _(zsh)_ Use fasd
- Add rakuten search shortcut
- Allow env to set editor
- Use smug
- _(direnv)_ Context sensitive history
- _(direnv)_ Custom script support
- Use zdhama-continuum
- Add lunarvim config
- _(git)_ Add vimdiff rules
- Add awesome task
- Use mcfly
- _(k8s)_ Add base scripts and manifests
- _(nvim)_ Use astronvim
- _(devbox)_ Use devbox
- _(zsh)_ Paste clipb into buffer
- Add zz cmd
- _(zsh)_ Define zz alias
- _(zsh)_ Reuse original \_files comp

### 🐛 Bug Fixes

- Source script path
- Bindkey order
- Check zero length
- Replace some vim plugins
- Folder test
- Set base binding in the beginning
- Add alias to update nix
- Use nvim for nvim replacement
- Syntax cleanup
- Use nix for now
- Git nuke remove remote first
- Use nvim as default
- Refactor makefile
- Remove nvm
- Bit loading
- Remove undo alias
- _(zsh)_ Use zlogin
- _(zsh)_ Avoid overwrite
- _(tmux)_ Style
- _(git)_ Use gitignore explicitly
- _(tmux)_ Rename within precmd
- _(zsh)_ Nix gc
- Escape for feedly.com
- _(tridactyl)_ Hint for google
- _(git)_ Add nuke alias
- Google search result binding
- Use rebasex alias
- _(tridactyl)_ Reset every config load
- Remap
- Cleanup aliases
- Remove youtube shortcut
- Adapt google page change
- Path to exa
- Adjust for using neovim / vscode
- _(apt)_ Autoclean
- Add nnn
- Use ugit
- Add vscode integration
- _(git)_ Add message templates
- _(wsl)_ Use wsl-open if needed
- _(i3)_ Update config
- Split makefile tasks
- Adjust key bindgins
- Add memory viz tool
- _(i3/awesome)_ Update config
- _(zinit)_ Make sure to get right file
- Use fuzzy mcfly search
- _(awesome)_ Add applets
- _(zinit)_ Pick right watchexec archive
- Better google links handling
- Escape s for feedly
- Use alt-space for marking
- Shortcut keys
- Add shortcut for compare view
- Nnn configs
- Update path of config
- Zsh startup time optmization
- Add fzf util
- Remove nnn detection
- Remove IME control
- Remove xh
- Set hint keys for habitica
- Handle x startup
- Make focus shortcut
- Aliases
- Use direnv instead of dotenv
- Support backlight shortcuts
- Add more quickmarks
- Revert for broot installation
- No mcfly
- Use asdf/direnv plugins
- Use tmxu-resurrect
- Add tmux-thumbs
- _(zsh)_ Use zdharma-continuum for now
- Add broot execution cmd
- _(tmux)_ Add switch-client bindings
- Add smug shortcut
- _(zinit)_ Initialization
- Installer
- Zsh alias
- Disable autocrlf
- Update aliases
- Circumvent smug crash
- Cleanup dotbot
- _(zsh)_ Add nix profile
- _(fzf)_ Add keybinding
- _(fzf-tab)_ Add key binding
- _(nix)_ Use home-manager 20.05
- Use simple makefile for initialization
- Add sample tmux script
- Use custom tmux scripts
- Update sample.sh
- Adjust Makefile
- Attach proj_tmux after creation
- _(zsh)_ Use atuin
- _(zsh)_ Remove atuin integration
- _(nvim)_ Use astronvim for now
- _(vim)_ Link
- _(git)_ Enable followTags
- _(zsh)_ Use lessfilter
- _(nvim)_ Sync with upstream userconfig
- _(nvim)_ Sync with upstream userconfig
- +x lessfilter
- _(nvim)_ Awesome bindings lua
- _(awesome)_ Switch master
- _(awesome)_ S+Return
- _(zsh)_ Tm autocomplete
- _(vim)_ Use fugitive
- _(vim)_ Use leap
- _(vim)_ Use tabnine in x86
- _(awesome)_ Use quakedd
- _(nix)_ Homemanager verup
- _(nix)_ Use devenv
- _(alias)_ Maintain
- _(nvim)_ Use stable channel
- _(tmux)_ Configure extracto
- _(zsh)_ Cleanup aliases
- _(neovim)_ Use Codeium
- _(tmux)_ Use extrakto
- _(zsh)_ Performance tweak
- Use zoxide
- _(vim)_ Use appimage neovim
- _(home-manager)_ Templating home.nix
- _(zshrc)_ Silence setup
- _(direnv)_ Remove debvox integn
- _(zsh)_ Add recursive completion
- _(zsh)_ Hightlight plugin before compinit
- Add tig config
- _(zsh)_ Improve file completion
- _(zsh)_ Bind fzf key
- _(zsh)_ Zz completion
- _(zsh)_ Set batman
- _(nix)_ Generation cleanup
- _(nix)_ Use new installer
- _(nix)_ Use nix topgrade
- _(tmux)_ Disable mouse
- _(zsh)_ Remove recursive file complete
- _(zsh)_ Use deer
- _(nix)_ Refactor
- _(tmux)_ Default layout
- _(nix)_ Load home-manager sessionvars
- _(git)_ Use renormalize strategy
- _(nix)_ Fix nix installation
- _(vim)_ Disable autoformat

### 💼 Other

- Local config inclusion
- Local config inclusion
- Add quote func / refactor cmd stack
- Use unite-session for default
- Use unite-gitlsfiles
- Wrong quotation
- Wrong passkey format
- 0prev should not be kept as v:this_session, use old copy instead.
- Fzf handling
- Key collision
- Support clipboard access via unite.
- Wrap/list toggle unite cmd
- Bind history-search
- Use 256 color
- Avoid unnesessary compinit
- Sanitize config everytime
- Make --prune default
- Zplugin -> zinit
- Update plugins
- Add docker cleanup script
- Adjust hint mode for google
- Use bit
- Put installer

### 🚜 Refactor

- _(zsh)_ Cleanup

### ⚙️ Miscellaneous Tasks

- Use broot, etc
- Use dotbot
- Cleanup old files
- Use lazyvim
- Cleanup
- Refactor
- Update home-manager
- _(nvim)_ Use codeium.nvim

<!-- generated by git-cliff -->
