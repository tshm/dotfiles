# install
## sh -c "$(curl -fsSL https://raw.githubusercontent.com/zdharma/zinit/master/doc/install.sh)"

# init
source ~/.zinit/bin/zinit.zsh
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

# plugins
zinit for \
  light-mode zsh-users/zsh-autosuggestions \
  light-mode \
    zdharma/fast-syntax-highlighting \
    zdharma/history-search-multi-word \
    pick"async.zsh" src"pure.zsh" sindresorhus/pure
zinit ice wait'1' atload'_zsh_autosuggest_start'
zinit light zsh-users/zsh-completions

zinit ice as"command" extract"" pick"delta/delta" mv"delta* -> delta" from"gh-r"
zinit load dandavison/delta

zinit load lukechilds/zsh-nvm

zinit ice wait:2 as"command" from"gh-r" mv"bat* -> bat" pick"bat/bat"
zinit light sharkdp/bat
zinit ice wait:2 as"command" from"gh-r" mv"fd* -> fd" pick"fd/fd"
zinit light sharkdp/fd

zinit ice wait:2 lucid extract"" from"gh-r" as"command" mv"exa* -> exa"
zinit light ogham/exa
zinit light DarrinTisdale/zsh-aliases-exa

zinit ice wait:2 as"command" from"gh-r" mv"ripgrep* -> ripgrep" pick"ripgrep/rg"
zinit light BurntSushi/ripgrep

zinit from"gh-r" as"program" mv"direnv* -> direnv" \
  atclone'./direnv hook zsh > zhook.zsh' atpull'%atclone' \
  pick"direnv" src="zhook.zsh" for direnv/direnv

zinit ice wait:2 lucid from"gh-r" pick bpick"*.gz"
zinit light starship/starship

zinit ice as"completion"
zinit snippet https://github.com/docker/cli/blob/master/contrib/completion/zsh/_docker

zinit light zsh-users/zsh-history-substring-search
if [ -z "$LOAD_FZF" -o "$LOAD_FZF" -ne "0" ]; then
  zinit ice from"gh-r" as"command"
  zinit load junegunn/fzf-bin
fi
zinit ice "rupa/z" pick"z.sh"; zinit load "rupa/z"
zinit ice pick"deer"; zinit load "Vifon/deer"
zle -N deer
bindkey '\el' deer

zinit ice wait atinit"zpcompinit; zpcdreplay"; zinit load zsh-users/zaw
zinit snippet 'OMZ::lib/completion.zsh'
zinit snippet 'OMZ::lib/compfix.zsh'

# finalize
autoload -U compinit
compinit
