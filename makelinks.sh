#!/bin/sh

SRC0=`dirname $0`
SRC=`cd $SRC0; pwd`
cd ~

# config.fish
mkdir -p ~/.config/fish/
echo "source $SRC/config.fish" > ~/.config/fish/config.fish

# gitconfig
echo "[include]"              > ~/.gitconfig
echo "path = $SRC/gitconfig" >> ~/.gitconfig

# tmux
echo "source-file $SRC/tmux.conf" > ~/.tmux.conf

# vimrc
cp $SRC/vimrc ~/.vimrc

# vimperator
echo "source $SRC/vimperatorrc" > ~/.vimperatorrc

