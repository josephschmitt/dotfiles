# Bash interactive shell configuration
# This file is sourced for interactive bash sessions

# Source shared aliases and functions
if [ -f "$HOME/.config/shell/aliases.sh" ]; then
  . "$HOME/.config/shell/aliases.sh"
fi

if [ -f "$HOME/.config/shell/functions.sh" ]; then
  . "$HOME/.config/shell/functions.sh"
fi

# Oh-my-posh prompt for bash
if command -v oh-my-posh >/dev/null 2>&1; then
  eval "$(oh-my-posh init bash --config ~/.config/oh-my-posh/themes/custom.omp.yaml)"
fi

# Bash-specific aliases
alias ls='ls --color=auto'

# TWM shell completions
eval "$(twm --print-bash-completion)"
