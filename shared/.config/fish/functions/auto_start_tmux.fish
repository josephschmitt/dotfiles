function auto_start_tmux -d "Auto-start tmux if available and not already inside tmux"
    # Check if tmux is available and we're not already in tmux or SSH
    if command -q tmux; and not set -q TMUX; and not set -q SSH_CONNECTION
        # Check if there's an existing tmux session
        if tmux has-session 2>/dev/null
            # Check if the session has any attached clients
            set attached_clients (tmux list-clients 2>/dev/null | wc -l)
            if test $attached_clients -eq 0
                # No clients attached, safe to attach
                exec tmux attach-session
            else
                # Session has attached clients, create new session
                exec tmux new-session
            end
        else
            # Create new session with hostname as name
            exec tmux new-session -s (hostname -s)
        end
    end
end

