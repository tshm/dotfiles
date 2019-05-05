echo "handle plugins"

# init
source ~/.zplugin/bin/zplugin.zsh
autoload -Uz _zplugin
(( ${+_comps} )) && _comps[zplugin]=_zplugin

# plugin at load time
zplugin light zdharma/fast-syntax-highlighting
zplugin light zsh-users/zsh-autosuggestions
zplugin light zsh-users/zsh-completions

zplugin ice as"program" pick"bin/git-dsf"
zplugin light zdharma/zsh-diff-so-fancy
zplugin light nocttuam/autodotenv

# async loading
zplugin ice pick"async.zsh" src"pure.zsh"; zplugin light sindresorhus/pure
zplugin ice wait'!0'; zplugin light zsh-users/zsh-history-substring-search
zplugin ice wait'!0'; zplugin light vim/vim
zplugin ice from"gh-r" as"program"; zplugin load junegunn/fzf-bin
zplugin ice "rupa/z" pick"z.sh"; zplugin light "rupa/z"
#zplugin load zpm-zsh/clipboard
zplugin light zsh-users/zaw

zplugin snippet 'OMZ::lib/completion.zsh'
zplugin snippet 'OMZ::lib/compfix.zsh'

# finalize
autoload -U compinit
compinit

# Also prezto
#zplug "modules/prompt", from:prezto

#zplug "chrissicool/zsh-256color"

