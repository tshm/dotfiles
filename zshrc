#-*-shell-script-*-
# vim: ft=zsh
export RSYNC_RSH='ssh'
export EDITOR=vim
export VISUAL=vim
#export NNTPSERVER=nntp.stanford.edu
export PAGER='less'
export LESS='--quit-if-one-screen -R -iMX'
export LS_COLORS='di=32:ln=36:pi=31:so=33:bd=44;37:cd=44;37:ex=35'
export WORDCHARS=${WORDCHARS:s|/||}

HISTSIZE=5100
HISTFILE=~/.zsh_history
SAVEHIST=5000
DIRSTACKSIZE=15
fignore=('~' .bak)
hash -d 'D=/usr/share/doc'

alias pstree='pstree -A'
alias aumix='LANG= aumix'
alias sudo='LANG= sudo'
alias octave='octave --traditional'
alias mv='nocorrect mv'       # no spelling correction on mv
alias cp='nocorrect cp'       # no spelling correction on cp
alias ls='ls --color=auto -F'
alias dir='ls -l -h'
alias rm='rm -i'
alias ww='w3m -B'
alias scala='rlwrap scala -Xnojline'

PROMPT_COLOR="green"
PROMPT="%F{$PROMPT_COLOR}-[%m:%~]---------------------%f
%# "
RPROMPT=`print -n '%{\033[1;33m%}(%T)%b%{\033[0m%}'`

preexec () {
  echo -ne "\ek${1%% *}\e\\"
}

setopt   notify globdots correct cdablevars automenu autolist
setopt   correctall noautocd recexact longlistjobs sharehistory
setopt   autoresume histignoredups noclobber histfindnodups
setopt   extendedglob rcquotes hashcmds  histexpiredupsfirst
setopt   globcomplete ignoreeof rmstarsilent histallowclobber
setopt   autopushd pushdminus pushdignoredups printeightbit
unsetopt bgnice listbeep recexact listambiguous 

bindkey -e               # emacs key bindings
bindkey ' ' magic-space  # also do history expansino on space
bindkey "\e[Z" reverse-menu-complete

autoload -U up-line-or-beginning-search
autoload -U down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey "^P" up-line-or-beginning-search
bindkey "^N" down-line-or-beginning-search

autoload -U edit-command-line
zle -N edit-command-line
bindkey '\ee' edit-command-line
precmd() { jobs; }

# The following lines were added by compinstall
autoload -U compinit
compinit -u

zstyle ':completion:*' auto-description 'specify: %d'
zstyle ':completion:*' file-sort name
zstyle ':completion:*' format 'Completing %d'
zstyle ':completion:*' ignore-parents parent
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' max-errors 4
zstyle ':completion:*' menu select=0
zstyle ':completion:*' prompt 'correct'
zstyle ':completion:*' squeeze-slashes true
zstyle ':completion:*' substitute 1
zstyle ':completion:*' verbose true
zstyle :compinstall filename '/home/tshm/.zshrc'
# End of lines added by compinstall

if [ "$TERM" = "cygwin" ]; then
	export CYGWIN=binmode
	export SHELL=zsh
	export LV="-Os"
	unalias ls; alias ls='ls --color=auto -F --show-control-chars'
	alias e='cygstart'
	alias man='LANG= man'
fi

if [ -f $(/usr/bin/dirname $0)/z/z.sh ]; then
  source $(/usr/bin/dirname $0)/z/z.sh
fi

if [ -f ~/.zshrc.local ]; then
  source ~/.zshrc.local
fi
