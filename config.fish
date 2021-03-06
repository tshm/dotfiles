# source ~/.dotfiles/config.fish
#
set -x SHELL /usr/bin/fish
set -x EDITOR "vim"
set -x PAGER "less"
if [ -x "lv" ]
  set -x PAGER "lv -c"
end

if status is-login
  cd $HOME
  test -f .login.fish; and source .login.fish
end

if status is-interactive
  test -f .local.fish; and source .local.fish
  set -x LESS "--quit-if-one-screen -R -iMX"
  set -x LS_COLORS "di=32:ln=36:pi=31:so=33:bd=44;37:cd=44;37:ex=35"
  set -x PATH ~/bin $PATH

  function rm; command rm -i $argv; end
  function vi; command vim $argv; end
  function ff; command ranger $argv; end
  function gf; command git flow $argv; end

  # helper functions
  set __CMD_STACK
  function _push_cmd
    set __CMD_STACK $__CMD_STACK "$argv"
  end

  function _pop_cmd -e fish_postexec
    [ -z "$__CMD_STACK" ]; and return
    set -l n (count $__CMD_STACK)
    commandline -i $__CMD_STACK[$n]
    set -e __CMD_STACK[$n]
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

  # fzf connectors
  set __FZF "fzf-tmux -d40%"
  function _fzf_pane
    _expand_fzf -t -r "tmux capture-pane -pS -30 | $__FZF -q (commandline -t)"
  end

  function _fzf_file
    _expand_fzf -t -r "$__FZF -q (commandline -t)"
  end

  function _fzf_history
    _expand_fzf "history | $__FZF -q (commandline)"
  end

  function _expand_fzf
    set -l cmd $argv[-1]; and set -e argv[-1]
    and eval $cmd | read -l fzfout
    and eval "commandline $argv \"$fzfout\""
  end

  function fish_user_key_bindings
    # enable vi mode
    fish_vi_key_bindings
    set -g __fish_vi_mode 1
    bind --erase -M insert \cd
    bind -M insert \e\x7f backward-kill-word
    bind -M insert \eb  backward-word
    bind -M insert \ef  forward-word
    bind -M insert \ca  beginning-of-line
    bind -M insert \ce  end-of-line
    bind -M insert \ck  kill-line
    bind -M insert \cb  backward-char
    bind -M insert \cf  forward-char
    bind -M insert \cp  up-or-search
    bind -M insert \cn  down-or-search
    bind -M insert \cl  'clear; commandline -f repaint'
    type -q getclip; and bind -M insert \ey 'commandline -i ( getclip; echo )[1]'
    type -q xsel;    and bind -M insert \ey 'commandline -i ( xsel -p; echo )[1]'

    # delete exit shortcut
    bind -e \cd
    bind -e \ed
    # find filename via fzf
    bind -M insert \e8  _fzf_file
    bind -M insert \e9  _fzf_pane
    bind -M insert \e\/  _fzf_history
    bind -M insert \ek  history-token-search-backward
    bind -M insert \ej  history-token-search-forward
    bind -M insert \e\; 'commandline -f accept-autosuggestion execute'
    bind -M insert \eq  _stack
    bind -M insert \e7  _quote
    bind -M insert \e\' _quote
    # bind -M insert \eh  __fish_man_page
    bind -M insert \ep  '__fish_paginate; commandline -f execute'
  end

  function fish_right_prompt
    set_color -u yellow
    printf '(%s) ' (date +%H:%M)
    set_color normal
  end

end

# vi: ft=fish
