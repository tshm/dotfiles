# echo "handle plugins"

# init
source ~/.zplugin/bin/zplugin.zsh
autoload -Uz _zplugin
(( ${+_comps} )) && _comps[zplugin]=_zplugin

#zplg light zdharma/fast-syntax-highlighting
#zplg ice wait'1' atload'_zsh_autosuggest_start'
zplg light zsh-users/zsh-autosuggestions
zplg light zsh-users/zsh-completions
zplg light mollifier/anyframe

zplg ice as"program" pick"bin/git-dsf"; zplg load zdharma/zsh-diff-so-fancy
zplg light nocttuam/autodotenv

zplg ice pick"async.zsh" src"pure.zsh"; zplg load sindresorhus/pure
zplg light zsh-users/zsh-history-substring-search

if [ -z "$LOAD_FZF" -o "$LOAD_FZF" -ne "0" ]; then
    zplg ice from"gh-r" as"program"; zplg load junegunn/fzf-bin
fi
zplg ice "rupa/z" pick"z.sh"; zplg load "rupa/z"
#zplg load zpm-zsh/clipboard
#zplg light zsh-users/zaw

zplg snippet 'OMZ::lib/completion.zsh'
zplg snippet 'OMZ::lib/compfix.zsh'

# finalize
autoload -U compinit
compinit

