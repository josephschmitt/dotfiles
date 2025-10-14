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
  # Skip in IDE/editor integrated terminals
  if [ -n "$VSCODE_INJECTION" ] || [ -n "$INSIDE_EMACS" ]; then
    return
  fi
  
  # Check if tmux is available and we're not already in tmux or SSH
  if command -v tmux >/dev/null 2>&1 && [ -z "$TMUX" ] && [ -z "$SSH_CONNECTION" ]; then
    session_name="$(hostname -s)"
    
    # Check if the hostname session exists
    if tmux has-session -t "$session_name" 2>/dev/null; then
      # Check if the session has any attached clients
      attached_clients=$(tmux list-clients -t "$session_name" 2>/dev/null | wc -l)
      if [ "$attached_clients" -eq 0 ]; then
        # No clients attached, safe to attach
        exec tmux attach-session -t "$session_name"
      else
        # Session has attached clients, create new session with random name
        adjectives="curious jumping happy clever brave swift quiet bright calm eager"
        animals="lemur lizard panda tiger eagle dolphin falcon rabbit otter ferret"
        adj=$(echo "$adjectives" | tr ' ' '\n' | shuf -n 1)
        animal=$(echo "$animals" | tr ' ' '\n' | shuf -n 1)
        exec tmux new-session -s "$adj-$animal"
      fi
    else
      # Create new session with hostname as name
      exec tmux new-session -s "$session_name"
    fi
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
    tmux new-session -A -d -s "$session_name"
    tmux switch-client -t "$session_name"
  else
    # Not in tmux, start new session normally
    tmux new-session -A -s "$session_name"
    exit
  fi
}
