if [ -f $HOME/.bashrc ]; then
  source $HOME/.bashrc
fi

if [ "$TERM_PROGRAM" != "Apple_Terminal" ]; then
  eval "$(oh-my-posh init zsh --config $HOME/.config/oh-my-posh/themes/custom.omp.yaml)"
fi

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

# Add in zsh plugins
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab
zinit ice depth=1
zinit light jeffreytse/zsh-vi-mode

# Add in snippets
zinit snippet OMZP::sudo
zinit snippet OMZP::aws
zinit snippet OMZP::command-not-found

# Load completions
autoload -Uz compinit && compinit

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

# Aliases
alias ls='ls --color'
alias vim='nvim'
alias c='clear'

# Define the cdd function to change directories from ~/development
cdd() {
  cd ~/development/"$1"
}


# Shell integrations
eval "$(fzf --zsh)"
