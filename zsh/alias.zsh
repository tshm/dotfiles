#-*-shell-script-*-
# vim: ft=zsh
unset MAILCHECK
uname=$(uname -a)

[ -f ~/.config/nnn/plugins/z ] || mkdir -p ~/.config/nnn/plugins/ || ln -s ~/.dotfiles/zsh/nnn_z ~/.config/nnn/plugins/z
export NNN_BMS='d:~/dl'
export NNN_PLUG='z:z;c:!code $nnn*;e:!nvim $nnn*'
function n() {
  env LESS= BAT_PAGER='less -R' VISUAL=bat nnn -e $*
}

function b () {
  local cmd cmd_file code
  cmd_file=$(mktemp)
  if broot --outcmd "$cmd_file" "$@"
  then
    cmd=$(<"$cmd_file")
    rm -i -f "$cmd_file"
    eval "$cmd"
  else
    code=$?
    rm -i -f "$cmd_file"
    return "$code"
  fi
}

which curl >/dev/null && function cheat () {
  curl cheat.sh/$1 | bat
}

function tm () {
  SN=${1:-home}
  echo -------- start $SN
  tmux has -t $SN || {
    source ~/.dotfiles/proj/${SN}.sh
    #
    tmux select-window -t $SN:0
    tmux select-pane -t 0
  }
  tmux attach -t $SN || tmux switch -t $SN
}
_tm() {
  _values 'sessions' $(/bin/ls ~/.dotfiles/proj/ | sed 's/\.sh//')
}
compdef _tm tm

_files 2>/dev/null
functions[_files_orig]=$functions[_files]
function _files() {
  _files_orig
  local files
  grep '/' <<<${words[CURRENT]} || files=($(fd ${words[CURRENT]}))
  _values 'files' ${files[@]}
}

read -d '' -r awks <<'EOF'
NR>2 {
  mem[$3]+=$2
}
END {
  for(k in mem) printf "%0.1f\t%s\n", mem[k]/1024000, k
};
EOF
function mem_info() {
  ps -eo pmem,vsize,cmd \
  | grep -v '\[' \
  | awk "$awks" \
  | sort -g
}
[ -d /nix ] && {
  function nixup() {
    nix-channel --update
    which home-manager && home-manager switch
    nix-env -u
    nix-store --optimise
    nix-collect-garbage -d
  }
}

(which docker > /dev/null) && {
  function dockerclean() {
    docker system df
    docker rm `docker ps -aq`
    docker volume rm `docker volume ls -q -f dangling=true`
    docker system df
  }
}

(which nvim >/dev/null) && {
  alias vi=nvim
}

(which xdg-open >/dev/null) && {
  alias e=xdg-open
}

(echo $uname | grep -i microsoft >/dev/null) && {
  alias scoopup="scoop update '*' && scoop cleanup '*' && scoop cache rm '*'"
  function e() {
    (which wsl-open > /dev/null) && wsl-open "$*" \
    || cmd.exe /c start $(wslpath -w "$*")
  }
  function gvim() {
    nvim-qt.exe --wsl $*
  }
}
