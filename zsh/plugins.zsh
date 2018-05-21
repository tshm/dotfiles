source ~/.zplug/init.zsh
echo "handle plugins"
zplug 'zplug/zplug', hook-build:'zplug --self-manage'

# Make sure to use double quotes
zplug "zsh-users/zsh-history-substring-search"

# Can manage everything e.g., other person's zshrc
zplug "tcnksm/docker-alias", use:zshrc

# Supports oh-my-zsh plugins and the like
zplug "plugins/git",   from:oh-my-zsh

# Also prezto
zplug "modules/prompt", from:prezto

zplug "zsh-users/zsh-syntax-highlighting", defer:2
zplug "zsh-users/zsh-autosuggestions"
zplug "zsh-users/zsh-completions"
zplug "chrissicool/zsh-256color"

zplug load --verbose

