# Bash interactive shell configuration
# This file is sourced for interactive bash sessions

# Source shared aliases and functions
if [ -f "$HOME/.config/shell/aliases.sh" ]; then
  . "$HOME/.config/shell/aliases.sh"
fi

if [ -f "$HOME/.config/shell/functions.sh" ]; then
  . "$HOME/.config/shell/functions.sh"
fi

# Auto-source profile-specific aliases (aliases.*.sh)
for config_file in "$HOME/.config/shell/aliases."*.sh; do
  # Skip if glob didn't match any files (contains literal *)
  case "$config_file" in
    *"*"*) continue ;;
  esac
  if [ -f "$config_file" ]; then
    . "$config_file"
  fi
done

# Auto-source profile-specific functions (functions.*.sh)
for config_file in "$HOME/.config/shell/functions."*.sh; do
  # Skip if glob didn't match any files (contains literal *)
  case "$config_file" in
    *"*"*) continue ;;
  esac
  if [ -f "$config_file" ]; then
    . "$config_file"
  fi
done

# Auto-start tmux if available
auto_start_tmux

# Prompt configuration
# Use Starship if USE_STARSHIP env var is set, otherwise use oh-my-posh (default)
if [ -n "$USE_STARSHIP" ] && command -v starship >/dev/null 2>&1; then
  # Starship prompt for bash
  eval "$(starship init bash)"
elif command -v oh-my-posh >/dev/null 2>&1; then
  # oh-my-posh prompt for bash (default)
  eval "$(oh-my-posh init bash --config ~/.config/oh-my-posh/themes/custom.omp.yaml)"
fi

# Zoxide smart directory jumping
if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init bash)"
  
  # Override z with our custom version that triggers interactive on ambiguous queries
  z() {
    result_count=$(zoxide query --list -- "$@" 2>/dev/null | wc -l | tr -d ' ')
    if [ "$result_count" -gt 1 ]; then
      result=$(zoxide query --interactive -- "$@")
      [ -n "$result" ] && cd "$result"
    else
      __zoxide_z "$@"
    fi
  }
fi

# TWM shell completions (lazy-loaded)
twm() {
  unset -f twm
  eval "$(command twm --print-bash-completion)"
  command twm "$@"
}
