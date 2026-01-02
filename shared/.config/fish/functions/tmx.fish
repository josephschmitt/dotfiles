function tmx
    # If no arguments provided, attach to last session
    if test (count $argv) -eq 0
        if test -n "$TMUX"
            # Already in tmux, can't attach - switch to last session instead
            tmux switch-client -l
        else
            # Not in tmux, attach to last used session
            tmux attach
        end
        return
    end

    # Directory-based session management (when argument provided)
    set -l dir $argv[1]
    cd $dir; or return 1
    set -l session_name (basename $dir)

    if test -n "$TMUX"
        # Already in tmux, switch to session instead of nesting
        tmux new-session -A -d -s $session_name
        tmux switch-client -t $session_name
    else
        # Not in tmux, start new session normally
        tmux new-session -A -s $session_name
    end
end