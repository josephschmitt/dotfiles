function auto_start_tmux -d "Auto-start tmux if available and not already inside tmux"
    # Check if tmux is available and we're not already in tmux or SSH
    if command -q tmux; and not set -q TMUX; and not set -q SSH_CONNECTION
        set session_name (hostname -s)
        
        # Check if the hostname session exists
        if tmux has-session -t $session_name 2>/dev/null
            # Check if the session has any attached clients
            set attached_clients (tmux list-clients -t $session_name 2>/dev/null | wc -l)
            if test $attached_clients -eq 0
                # No clients attached, safe to attach
                exec tmux attach-session -t $session_name
            else
                # Session has attached clients, create new session with auto name
                exec tmux new-session
            end
        else
            # Create new session with hostname as name
            exec tmux new-session -s $session_name
        end
    end
end

