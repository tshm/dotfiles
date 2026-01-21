#-*-shell-script-*-
# vim: ft=zsh foldmethod=indent
unset MAILCHECK
uname=$(uname -a)

alias tokscale='bunx tokscale@latest'
alias opencode='~/.opencode/bin/opencode'
alias op=opencode

function scptar() {
  [ $# -ne 2 ] && echo "Usage: $1 <source> <destination>" && return 1
  local src="$1"
  local dst="$2"
  # Parse source
  local src_host=""
  local src_path=""
  if [[ "$src" =~ ":" ]]; then
    src_host="${src%%:*}"
    src_path="${src#*:}"
  else
    src_path="$(realpath --relative-base=. $src)"
  fi
  # Parse destination
  local dst_host=""
  local dst_path=""
  if [[ "$dst" =~ ":" ]]; then
    dst_host="${dst%%:*}"
    dst_path="${dst#*:}"
  else
    dst_path="$(realpath --relative-base=. $dst)"
  fi
  # Handle different cases with progress via pv if available
  if command -v pv >/dev/null 2>&1; then
    if [ -z "$src_host" ] && [ -n "$dst_host" ]; then # 1. Local to Remote
      tar czf - "$src_path" | pv | ssh "$dst_host" "cd \"${dst_path%/*}\" && tar xzf -"
    elif [ -n "$src_host" ] && [ -z "$dst_host" ]; then # 2. Remote to Local
      ssh "$src_host" "cd \"${src_path%/*}\" && tar czf - \"${src_path##*/}\"" | pv | tar xzf - -C "${dst_path}"
    elif [ -n "$src_host" ] && [ -n "$dst_host" ]; then # 3. Remote to Remote
      ssh "$src_host" "cd \"${src_path%/*}\" && tar czf - \"${src_path##*/}\"" | pv | ssh "$dst_host" "cd \"${dst_path%/*}\" && tar xzf -"
    else # 4. Local to Local
      tar czf - "$src_path" | pv | tar xzf - -C "${dst_path%/*}"
    fi
  else
    # Fallback without progress
    if [ -z "$src_host" ] && [ -n "$dst_host" ]; then # 1. Local to Remote
      tar czf - "$src_path" | ssh "$dst_host" "cd \"${dst_path%/*}\" && tar xzf -"
    elif [ -n "$src_host" ] && [ -z "$dst_host" ]; then # 2. Remote to Local
      ssh "$src_host" "cd \"${src_path%/*}\" && tar czf - \"${src_path##*/}\"" | tar xzf - -C "${dst_path}"
    elif [ -n "$src_host" ] && [ -n "$dst_host" ]; then # 3. Remote to Remote
      ssh "$src_host" "cd \"${src_path%/*}\" && tar czf - \"${src_path##*/}\"" | ssh "$dst_host" "cd \"${dst_path%/*}\" && tar xzf -"
    else # 4. Local to Local
      tar czf - "$src_path" | tar xzf - -C "${dst_path%/*}"
    fi
  fi
}
compdef scptar=scp

builtin whence -p curl >/dev/null && function cheat () {
  curl cheat.sh/$1 | bat
}

builtin whence -p scrot >/dev/null && {
  builtin whence -p wl-copy >/dev/null && {
    alias scr='scrot -s -f - | wl-copy'
  } || {
    alias scr='scrot -s -f - | xclip -selection clipboard -t image/png -i'
  }
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

(builtin whence -p docker > /dev/null) && {
  alias dco='docker-compose'
  alias dcr='docker run -it --rm -v $PWD:/app -w /app'
  function dockerclean() {
    docker system df
    docker rm `docker ps -aq`
    docker volume rm `docker volume ls -q -f dangling=true`
    docker image prune
    docker system df
  }
}

(builtin whence -p nvim >/dev/null) && {
  alias vi=nvim
  function viup() { nix-shell -p gcc --run "nvim -c 'TSUpdate all'" }
}

(builtin whence -p xdg-open >/dev/null) && {
  alias e=xdg-open
}

(echo $uname | grep -i microsoft >/dev/null) && {
  alias scoopup="scoop update '*' && scoop cleanup '*' && scoop cache rm '*'"
  function e() {
    (builtin whence -p wsl-open > /dev/null) && wsl-open "$*" \
      || cmd.exe /c start $(wslpath -w "$*")
  }
  function gvim() {
    neovide.exe --wsl $*
  }
}
