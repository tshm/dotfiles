# initial setup

SRC := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
ISWSL := $(shell uname -a | grep -i microsoft)

PHONY: all shell tools nix

all: shell tools
shell: wezterm.lua ~/.ssh/config
tools: nvim ~/.config/lf/lfrc ~/.config/nnn/plugins ~/.config/mpv/mpv.conf

~/.config/yazi/plugins:
	mkdir -p ~/.config/yazi/plugins
	cd $@ && ln -s ~/.dotfiles/yazi/plugins/tab.yazi
	ya pack -a yazi-rs/plugins:hide-preview

~/.ssh/config:
	mkdir -p ~/.ssh
	chmod 700 ~/.ssh
	echo Include ~/.dotfiles/sshconfig >> ~/.ssh/config
	chmod 600 ~/.ssh/config

nix:
	cd nix && make

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
	ln mpv.conf ~/.config/mpv/mpv.conf

~/.gitconfig:
	echo -e "[include]\n  path = ~/.dotfiles/gitconfig" > $@
	echo -e '#[includeIf "gitdir:~/projdir/"]\n#  path = ~/projdir/.gitconfig' >> $@
	echo -e '#[includeIf "hasconfig:remote.*.url::**/github**"]\n#  path = ~/github/.gitconfig' >> $@

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

