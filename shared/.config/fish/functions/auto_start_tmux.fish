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
        tmx --new
        # Note: tmx --new will exit if successful, so anything after this won't run
    end
end

