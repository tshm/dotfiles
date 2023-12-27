#-*-shell-script-*-
# vim: ft=zsh
unset MAILCHECK
uname=$(uname -a)

which curl >/dev/null && function cheat () {
  curl cheat.sh/$1 | bat
}

which scr >/dev/null && {
  alias scr='scrot -s -f - | xclip -selection clipboard -t image/png -i'
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
  | ug -v '\[' \
  | awk "$awks" \
  | sort -g
}
[ -d /nix ] && {
  function nixup() {
    nix-env --install --attr nixpkgs.nix nixpkgs.cacert
    nix-env --delete-generations 14d
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
  function viup() { nix-shell -p gcc --run "nvim -c 'TSUpdate all'" }
}

(which xdg-open >/dev/null) && {
  alias e=xdg-open
}

(echo $uname | grep -i microsoft >/dev/null) && {
  alias scoopup="scoop update '*' && scoop cleanup '*' && scoop cache rm '*'"
  unalias e
  function e() {
    (which wsl-open > /dev/null) && wsl-open "$*" \
      || cmd.exe /c start $(wslpath -w "$*")
  }
  function gvim() {
    nvim-qt.exe --wsl $*
  }
}
