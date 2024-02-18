#-*-shell-script-*-
# vim: ft=zsh
unset MAILCHECK
uname=$(uname -a)

builtin whence -p curl >/dev/null && function cheat () {
  curl cheat.sh/$1 | bat
}

builtin whence -p scr >/dev/null && {
  alias scr='scrot -s -f - | xclip -selection clipboard -t image/png -i'
}

builtin whence -p eza >/dev/null && {
  alias ls='eza --icons'
  alias l='eza --icons -l'
  alias la='eza --icons -la'
}

function ff () {
  rgcmd="rg --color=always --line-number --no-heading --smart-case"
  [ -z "$*" ] && q0='--files' || q0="$*"
  FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS -e --disabled \
    --delimiter : \
    --color 'hl:-1:underline,hl+:-1:underline:reverse' \
    --bind 'change:reload:$rgcmd {q} || true' \
    --bind 'alt-e:become(vi {1} +{2} </dev/tty >/dev/tty)' \
    --preview 'bat --color=always {1} --highlight-line {2}'" \
  FZF_DEFAULT_COMMAND="$rgcmd $q0" fzf -q "$*"
}

# export NNN_OPENER='~/.config/nnn/plugins/nuke'
export NNN_BMS='d:~/dl'
export NNN_SPLITSIZE=75
export NNN_BATSTYLE=plain
export NNN_PLUG='p:-preview-tui;c:!code $nnn*;e:!nvim $nnn*;g:!xdg-open .'
export NNN_OPTS='Aae'
function n() {
  env LESS='-R -iMX' EDITOR=less VISUAL=less BAT_PAGER='less -R' nnn $*
}

function tm () {
  \builtin local SN=${1:-home} DIR
  [ -e ~/.dotfiles/proj/${SN}.sh ] || {
    DIR="$(\command zoxide query -- "$@[-1]")" || return
    SN="$(\command basename $DIR)" || return
  }
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
  tmux attach -t $SN || tmux switch -t $SN
}

read -d '' -r awks <<'EOF'
NR>2 {
  mem[$3]+=$2
}
END {
  for(k in mem) printf "%0.1f\t%s\n", mem[k]/1024000, k
};
EOF
function meminfo() {
  ps -eo pmem,vsize,cmd \
  | rg -v '\[' \
  | awk "$awks" \
  | sort -g
}
[ -d /nix ] && {
  function nixup() {
    # nix-env --install --attr nixpkgs.nix nixpkgs.cacert
    nix-env --delete-generations 14d
    nix-channel --update
    builtin whence -p home-manager && home-manager switch
    nix-env -u
    nix-store --optimise
    nix-collect-garbage -d
  }
}

(builtin whence -p docker > /dev/null) && {
  alias dco='docker-compose'
  alias dcr='docker run -it --rm -v $PWD:/app -w /app'
  function dockerclean() {
    docker system df
    docker rm `docker ps -aq`
    docker volume rm `docker volume ls -q -f dangling=true`
    docker system df
  }
}

builtin whence -p kubectl >/dev/null && alias kc='kubectl'

(builtin whence -p nvim >/dev/null) && {
  alias vi=nvim
  function viup() { nix-shell -p gcc --run "nvim -c 'TSUpdate all'" }
}

(builtin whence -p xdg-open >/dev/null) && {
  alias e=xdg-open
}

(echo $uname | grep -i microsoft >/dev/null) && {
  alias scoopup="scoop update '*' && scoop cleanup '*' && scoop cache rm '*'"
  unalias e
  function e() {
    (builtin whence -p wsl-open > /dev/null) && wsl-open "$*" \
      || cmd.exe /c start $(wslpath -w "$*")
  }
  function gvim() {
    nvim-qt.exe --wsl $*
  }
}
