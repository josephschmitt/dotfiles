#!/bin/sh
# Quick shell popup - runs one command and exits on success

# Run Fish interactively with a custom config that exits after first command
exec fish --init-command '
    function fish_prompt
        echo -n "⚡ "
    end
    
    # Hook that runs after each command
    function on_command_execute --on-event fish_postexec
        # Exit with the command status (popup closes on success)
        exit $status
    end
'
