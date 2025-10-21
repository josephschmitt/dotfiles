# Zsh interactive shell configuration
# This file is sourced for interactive zsh sessions

# Enable nullglob for profile-specific file loading
setopt nullglob

# Source shared aliases and functions
if [ -f "$HOME/.config/shell/aliases.sh" ]; then
  . "$HOME/.config/shell/aliases.sh"
fi

if [ -f "$HOME/.config/shell/functions.sh" ]; then
  . "$HOME/.config/shell/functions.sh"
fi

# Auto-source profile-specific aliases (aliases.*.sh)
for config_file in "$HOME/.config/shell/aliases."*.sh; do
  if [ -f "$config_file" ]; then
    . "$config_file"
  fi
done

# Auto-source profile-specific functions (functions.*.sh)
for config_file in "$HOME/.config/shell/functions."*.sh; do
  if [ -f "$config_file" ]; then
    . "$config_file"
  fi
done

# Auto-start tmux if available
auto_start_tmux

# Prompt configuration (skip in Apple Terminal.app which has its own prompt)
# Use Starship if USE_STARSHIP env var is set, otherwise use oh-my-posh (default)
if [ "$TERM_PROGRAM" != "Apple_Terminal" ]; then
  if [ -n "$USE_STARSHIP" ] && command -v starship >/dev/null 2>&1; then
    # Starship prompt
    eval "$(starship init zsh)"

    # Enable transient prompt (built-in zsh option)
    setopt transient_prompt
  elif command -v oh-my-posh >/dev/null 2>&1; then
    # oh-my-posh prompt (default)
    eval "$(oh-my-posh init zsh --config $HOME/.config/oh-my-posh/themes/custom.omp.yaml)"
  fi
fi

# Zoxide smart directory jumping
if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh)"
fi

# Set the directory we want to store zinit and plugins
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

# ZVM keybindings
function zvm_after_lazy_keybindings() {
  bindkey -M vicmd 'U' redo
  bindkey -M vicmd 'gh' beginning-of-line
  bindkey -M vicmd 'gl' end-of-line
}

# ZVM Config
function zvm_config() {
  ZVM_NORMAL_MODE_CURSOR=$ZVM_CURSOR_BLOCK
  ZVM_INSERT_MODE_CURSOR=$ZVM_CURSOR_BEAM
  ZVM_VISUAL_MODE_CURSOR=$ZVM_CURSOR_UNDERLINE
  ZVM_VISUAL_LINE_MODE_CURSOR=$ZVM_CURSOR_BLOCK
  ZVM_OPPEND_MODE_CURSOR=$ZVM_CURSOR_USER_DEFAULT
}

function zvm_after_init() {
  [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
}

# Download Zinit, if it's not there yet
if [ ! -d "$ZINIT_HOME" ]; then
   mkdir -p "$(dirname $ZINIT_HOME)"
   git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

# Source/Load zinit
source "${ZINIT_HOME}/zinit.zsh"

# Add in zsh plugins (with turbo-mode for faster startup)
zinit ice wait lucid
zinit light zsh-users/zsh-syntax-highlighting
zinit ice wait lucid
zinit light zsh-users/zsh-autosuggestions
zinit ice wait lucid
zinit light Aloxaf/fzf-tab
zinit light zsh-users/zsh-completions
zinit ice depth=1
zinit light jeffreytse/zsh-vi-mode

# Add in snippets
zinit ice wait lucid
zinit snippet OMZP::sudo
zinit ice wait lucid
zinit snippet OMZP::aws
zinit ice wait lucid
zinit snippet OMZP::command-not-found

# Load completions with daily caching
autoload -Uz compinit
if [[ -n ${ZDOTDIR}/.zcompdump(#qN.mh+24) ]]; then
  compinit
else
  compinit -C
fi

# Replay all cached completions
zinit cdreplay -q

# Keybindings
bindkey '^[[A' history-search-backward # Up arrow
bindkey '^[[B' history-search-forward # Down arrow

# Completion history tweaks to be more like fish
HISTSIZE=5000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

# Completion styling
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}' # Case-insensitive completion
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}" # Use LS_COLORS for completion colors
zstyle ':completion:*' menu no # Disable completion menu since we're using fzf
zstyle ':completion:*:*:cdd:*' tag-order 'directories' # Completions for cdd

# Zsh-specific aliases  
# ls alias is now provided by shared aliases (eza)

# Shell integrations (lazy-loaded)
fzf() {
  unfunction fzf
  eval "$(command fzf --zsh)"
  command fzf "$@"
}

# TWM shell completions (lazy-loaded)
twm() {
  unfunction twm
  eval "$(command twm --print-zsh-completion)"
  command twm "$@"
}
