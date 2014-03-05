#!/bin/sh

SRC0=`dirname $0`
SRC=`cd $SRC0; pwd`

cd ~
# create symlinks
for i in \
  "gitconfig" \
  "tmux.conf" \
  ; do
  ln -s $SRC/$i .$i
done

# gvim-win does not support symlinks
# so inverse the sourcing direction.
cp $SRC/vimrc ~/.vimrc

