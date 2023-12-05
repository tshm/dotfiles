#-*-shell-script-*-
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
if [ ! -d "$ZINIT_HOME" ]; then
  mkdir -p "$(dirname $ZINIT_HOME)"
  git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

# init
# ShellCheck
source "${ZINIT_HOME}/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit
arc=$(uname -m | cut -c1-5)

zinit for light-mode \
  zsh-users/zsh-autosuggestions \
  zdharma-continuum/history-search-multi-word \
  zdharma-continuum/fast-syntax-highlighting \
  hlissner/zsh-autopair \
  pick"async.zsh" src"pure.zsh" sindresorhus/pure

# bins
zinit ice as"command" from"gh-r"
zinit load junegunn/fzf

# plugins
zinit light zsh-users/zsh-history-substring-search

# completions & etc
zinit light zsh-users/zsh-completions

zinit ice lucid nocompile nocompletions
zinit load MenkeTechnologies/zsh-more-completions

zinit ice as"completion"
zinit snippet https://github.com/docker/cli/blob/master/contrib/completion/zsh/_docker

zinit snippet 'OMZ::lib/completion.zsh'
zinit snippet 'OMZ::lib/compfix.zsh'

# history
zinit load jimhester/per-directory-history

# git
zinit ice as"program" pick"$ZPFX/bin/git-*" make"PREFIX=$ZPFX"
zinit light tj/git-extras
zinit light wfxr/forgit
zinit ice as"command" from"gh-r" pick "ugit"
zinit load Bhupesh-V/ugit

# tools
zinit ice ver"7fbd15150fe0fc84a34b6aa9e31c5589de3c9ffc"
zinit load "zpm-zsh/clipboard"
# set fpath += ~/.local/share/zinit/plugins/zpm-zsh---clipboard/functions/
# autoload -Uz open pbcopy pbpaste clip

zinit ice pick"deer"; zinit load "Vifon/deer"
zle -N deer
bindkey '\el' deer

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
