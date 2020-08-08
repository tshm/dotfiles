#!/bin/sh

SRC0=`dirname $0`
SRC=`cd $SRC0; pwd`
cd ~

# zinit
sh -c "$(curl -fsSL https://raw.githubusercontent.com/zdharma/zinit/master/doc/install.sh)"

# brew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"

# zsh
echo "source $SRC/zsh/zshrc" > ~/.zshrc

# gitconfig
echo "[include]"              > ~/.gitconfig
echo "path = $SRC/gitconfig" >> ~/.gitconfig

# tmux
echo "source-file $SRC/tmux.conf" > ~/.tmux.conf

# vimrc
cp $SRC/vimrc ~/.vimrc

# tridactyl
echo "source $SRC/tridactylrc" > ~/.tridactylrc

