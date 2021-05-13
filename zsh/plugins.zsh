# install
if [ ! -d "${HOME}/.zinit" ]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/zdharma/zinit/master/doc/install.sh)"
fi

# init
source "${HOME}/.zinit/bin/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

# bins
zinit ice as"program" pick"$ZPFX/bin/git-*" make"PREFIX=$ZPFX"
zinit light tj/git-extras
zinit ice wait:2 as"command" extract"" from"gh-r" mv"delta* -> delta" pick"delta/delta"
zinit load dandavison/delta
zinit ice wait:2
zinit light wfxr/forgit
zinit ice wait:2 as"command" from"gh-r"  pick "ugit"
zinit load Bhupesh-V/ugit

zinit ice wait:2 as"command" from"gh-r" mv"bat* -> bat" pick"bat/bat"
zinit light sharkdp/bat
zinit ice wait:2 as"command" from"gh-r" mv"fd* -> fd" pick"fd/fd"
zinit light sharkdp/fd
zinit ice wait:2 as"command" lucid extract"" from"gh-r" mv"exa* -> exa" pick"bin/exa"
zinit light ogham/exa
zinit ice wait:2 as"command" from"gh-r" mv"ripgrep* -> ripgrep" pick"ripgrep/rg"
zinit light BurntSushi/ripgrep

if [ -z "$LOAD_FZF" -o "$LOAD_FZF" -ne "0" ]; then
  zinit ice as"command" from"gh-r"
  zinit load junegunn/fzf-bin
fi

zinit load asdf-vm/asdf

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

# plugins
zinit for light-mode \
  Aloxaf/fzf-tab \
  zsh-users/zsh-autosuggestions \
  zdharma/fast-syntax-highlighting \
  zdharma/history-search-multi-word \
  hlissner/zsh-autopair \
  pick"async.zsh" src"pure.zsh" sindresorhus/pure

zinit light zsh-users/zsh-history-substring-search
zinit light DarrinTisdale/zsh-aliases-exa

zinit ice wait:2 as"command" make pick"nnn"
zinit light jarun/nnn

zinit ice pick"deer"; zinit load "Vifon/deer"
zle -N deer
bindkey '\el' deer

# completions & etc
zinit ice wait'1' atload'_zsh_autosuggest_start'
zinit light zsh-users/zsh-completions

zinit ice wait:2
zinit snippet OMZ::plugins/dotenv/dotenv.plugin.zsh

zinit ice as"completion"
zinit snippet https://github.com/docker/cli/blob/master/contrib/completion/zsh/_docker

zinit snippet 'OMZ::lib/completion.zsh'
zinit snippet 'OMZ::lib/compfix.zsh'

# finalize
autoload -U compinit
compinit
zinit cdreplay -q 
zinit cdlist 
