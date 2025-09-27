function auto_start_tmux -d "Auto-start tmux if available and not already inside tmux"
    # Check if tmux is available and we're not already in tmux or SSH
    if command -q tmux; and not set -q TMUX; and not set -q SSH_CONNECTION
        # Check if there's an existing tmux session
        if tmux has-session 2>/dev/null
            # Attach to existing session
            exec tmux attach-session
        else
            # Create new session with hostname as name
            exec tmux new-session -s (hostname)
        end
    end
end