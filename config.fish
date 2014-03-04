set -x SHELL /usr/bin/fish

if status --is-login
  screen -xRR -U >/dev/null; and exit
end

if status --is-interactive
  set -x LESS "--quit-if-one-screen -R -iMX"
  set -x LS_COLORS "di=32:ln=36:pi=31:so=33:bd=44;37:cd=44;37:ex=35"
  set -x PATH ~/bin $PATH

  alias dir "ls -lh"

  function fish_user_key_bindings
    bind \ek history-token-search-backward
    bind \ej history-token-search-forward
  end

  function fish_right_prompt
    set_color yellow
    printf '(%s) ' (date +%H:%M)
    set_color normal
  end
end

# vi: ft=sh
