#!/usr/bin/env zsh
[ "$2" ] && {
  DIR=$(zoxide query --list | fzf) || return
  echo -------- open $DIR
  tmux neww -c "$DIR"
  return
}
DIR=$({/bin/ls ~/.dotfiles/proj | egrep -v "sample|$1"| grep '\.sh'; zoxide query --list} | fzf) || return
SN="$(basename $DIR)"
echo -------- start $SN
tmux has -t $SN 2>/dev/null || {
  [ $DIR ] && [ -d $DIR ] && {
    tmux new-session -s "$SN" -c "$DIR" -d
  } || {
    source ~/.dotfiles/proj/${SN}.sh
    tmux select-window -t $SN:0
    tmux select-pane -t 0
  }
}
tmux switch-client -t $SN
