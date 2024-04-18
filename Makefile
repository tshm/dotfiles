# initial setup

SRC := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
ISWSL := $(shell uname -a | grep -i microsoft)

PHONY: all shell tools git nix

all: shell tools
shell: ~/.zshrc wezterm.lua
tools: ~/.tmux.conf git nvim ~/.config/lf/lfrc ~/.config/nnn/plugins ~/.config/mpv/mpv.conf

nix:
	cd nix && make

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

~/.config/lf/lfrc: lfrc
	mkdir -p ~/.config/lf
	ln -s ~/.dotfiles/lfrc $@

~/.config/nvim: ./vim/nvim
	mkdir -p ~/.config
	ln -s ~/.dotfiles/vim/nvim $@

~/.config/mpv/mpv.conf:
	mkdir -p ~/.config/mpv
	cp mpv.conf ~/.config/mpv

~/.gitconfig:
	echo -e "[include]\n  path = ~/.dotfiles/gitconfig" > $@
	echo -e '#[includeIf "gitdir:~/projdir/"]\n#  path = ~/projdir/.gitconfig' >> $@
	echo -e '#[includeIf "hasconfig:remote.*.url::**/github**"]\n#  path = ~/github/.gitconfig' >> $@

~/.zshrc:
	echo 'source ~/.dotfiles/zsh/zshrc' > $@

ifdef ISWSL
~/.local/bin/wsl-open:
	curl -o $@ https://raw.githubusercontent.com/4U6U57/wsl-open/master/wsl-open.sh
	chmod +x $@

wezterm.lua: /u/.wezterm.lua
else
wezterm.lua: ~/.config/wezterm/wezterm.lua
endif

~/.config/wezterm/wezterm.lua:
	mkdir -p ~/.config/wezterm
	cp ~/.dotfiles/wezterm/wezterm.lua $@
/u/.wezterm.lua:
	cp ~/.dotfiles/wezterm/wezterm.lua $@

resh:
	curl -fsSL https://raw.githubusercontent.com/curusarn/resh/master/scripts/rawinstall.sh | bash

hishtory:
	curl https://hishtory.dev/install.py | python3 -

~/.config/nnn/plugins:
	mkdir -p ~/.config/nnn/plugins
	sh -c "$$(curl -Ls https://raw.githubusercontent.com/jarun/nnn/master/plugins/getplugs)"

