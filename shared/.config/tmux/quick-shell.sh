#!/bin/sh
# Quick shell popup - runs one command and exits on success (by default)
# Usage: quick-shell.sh [--persist]

# Check for --persist flag
PERSIST=0
if [ "$1" = "--persist" ]; then
    PERSIST=1
fi

# Run Fish interactively with a custom config
exec fish --init-command "
    function fish_prompt
        echo -n '⚡ '
    end
    
    # Track Ctrl-c presses for double-tap exit
    set -g __quick_shell_last_sigint 0
    
    # Handle Ctrl-c (SIGINT)
    function __handle_sigint --on-signal SIGINT
        set -l now (date +%s)
        set -l time_diff (math \$now - \$__quick_shell_last_sigint)
        
        if test \$time_diff -le 2
            # Second Ctrl-c within 2 seconds - exit
            exit 130
        else
            # First Ctrl-c - update timestamp and show hint at bottom via tmux
            set -g __quick_shell_last_sigint \$now
            tmux display-message -d 2000 'Press Ctrl-c again to close popup'
            commandline -f repaint
        end
    end
    
    # Hook that runs after each command
    function on_command_execute --on-event fish_postexec
        # Exit with the command status (popup closes on success) unless --persist
        if test $PERSIST -eq 0
            exit \$status
        end
    end
"
