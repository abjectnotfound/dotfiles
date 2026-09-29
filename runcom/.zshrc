# ============================================================================
# Zsh configuration
# ============================================================================
#
# This zshrc sources the shared dotfiles system/* files (functions, paths,
# environment, aliases, completions, etc.) exactly like runcom/.bash_profile
# does for bash. Zsh-specific setup (completion, vi mode, Starship prompt)
# lives below that.
#
# Replaces the old oh-my-zsh + Powerlevel10k setup.

# Resolve DOTFILES_DIR (same logic as .bash_profile; $0:A resolves symlinks)

CURRENT_SCRIPT=${0:A}
if [[ $0 == */* && -f $CURRENT_SCRIPT ]]; then
  DOTFILES_DIR=${CURRENT_SCRIPT:h:h}
fi
if [[ -z $DOTFILES_DIR || ! -d $DOTFILES_DIR/system ]]; then
  if [ -d "$HOME/.dotfiles" ]; then
    DOTFILES_DIR="$HOME/.dotfiles"
  elif [ -d "$HOME/dotfiles" ]; then
    DOTFILES_DIR="$HOME/dotfiles"
  else
    echo "Unable to find dotfiles, exiting."
    return
  fi
fi

# Make utilities available

PATH="$DOTFILES_DIR/bin:$PATH"

# Source the dotfiles (order matters)

[ -f "$DOTFILES_DIR/local/.profile" ] && . "$DOTFILES_DIR/local/.profile"
[ -f "$DOTFILES_DIR/local/.env" ] && . "$DOTFILES_DIR/local/.env"

# NULL_GLOB so unmatched patterns are skipped silently (bash leaves them as-is)

setopt NULL_GLOB
for DOTFILE in "$DOTFILES_DIR"/system/.{function,function_*,n,path,env,alias,fzf,grep,prompt,completion,fix,pnpm,zoxide}; do
  . "$DOTFILE"
done

if is-macos; then
  for DOTFILE in "$DOTFILES_DIR"/system/macos/.{env,alias,function}; do
    . "$DOTFILE"
  done
fi
unsetopt NULL_GLOB

# Zsh-specific setup

# Deduplicate PATH
typeset -U path PATH

# Docker CLI completions (before compinit so they get registered)
[ -d "$HOME/.docker/completions" ] && fpath=($HOME/.docker/completions $fpath)

# Completion
autoload -Uz compinit && compinit

# Vi key bindings
set -o vi

# Additional PATH entries
export GOPATH="$HOME/go"
export PATH="$PATH:$GOPATH/bin"
export PATH="$PATH:$HOME/.local/share/nvim/mason/bin"
export PATH="/opt/homebrew/opt/openjdk/bin:$PATH"

# GPG agent
GPG_TTY=$(tty)
export GPG_TTY

# fzf key bindings and fuzzy completion
source <(fzf --zsh)

# zsh plugins (brew-installed)
source "$HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
source "$HOMEBREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

# Ghostty shell integration
if [[ -n $GHOSTTY_RESOURCES_DIR ]]; then
  source "$GHOSTTY_RESOURCES_DIR"/shell-integration/zsh/ghostty-integration
fi

# Tool environments

[ -d "$HOME/.docker/bin" ] && export PATH="$PATH:$HOME/.docker/bin"
[ -f "$HOME/.local/share/bob/env/env.sh" ] && . "$HOME/.local/share/bob/env/env.sh"
export CLOUDSDK_PYTHON_SITEPACKAGES=1

# Homebrew cleanup
export HOMEBREW_CLEANUP_MAX_AGE_DAYS=30
export HOMEBREW_AUTOREMOVE=1

# Prompt and shell integrations

[ -f "$HOME/.atuin/bin/env" ] && . "$HOME/.atuin/bin/env"

command -v starship >/dev/null && eval "$(starship init zsh)"
command -v atuin >/dev/null && eval "$(atuin init zsh)"
command -v zoxide >/dev/null && eval "$(zoxide init zsh)"
command -v mise >/dev/null && eval "$(mise activate zsh)"
command -v thefuck >/dev/null && eval $(thefuck --alias)

# Wrap up

unset CURRENT_SCRIPT DOTFILE

export DOTFILES_DIR
export XDG_CONFIG_HOME="$HOME/.config"

# Custom functions

# Extract archives of any type
# https://github.com/xvoland/Extract/blob/master/extract.sh
extract() {
  if [ -z "$1" ]; then
    # display usage if no parameters given
    echo "Usage: extract <path/file_name>.<zip|rar|bz2|gz|tar|tbz2|tgz|Z|7z|xz|ex|tar.bz2|tar.gz|tar.xz>"
    echo "       extract <path/file_name_1.ext> [path/file_name_2.ext] [path/file_name_3.ext]"
    return 1
  else
    for n in $@
    do
      if [ -f "$n" ] ; then
          case "${n%,}" in
            *.tar.bz2|*.tar.gz|*.tar.xz|*.tbz2|*.tgz|*.txz|*.tar)
                         tar xvf "$n"       ;;
            *.lzma)      unlzma ./"$n"      ;;
            *.bz2)       bunzip2 ./"$n"     ;;
            *.rar)       unrar x -ad ./"$n" ;;
            *.gz)        gunzip ./"$n"      ;;
            *.zip)       unzip ./"$n"       ;;
            *.z)         uncompress ./"$n"  ;;
            *.7z|*.arj|*.cab|*.chm|*.deb|*.dmg|*.iso|*.lzh|*.msi|*.rpm|*.udf|*.wim|*.xar)
                         7z x ./"$n"        ;;
            *.xz)        unxz ./"$n"        ;;
            *.exe)       cabextract ./"$n"  ;;
            *)
                         echo "extract: '$n' - unknown archive method"
                         return 1
                         ;;
          esac
      else
          echo "'$n' - file does not exist"
          return 1
      fi
    done
  fi
}

# ripgrep -> fzf -> nvim [QUERY]
rfv() (
  RELOAD='reload:rg --column --color=always --smart-case {q} || :'
  OPENER='if [[ $FZF_SELECT_COUNT -eq 0 ]]; then
            nvim {1} +{2}     # No selection. Open the current line in nvim.
          else
            nvim +cw -q {+f}  # Build quickfix list for the selected items.
          fi'
  fzf --disabled --ansi --multi \
      --bind "start:$RELOAD" --bind "change:$RELOAD" \
      --bind "enter:become:$OPENER" \
      --bind "ctrl-o:execute:$OPENER" \
      --bind 'alt-a:select-all,alt-d:deselect-all,ctrl-/:toggle-preview' \
      --delimiter : \
      --preview 'bat --style=full --color=always --highlight-line {2} {1}' \
      --preview-window '~4,+{2}+4/3,<80(up)' \
      --query "$*"
)

# Custom aliases (shell-agnostic aliases in system/.alias)