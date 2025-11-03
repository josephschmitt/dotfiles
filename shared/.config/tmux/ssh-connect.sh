#!/bin/sh
# Smart SSH connector that avoids tmux-in-tmux and tracks recent connections
# Usage: ssh-connect.sh <hostname>

HOST="$1"
RECENT_HOSTS="${XDG_CACHE_HOME:-$HOME/.cache}/tmux-ssh-recent"

# Exit if no host provided
if [ -z "$HOST" ]; then
    exit 0
fi

# Track this host in recent connections
mkdir -p "$(dirname "$RECENT_HOSTS")"
echo "$HOST" >> "$RECENT_HOSTS"

# Keep only last 100 entries (will be deduped on display)
if [ -f "$RECENT_HOSTS" ]; then
    tail -100 "$RECENT_HOSTS" > "${RECENT_HOSTS}.tmp"
    mv "${RECENT_HOSTS}.tmp" "$RECENT_HOSTS"
fi

# Check if we're inside tmux
if [ -n "$TMUX" ]; then
    # Save the current session name to reattach after SSH exits
    SESSION=$(tmux display-message -p '#S')
    
    # Detach from tmux, run SSH (which will use remote tmux), then reattach to local tmux
    # The -E flag runs the command after detaching
    # After SSH exits, we exec tmux attach to return to our session
    tmux detach-client -E "ssh -t '$HOST' 'tmux attach || tmux new -As main || exec \$SHELL -l' && exec tmux attach-session -t '$SESSION' || exec tmux attach-session -t '$SESSION'"
else
    # Not in tmux - connect directly
    # Still use smart tmux handling on remote side
    exec ssh -t "$HOST" 'tmux attach || tmux new -As main || exec $SHELL -l'
fi
