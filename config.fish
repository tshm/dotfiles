set -x SHELL /usr/bin/fish

if status --is-login
  cd $HOME
  # which tmux; and tmux attach -t root; or tmux new -s root
  test -f .login.fish; and source .login.fish
end

if status --is-interactive
  test -f .local.fish; and source .local.fish
  set -x LESS "--quit-if-one-screen -R -iMX"
  set -x LS_COLORS "di=32:ln=36:pi=31:so=33:bd=44;37:cd=44;37:ex=35"
  set -x PATH ~/bin $PATH

  alias dir "ls -lh"
  alias rm "rm -i"
  alias vim "env SHELL=sh vim"

  set __QQ
  function queuecommand
    if test -z "$argv" -a -n "$__QQ"
      set -l n (count $__QQ)
      commandline -i $__QQ[$n]
      set -e __QQ[$n]
    else
      set __QQ $__QQ "$argv"
    end
  end

  function fish_user_key_bindings
    bind \ek  history-token-search-backward
    bind \ej  history-token-search-forward
    # commandline seems to eval from right to left...
    bind \e\; 'commandline -f execute accept-autosuggestion'
    # invoking manual
    bind \eh 'man (commandline -po)[1]; commandline -f repaint'
    # command queueing
    bind \eq 'queuecommand (commandline); commandline -f backward-kill-line'
  end

  function fish_right_prompt
    set_color yellow
    printf '(%s) ' (date +%H:%M)
    queuecommand
    set_color normal
  end
end

# vi: ft=sh
