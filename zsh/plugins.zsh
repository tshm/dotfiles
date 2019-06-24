# echo "handle plugins"

# init
source ~/.zplugin/bin/zplugin.zsh
autoload -Uz _zplugin
(( ${+_comps} )) && _comps[zplugin]=_zplugin

zplugin light zdharma/fast-syntax-highlighting
#zplugin ice wait'1' atload'_zsh_autosuggest_start'
zplugin light zsh-users/zsh-autosuggestions
zplugin light zsh-users/zsh-completions
zplugin light mollifier/anyframe

zplugin ice as"program" pick"bin/git-dsf"; zplugin load zdharma/zsh-diff-so-fancy
zplugin light nocttuam/autodotenv

zplugin ice pick"async.zsh" src"pure.zsh"; zplugin load sindresorhus/pure
zplugin light zsh-users/zsh-history-substring-search
zplugin light vim/vim
zplugin ice from"gh-r" as"program"; zplugin load junegunn/fzf-bin
zplugin ice "rupa/z" pick"z.sh"; zplugin load "rupa/z"
#zplugin load zpm-zsh/clipboard
zplugin light zsh-users/zaw

zplugin snippet 'OMZ::lib/completion.zsh'
zplugin snippet 'OMZ::lib/compfix.zsh'

# finalize
autoload -U compinit
compinit

