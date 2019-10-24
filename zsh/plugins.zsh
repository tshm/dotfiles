# echo "handle plugins"

# init
source ~/.zplugin/bin/zplugin.zsh
autoload -Uz _zplugin
(( ${+_comps} )) && _comps[zplugin]=_zplugin

zplugin load zdharma/history-search-multi-word
#zplugin light zdharma/fast-syntax-highlighting
zplugin light zsh-users/zsh-autosuggestions
zplugin ice wait'1' atload'_zsh_autosuggest_start'
zplugin light zsh-users/zsh-completions
zplugin light mollifier/anyframe

zplugin ice as"program" pick"bin/git-dsf"; zplugin load zdharma/zsh-diff-so-fancy
zplugin light nocttuam/autodotenv

zplugin ice as"completion"
zplugin snippet https://github.com/docker/cli/blob/master/contrib/completion/zsh/_docker

zplugin ice pick"async.zsh" src"pure.zsh"; zplugin load sindresorhus/pure
zplugin light zsh-users/zsh-history-substring-search

if [ -z "$LOAD_FZF" -o "$LOAD_FZF" -ne "0" ]; then
    zplugin ice from"gh-r" as"program"; zplugin load junegunn/fzf-bin
fi
zplugin ice "rupa/z" pick"z.sh"; zplugin load "rupa/z"
#zplugin load zpm-zsh/clipboard
zplugin ice wait atinit"zpcompinit; zpcdreplay"; zplugin load zsh-users/zaw

zplugin snippet 'OMZ::lib/completion.zsh'
zplugin snippet 'OMZ::lib/compfix.zsh'

# finalize
autoload -U compinit
compinit

