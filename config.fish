set -x SHELL /usr/bin/fish
set -x PAGER "lv -c"

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

  set __CMD_STACK
  function push_cmd
    set __CMD_STACK $__CMD_STACK "$argv"
  end

  function pop_cmd
    test -z "$__CMD_STACK"; and return
    set -l n (count $__CMD_STACK)
    commandline -i $__CMD_STACK[$n]
    set -e __CMD_STACK[$n]
  end

  function fish_user_key_bindings
    bind \ek  history-token-search-backward
    bind \ej  history-token-search-forward
    # commandline seems to eval from right to left...
    bind \e\; 'commandline -f execute accept-autosuggestion'
    # invoking manual
    bind \eh 'echo get help;man (commandline -po)[1]; commandline -f repaint'
    # command stack
    bind \eq 'push_cmd (commandline); commandline -f kill-whole-line'
    # quoting whole line
    bind \e7 "commandline -i \'\'; commandline -f backward-char"
    # backward-kill-word
    bind \e\b backward-kill-word
  end

  function fish_right_prompt
    set_color yellow
    printf '(%s) ' (date +%H:%M)
    pop_cmd
    set_color normal
  end
end

# vi: ft=vb
