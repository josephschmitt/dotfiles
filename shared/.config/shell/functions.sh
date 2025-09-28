# Shared functions for all POSIX-compatible shells

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

# Auto-start tmux if available and not already inside tmux
auto_start_tmux() {
  # Check if tmux is available and we're not already in tmux or SSH
  if command -v tmux >/dev/null 2>&1 && [ -z "$TMUX" ] && [ -z "$SSH_CONNECTION" ]; then
    # Check if there's an existing tmux session
    if tmux has-session 2>/dev/null; then
      # Check if the session has any attached clients
      attached_clients=$(tmux list-clients 2>/dev/null | wc -l)
      if [ "$attached_clients" -eq 0 ]; then
        # No clients attached, safe to attach
        exec tmux attach-session
      else
        # Session has attached clients, create new session
        exec tmux new-session
      fi
    else
      # Create new session with hostname as name
      exec tmux new-session -s "$(hostname -s)"
    fi
  fi
}

# Launch tmux session with directory argument support
tmx() {
  local dir="${1:-$(pwd)}"
  cd "$dir" || return 1
  tmux new-session -A -s "$(basename "$dir")"
  exit
}
