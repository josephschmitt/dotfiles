function auto_start_tmux -d "Auto-start tmux if available and not already inside tmux"
    # Skip in IDE/editor integrated terminals
    if set -q VSCODE_INJECTION; or set -q INSIDE_EMACS; or set -q VSCODE_PID; or test "$TERM_PROGRAM" = "vscode"
        return
    end
    
    # Check if tmux is available and we're not already in tmux or SSH
    if command -q tmux; and not set -q TMUX; and not set -q SSH_CONNECTION
        set session_name (hostname -s)
        
        # If hostname session exists and has attached clients, generate random name for new session
        if tmux has-session -t $session_name 2>/dev/null
            set attached_clients (tmux list-clients -t $session_name 2>/dev/null | wc -l)
            if test $attached_clients -gt 0
                set adjectives "curious" "jumping" "happy" "clever" "brave" "swift" "quiet" "bright" "calm" "eager"
                set animals "lemur" "lizard" "panda" "tiger" "eagle" "dolphin" "falcon" "rabbit" "otter" "ferret"
                set adj (random choice $adjectives)
                set animal (random choice $animals)
                set session_name "$adj-$animal"
            end
        end
        
        # Create new session and launch sesh popup
        exec tmux new-session -s $session_name \; run-shell "~/.config/tmux/sesh-or-stay.sh '$session_name'"
    end
end

