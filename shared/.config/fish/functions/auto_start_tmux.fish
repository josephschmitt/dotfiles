function auto_start_tmux -d "Auto-start tmux if available and not already inside tmux"
    # Skip if SKIP_AUTO_TMUX is set (for performance testing)
    if set -q SKIP_AUTO_TMUX
        return
    end
    
    # Skip in IDE/editor integrated terminals
    if is_integrated_terminal
        return
    end
    
    # Check if tmux is available and we're not already in tmux or SSH
    if command -q tmux; and not set -q TMUX; and not set -q SSH_CONNECTION
        set session_name (hostname -s)
        
        # If hostname session exists and has no attached clients, just attach
        if tmux has-session -t $session_name 2>/dev/null
            set attached_clients (tmux list-clients -t $session_name 2>/dev/null | wc -l | tr -d ' ')
            # Ensure we have a valid number (default to 1 if empty/invalid to show picker)
            if test -z "$attached_clients"
                set attached_clients 1
            end

            if test $attached_clients -eq 0
                tmux attach-session -t $session_name && exit
                return  # If attach failed, continue with normal shell
            end

            # Session already attached, generate random name for new session
            set session_name (random-session-name)
        end

        # Create new session and launch sesh popup
        # If tmux fails to start, fall back to regular shell
        tmux new-session -s $session_name \; run-shell "~/.config/tmux/sesh-or-stay.sh '$session_name'" && exit
    end
end

