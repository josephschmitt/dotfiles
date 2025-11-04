# Shared functions for all POSIX-compatible shells

start_interactive() {
  # Prompt configuration
  if command -v oh-my-posh >/dev/null 2>&1; then
    # oh-my-posh prompt for bash
    eval "$(oh-my-posh init bash --config ~/.config/oh-my-posh/themes/custom.omp.yaml)"
  fi

  # Zoxide smart directory jumping
  if command -v zoxide >/dev/null 2>&1; then
    eval "$(zoxide init bash)"
    
    # Override z with our custom version that triggers interactive on ambiguous queries
    # Set ZOXIDE_INTERACTIVE_THRESHOLD to control minimum matches needed (default: 2)
    z() {
      threshold="${ZOXIDE_INTERACTIVE_THRESHOLD:-2}"
      result_count=$(zoxide query --list -- "$@" 2>/dev/null | wc -l | tr -d ' ')
      if [ "$result_count" -ge "$threshold" ]; then
        result=$(zoxide query --interactive -- "$@")
        [ -n "$result" ] && cd "$result"
      else
        __zoxide_z "$@"
      fi
    }
  fi

  # Mark as loaded (only when inside tmux to skip in future tmux panes)
  if [ -n "$TMUX" ]; then
    export TMUX_INTERACTIVE_LOADED=1
  fi
}

# Change directories from ~/development
cdd() {
  cd ~/development/"$1" || exit
}

# Find the given path in zoxide, or enter interactive mode
zq() {
  zoxide query "$@" || zoxide query -i
}

# Convenience function to change directory and run twm
twmp() {
  target_dir="$(zq "${@:-$(pwd)}")"
  name="$(basename "$target_dir")"

  pushd "$target_dir" >/dev/null || return
  twm --path "$target_dir" --name "$name" --command nvim
  popd >/dev/null || return
}

# Check if running in an IDE/editor integrated terminal
is_integrated_terminal() {
  [ -n "$VSCODE_INJECTION" ] || \
  [ -n "$VSCODE_PID" ] || \
  [ "$TERM_PROGRAM" = "vscode" ] || \
  [ -n "$INSIDE_EMACS" ] || \
  [ -n "$ZED_TERM" ] || \
  [ -n "$NVIM" ] || \
  [ -n "$NVIM_LISTEN_ADDRESS" ]
}

# Auto-start tmux if available and not already inside tmux
auto_start_tmux() {
  # Skip in IDE/editor integrated terminals
  if is_integrated_terminal; then
    return
  fi
  
  # Check if tmux is available and we're not already in tmux or SSH
  if command -v tmux >/dev/null 2>&1 && [ -z "$TMUX" ] && [ -z "$SSH_CONNECTION" ]; then
    session_name="$(hostname -s)"
    
    # If hostname session exists and has no attached clients, just attach
    if tmux has-session -t "$session_name" 2>/dev/null; then
      attached_clients=$(tmux list-clients -t "$session_name" 2>/dev/null | wc -l)
      if [ "$attached_clients" -eq 0 ]; then
        tmux attach-session -t "$session_name" && exit
        return  # If attach failed, continue with normal shell
      fi

      # Session already attached, generate random name for new session
      session_name="$(random-session-name)"
    fi

    # Create new session and launch sesh popup
    # If tmux fails to start, fall back to regular shell
    tmux new-session -s "$session_name" \; run-shell "~/.config/tmux/sesh-or-stay.sh '$session_name'" && exit
  fi
}

# SSH wrapper that detaches from tmux before connecting
ssh() {
  if [ -n "$TMUX" ]; then
    # Detach from tmux and run SSH outside it
    tmux detach-client -E "command ssh $*"
  else
    # Not in tmux, just run SSH normally
    command ssh "$@"
  fi
}

# Launch tmux session with directory argument support
tmx() {
  local dir="${1:-$(pwd)}"
  cd "$dir" || return 1
  local session_name="$(basename "$dir")"
  
  if [ -n "$TMUX" ]; then
    # Already in tmux, switch to session instead of nesting
    if tmux has-session -t "$session_name" 2>/dev/null; then
      tmux switch-client -t "$session_name"
    else
      tmux-new-session "$session_name"
    fi
  else
    # Not in tmux, start new session normally
    tmux new-session -A -s "$session_name"
    exit
  fi
}
