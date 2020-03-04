# echo "handle plugins"

# init
source ~/.zinit/bin/zinit.zsh
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

# plugins
zinit for \
    light-mode zsh-users/zsh-autosuggestions \
    light-mode zdharma/fast-syntax-highlighting \
               zdharma/history-search-multi-word \
    pick"async.zsh" src"pure.zsh" sindresorhus/pure
zinit ice wait'1' atload'_zsh_autosuggest_start'
zinit light zsh-users/zsh-completions
zinit ice as"program" pick"bin/git-dsf"; zinit load zdharma/zsh-diff-so-fancy

zinit ice wait
zinit load lukechilds/zsh-nvm

zinit ice as"command" from"gh-r" mv"bat* -> bat" pick"bat/bat"
zinit light sharkdp/bat

# zinit ice wait:2 lucid extract"" from"gh-r" as"program" mv"exa* -> exa"
# zinit light ogham/exa
# zinit light DarrinTisdale/zsh-aliases-exa

zinit ice from"gh-r" as"program" mv"direnv* -> direnv"
zinit light direnv/direnv

zinit ice as"completion"
zinit snippet https://github.com/docker/cli/blob/master/contrib/completion/zsh/_docker

zinit light zsh-users/zsh-history-substring-search
if [ -z "$LOAD_FZF" -o "$LOAD_FZF" -ne "0" ]; then
    zinit ice from"gh-r" as"program"; zinit load junegunn/fzf-bin
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
