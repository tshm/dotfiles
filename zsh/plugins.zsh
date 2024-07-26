#-*-shell-script-*-
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
[ ! -d "$ZINIT_HOME" ] && mkdir -p "$(dirname $ZINIT_HOME)"
[ ! -d "$ZINIT_HOME/.git" ] && git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"

# init
# ShellCheck
source "${ZINIT_HOME}/zinit.zsh"

zinit for light-mode \
  zsh-users/zsh-autosuggestions \
  zdharma-continuum/history-search-multi-word \
  zdharma-continuum/fast-syntax-highlighting \
  hlissner/zsh-autopair

# prompt
zinit ice compile'(pure|async).zsh' pick"async.zsh" src"pure.zsh"
zinit light sindresorhus/pure

# zinit ice as"command" from"gh-r" \
#           atclone"./starship init zsh > init.zsh; ./starship completions zsh > _starship" \
#           atpull"%atclone" src"init.zsh"
# zinit light starship/starship

# plugins
zinit light zsh-users/zsh-history-substring-search

# completions & etc
zinit light zsh-users/zsh-completions

zinit ice lucid nocompile nocompletions
zinit load MenkeTechnologies/zsh-more-completions

zinit snippet 'OMZ::lib/completion.zsh'
zinit snippet 'OMZ::lib/compfix.zsh'

# git
zinit ice as"program" pick"$ZPFX/bin/git-*" make"PREFIX=$ZPFX"
zinit light tj/git-extras
zinit light wfxr/forgit
zinit ice as"command" from"gh-r" pick "ugit"
zinit load Bhupesh-V/ugit

# tools
zinit light "zpm-zsh/clipboard"

# zinit ice lucid wait"0a" from"gh-r" as"program" atload'eval "$(mcfly init zsh)"'
# zinit light cantino/mcfly
zinit ice as"command" from"gh-r" bpick"atuin-*.tar.gz" mv"atuin*/atuin -> atuin" \
    atclone"./atuin init zsh > init.zsh; ./atuin gen-completions --shell zsh > _atuin" \
    atpull"%atclone" src"init.zsh"
zinit light atuinsh/atuin

# finalize
autoload -U compinit
for dump in ~/.zcompdump(N.mh+24); do
  compinit
done
compinit -C

# fzf-tab has to be loaded after compinit
zinit light Aloxaf/fzf-tab
[ -n "$TMUX" ] && zstyle ':fzf-tab:*' fzf-command ftb-tmux-popup

zinit ice atload'_zsh_autosuggest_start'

zinit cdreplay -q
zinit cdlist
