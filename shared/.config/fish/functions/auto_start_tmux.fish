function auto_start_tmux -d "Auto-start tmux if available and not already inside tmux"
    # Disabled by default since migrating to herdr.dev. Opt in with ENABLE_AUTO_TMUX=1.
    if not set -q ENABLE_AUTO_TMUX
        return
    end

    # Skip if SKIP_AUTO_TMUX is set (for performance testing)
    if set -q SKIP_AUTO_TMUX
        return
    end
    
    # Skip in IDE/editor integrated terminals
    if is_integrated_terminal
        return
    end
    
    # Check if tmux is available and we're not already in tmux or SSH
    if command -q tmux; and not set -q TMUX; and not set -q SSH_CONNECTION; and not set -q HERDR
        set session_name "main"

        # If main session already exists, generate random name for new session
        if tmux has-session -t $session_name 2>/dev/null
            set session_name (random-session-name)
        end

        # Default starting directory (fallback to $HOME if ~/development doesn't exist)
        set -l start_dir "$HOME/development"
        if not test -d $start_dir
            set start_dir "$HOME"
        end

        # Create new session. If tmux fails to start, fall back to regular shell
        tmux new-session -s $session_name -c $start_dir
    end
end

