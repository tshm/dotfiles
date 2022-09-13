# install
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
if [ ! -d "$ZINIT_HOME" ]; then
  mkdir -p "$(dirname $ZINIT_HOME)"
  git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

# init
source "${ZINIT_HOME}/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit
arc=$(uname -m | cut -c1-5)

# bins
zinit ice as"command" from"gh-r"
zinit load junegunn/fzf

zinit ice wait:0 as"command" make pick"fasd"
zinit light clvv/fasd
zinit ice wait:2
zinit snippet OMZ::plugins/fasd/fasd.plugin.zsh
zle -N fasd-complete
zle -N fasd-complete-f
zle -N fasd-complete-d
bindkey '^X^A' fasd-complete    # C-x C-a to do fasd-complete (files and directories)
bindkey '^X^F' fasd-complete-f  # C-x C-f to do fasd-complete-f (only files)
bindkey '^X^D' fasd-complete-d  # C-x C-d to do fasd-complete-d (only directories)

# handle direnv with asdf
zinit ice wait lucid
zinit load redxtech/zsh-asdf-direnv

# plugins
zinit for light-mode \
  zsh-users/zsh-autosuggestions \
  zdharma-continuum/fast-syntax-highlighting \
  zdharma-continuum/history-search-multi-word \
  hlissner/zsh-autopair \
  pick"async.zsh" src"pure.zsh" sindresorhus/pure

zinit light zsh-users/zsh-history-substring-search

# completions & etc
zinit ice wait'1' atload'_zsh_autosuggest_start'
zinit light zsh-users/zsh-completions

zinit ice lucid nocompile wait'0e' nocompletions
zinit load MenkeTechnologies/zsh-more-completions

zinit ice as"completion"
zinit snippet https://github.com/docker/cli/blob/master/contrib/completion/zsh/_docker

zinit snippet 'OMZ::lib/completion.zsh'
zinit snippet 'OMZ::lib/compfix.zsh'

# git
zinit ice as"program" pick"$ZPFX/bin/git-*" make"PREFIX=$ZPFX"
zinit light tj/git-extras
zinit ice wait:2
zinit light wfxr/forgit
zinit ice wait:2 as"command" from"gh-r" pick "ugit"
zinit load Bhupesh-V/ugit

# tools
zinit ice pick"deer"; zinit load "Vifon/deer"
zle -N deer
bindkey '\el' deer

zinit ice wait:2 as"command" from"gh-r"
zinit load "r-darwish/topgrade"

zinit ice wait:2
zinit load "zpm-zsh/clipboard"

# finalize
autoload -U compinit
compinit

# fzf-tab has to be loaded after compinit
zinit light Aloxaf/fzf-tab
zstyle ':fzf-tab:*' fzf-bindings \
  'ctrl-s:toggle+down' \
  'ctrl-a:toggle-all' \
  'ctrl-y:y:execute-silent(echo {} | pbcopy)+abort'

zinit cdreplay -q 
zinit cdlist 
