unset MAILCHECK

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
tm() {
  SN=${1:-home}
  echo -------- start $SN
  tmux has -t $SN || {
    source ~/.dotfiles/proj/${SN}.sh
    #
    tmux select-window -t $SN:0
    tmux select-pane -t 0
  }
  [ -z $TMUX ] && tmux attach -t $SN || tmux switch -t $SN
  # [ $SN = $(tmux list-panes -t "$TMUX_PANE" -F '#S' | head -n1) ]
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

(which lvim >/dev/null) && {
  alias vi=lvim
}

(uname -a | grep Microsoft) && {
  alias scoopup="scoop update '*' && scoop cleanup '*' && scoop cache rm '*'"
  function e() {
    (which wsl-open > /dev/null) && wsl-open $* \
    || cmd.exe /c start $(wslpath -w $*)
  }
  function gvim() {
    h=`wslpath -w $HOME`
    export LUNARVIM_RUNTIME_DIR="$h/.local/share/lunarvim"
    export LUNARVIM_CONFIG_DIR="$h/.config/lvim"
    export LUNARVIM_CACHE_DIR="$h/.cache/nvim"
    args2=()
    for i in $*; do
      echo file: $i
      args2+="$(wslpath -aw $i) "
    done
    exec neovide.exe -u "$LUNARVIM_RUNTIME_DIR/lvim/init.lua" $args2 &
    # neovide.exe $args2 &
    # exec neovide.exe -u "$LUNARVIM_RUNTIME_DIR/lvim/init.lua" "$@"
  }
  function vim() {
    args2=()
    for i in $*; do
      echo file: $i
      args2+="$(wslpath -aw $i) "
    done
    nvim $args2
  }
}
