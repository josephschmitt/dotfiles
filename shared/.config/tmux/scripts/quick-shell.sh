#!/bin/sh
# Quick shell popup - runs one command and exits on success (by default)
# Usage: quick-shell.sh [--persist]

# Check for --persist flag
PERSIST=0
if [ "$1" = "--persist" ]; then
    PERSIST=1
fi

# Run Fish interactively with a custom config
fish --init-command "
    oh-my-posh init fish --config ~/.config/oh-my-posh/themes/custom.omp.yaml | source
    
    # Track Ctrl-c presses for double-tap exit
    set -g __quick_shell_last_sigint 0
    
    # Handle Ctrl-c (SIGINT)
    function __handle_sigint --on-signal SIGINT
        set -l now (date +%s)
        set -l time_diff (math \$now - \$__quick_shell_last_sigint)
        
        if test \$time_diff -le 2
            # Second Ctrl-c within 2 seconds - exit cleanly
            exit 0
        else
            # First Ctrl-c - update timestamp and show hint at bottom via tmux
            set -g __quick_shell_last_sigint \$now
            tmux display-message -d 2000 'Press Ctrl-c again to close popup'
            commandline -f repaint
        end
    end
    
    # Hook that runs after each command
    function on_command_execute --on-event fish_postexec
        # Debug: show what's happening
        set -l cmd_status \$status
        
        # Only exit on success (status 0) in quick mode
        if test $PERSIST -eq 0
            if test \$cmd_status -eq 0
                # Success - exit to close popup
                exit 0
            else
                # Failure - stay open and continue
                # Fish will show another prompt automatically
                return
            end
        end
        # Persist mode - never auto-exit
    end
"
# Capture fish exit code and always return 0 to tmux
exit 0
