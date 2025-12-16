#-*-shell-script-*-
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
[ ! -d "$ZINIT_HOME" ] && mkdir -p "$(dirname $ZINIT_HOME)"
[ ! -d "$ZINIT_HOME/.git" ] && git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"

# init
# ShellCheck
source "${ZINIT_HOME}/zinit.zsh"

zinit for light-mode \
  zsh-users/zsh-autosuggestions \
  zdharma-continuum/history-search-multi-word \
  zdharma-continuum/fast-syntax-highlighting \
  hlissner/zsh-autopair

# prompt
zinit ice compile'(pure|async).zsh' pick"async.zsh" src"pure.zsh"
zinit light sindresorhus/pure

# zinit ice depth=1
# zinit light jeffreytse/zsh-vi-mode

# zinit ice as"command" from"gh-r" \
#           atclone"./starship init zsh > init.zsh; ./starship completions zsh > _starship" \
#           atpull"%atclone" src"init.zsh"
# zinit light starship/starship

# plugins
zinit light zsh-users/zsh-history-substring-search

# completions & etc
zinit light zsh-users/zsh-completions

zinit ice lucid nocompile nocompletions
zinit load MenkeTechnologies/zsh-more-completions

zinit snippet 'OMZ::lib/completion.zsh'
zinit snippet 'OMZ::lib/compfix.zsh'

# git
zinit ice as"program" pick"$ZPFX/bin/git-*" make"PREFIX=$ZPFX"
zinit light tj/git-extras
zinit light wfxr/forgit
zinit light babarot/emoji-cli
zinit ice as"command" from"gh-r" pick "ugit"
zinit load Bhupesh-V/ugit

# tools
zinit light "zpm-zsh/clipboard"

# finalize
zinit ice atload'_zsh_autosuggest_start'

autoload -U compinit
zmodload zsh/stat
ZCOMPDUMP=${ZDOTDIR:-$HOME}/.zcompdump
if [[ ! -f $ZCOMPDUMP ]] || (( $(date +%s) - $(zstat +mtime $ZCOMPDUMP 2>/dev/null || echo 0) > 86400 )); then
  compinit
else
  compinit -C
fi

zinit cdreplay -q
zinit cdlist

# fzf-tab has to be loaded after compinit
zinit light Aloxaf/fzf-tab
[ -n "$TMUX" ] && zstyle ':fzf-tab:*' fzf-command ftb-tmux-popup

# zsh-ssh must be loaded after fzf-tab to override ^I binding
zinit light "sunlei/zsh-ssh"

# Patch _parse_config_file to use 'realpath -s' for symlink compatibility (e.g. home-manager)
_parse_config_file() {
  setopt localoptions rematchpcre
  unsetopt nomatch
  local config_file_path=$(realpath -s "$1")
  while IFS= read -r line || [[ -n "$line" ]]; do
    if [[ $line =~ ^[Ii]nclude[[:space:]]+(.*) ]] && (( $#match > 0 )); then
      local include_paths=(${(z)match[1]})
      for raw_path in "${include_paths[@]}"; do
        local expanded=${~raw_path}
        if [[ "$expanded" != /* ]]; then
          expanded="$(dirname "$config_file_path")/$expanded"
        fi
        for include_file_path in $~expanded; do
          if [[ -f "$include_file_path" ]]; then
            echo ""
            _parse_config_file "$include_file_path"
          fi
        done
      done
    else
      echo "$line"
    fi
  done < "$config_file_path"
}
