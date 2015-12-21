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

  alias rm "rm -i"
  alias vim "env SHELL=sh vim"

  # helper functions
  set __CMD_STACK
  function _push_cmd
    set __CMD_STACK $__CMD_STACK "$argv"
  end

  function _pop_cmd
    [ -z "$__CMD_STACK" ]; and return
    set -l n (count $__CMD_STACK)
    commandline -i $__CMD_STACK[$n]
    set -e __CMD_STACK[$n]
  end

  function _custom_execute
    execute
  end

  function _quote
    set -l tok (commandline -t)
    commandline -t \"$tok\"
    [ -z "$tok" ]; and commandline -f backward-char
  end

  function _stack
    _push_cmd (commandline)
    commandline -f kill-whole-line
  end

  function _help
    echo -- get help
    man (commandline -po)[1]
    commandline -f repaint
  end

  function _fzf_pane
    [ -z "$TMPDIR" ]; and set -g TMPDIR /tmp
    tmux capture-pane -pS -30 | eval "fzf-tmux -d40%" > $TMPDIR/fzf.result
    set -l __FZF (cat $TMPDIR/fzf.result)
    cat $TMPDIR/fzf.result
    [ -z "$__FZF" ]; and return
    commandline -i $__FZF
    commandline -o
    commandline -f repaint
  end

  function _fzf_file
    [ -z "$TMPDIR" ]; and set -g TMPDIR /tmp
    ls | eval "fzf-tmux -d40%" > $TMPDIR/fzf.result
    set -l __FZF (cat $TMPDIR/fzf.result)
    cat $TMPDIR/fzf.result
    [ -z "$__FZF" ]; and return
    commandline -i $__FZF
    commandline -o
    commandline -f repaint
  end

  function fish_user_key_bindings
    # enable vi mode
    fish_vi_mode
    fish_vi_key_bindings
    # delete exit shortcut
    bind -e \cd
    bind -e \ed
    # find filename via fzf
    bind -M insert \e8  _fzf_file
    bind -M insert \e9  _fzf_pane
    bind -M insert \ek  history-token-search-backward
    bind -M insert \ej  history-token-search-forward
    # accept and run
    bind -M insert \e\; 'commandline -f accept-autosuggestion execute'
    # invoking manual
    bind -M insert \eh _help
    # command stack
    bind -M insert \eq _stack
    # backward-kill-word
    bind -M insert \e\b backward-kill-word
    # quote token
    bind -M insert \e7 _quote
  end

  function fish_right_prompt
    set_color -u yellow
    printf '(%s) ' (date +%H:%M)
    _pop_cmd
    set_color normal
  end
end

# vi: ft=zsh
