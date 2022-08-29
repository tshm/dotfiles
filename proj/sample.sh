#!/bin/sh
cd ~
# 0:root
tmux new-session -s $SN -d
# 1:dotfiles
tmux neww -t $SN:1 -c .dotfiles
tmux send -t $SN:1 'git status' Enter
# 2:ssh
tmux neww -t $SN:2 'autossh -M 20000 spi';
# tmux splitw -t $SN:2 -v -l 50% 'autossh test';
# tmux select-pane -t 0

