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

zinit ice as"program" pick"$ZPFX/bin/git-*" make"PREFIX=$ZPFX"
zinit light tj/git-extras

zinit ice wait:2 as"command" extract"" from"gh-r" mv"delta* -> delta" pick"delta/delta"
zinit load dandavison/delta

zinit load lukechilds/zsh-nvm

zinit ice wait:2 as"command" from"gh-r" mv"bat* -> bat" pick"bat/bat"
zinit light sharkdp/bat
zinit ice wait:2 as"command" from"gh-r" mv"fd* -> fd" pick"fd/fd"
zinit light sharkdp/fd

zinit ice wait:2 as"command" lucid extract"" from"gh-r" mv"exa* -> exa"
zinit light ogham/exa
zinit light DarrinTisdale/zsh-aliases-exa

zinit ice wait:2
zinit snippet OMZ::plugins/dotenv/dotenv.plugin.zsh

zinit ice wait:2 as"command" from"gh-r" mv"ripgrep* -> ripgrep" pick"ripgrep/rg"
zinit light BurntSushi/ripgrep

zinit ice as"completion"
zinit snippet https://github.com/docker/cli/blob/master/contrib/completion/zsh/_docker

zinit light zsh-users/zsh-history-substring-search
if [ -z "$LOAD_FZF" -o "$LOAD_FZF" -ne "0" ]; then
  zinit ice as"command" from"gh-r"
  zinit load junegunn/fzf-bin
fi
zinit ice "rupa/z" pick"z.sh"; zinit load "rupa/z"
zinit ice pick"deer"; zinit load "Vifon/deer"
zle -N deer
bindkey '\el' deer

zinit ice wait atinit"zpcompinit; zpcdreplay"; zinit load zsh-users/zaw
zinit snippet 'OMZ::lib/completion.zsh'
zinit snippet 'OMZ::lib/compfix.zsh'

zinit load asdf-vm/asdf

# finalize
autoload -U compinit
compinit
zinit cdreplay -q 
zinit cdlist 
