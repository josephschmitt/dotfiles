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
        set session_name "main"

        # If main session already exists, generate random name for new session
        if tmux has-session -t $session_name 2>/dev/null
            set session_name (random-session-name)
        end

        # Create new session and launch sesh popup
        # If tmux fails to start, fall back to regular shell
        tmux new-session -s $session_name \; run-shell "$TMUX_CONFIG_DIR/scripts/sesh-or-stay.sh '$session_name'"
    end
end

