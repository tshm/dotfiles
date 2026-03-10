#!/usr/bin/env zsh

# Source interactive Zsh configuration for aliases and functions
source ~/.dotfiles/zsh/zshrc

files=${(j: :)${(q-)@}}

zle-line-init() {
  BUFFER=" $files"
  CURSOR=0
}
zle -N zle-line-init

typeset cmd
vared -p '$ ' cmd 2>/dev/null || exit 0

if [[ -n ${cmd//[[:space:]]/} ]]; then
  eval "$cmd"
fi
echo "Press any key to continue..."
read < /dev/tty
