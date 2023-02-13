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

# plugins
zinit for light-mode \
  zsh-users/zsh-autosuggestions \
  zdharma-continuum/fast-syntax-highlighting \
  zdharma-continuum/history-search-multi-word \
  hlissner/zsh-autopair \
  pick"async.zsh" src"pure.zsh" sindresorhus/pure

zinit light zsh-users/zsh-history-substring-search

# completions & etc
zinit ice atload'_zsh_autosuggest_start'
zinit light zsh-users/zsh-completions

zinit ice lucid nocompile nocompletions
zinit load MenkeTechnologies/zsh-more-completions

zinit ice as"completion"
zinit snippet https://github.com/docker/cli/blob/master/contrib/completion/zsh/_docker

zinit snippet 'OMZ::lib/completion.zsh'
zinit snippet 'OMZ::lib/compfix.zsh'

# git
zinit ice as"program" pick"$ZPFX/bin/git-*" make"PREFIX=$ZPFX"
zinit light tj/git-extras
zinit light wfxr/forgit
zinit ice as"command" from"gh-r" pick "ugit"
zinit load Bhupesh-V/ugit

# tools
zinit ice as"command" from"gh-r"
zinit load "topgrade-rs/topgrade"

zinit load "zpm-zsh/clipboard"

# finalize
autoload -U compinit
for dump in ~/.zcompdump(N.mh+24); do
  compinit
done
compinit -C

# fzf-tab has to be loaded after compinit
zinit light Aloxaf/fzf-tab
zstyle ':fzf-tab:*' fzf-bindings \
  'ctrl-s:toggle+down' \
  'ctrl-a:toggle-all' \
  'ctrl-y:y:execute-silent(echo {} | pbcopy)+abort'

zinit cdreplay -q 
zinit cdlist 
