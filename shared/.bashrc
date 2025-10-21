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

# Starship prompt for bash
if command -v starship >/dev/null 2>&1; then
  eval "$(starship init bash)"
fi

# Zoxide smart directory jumping
if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init bash)"
fi

# TWM shell completions (lazy-loaded)
twm() {
  unset -f twm
  eval "$(command twm --print-bash-completion)"
  command twm "$@"
}
