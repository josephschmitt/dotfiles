#!/bin/sh
# Quick shell popup for herdr — press Ctrl-c twice within 2 seconds to close
# the popup by exiting the shell. Mirrors shared/.config/tmux/scripts/quick-shell.sh
# but swaps `tmux display-message` for `herdr notification show`.
# Usage: quick-shell.sh [--persist]
#   (default) exits automatically after a command completes successfully
#   --persist stays open until explicitly closed (double Ctrl-c or `exit`)

PERSIST=0
if [ "$1" = "--persist" ]; then
    PERSIST=1
fi

# Detect best available shell and hand off to it directly
if command -v fish >/dev/null 2>&1; then
    exec fish --init-command "
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
                # First Ctrl-c - update timestamp and show hint
                set -g __quick_shell_last_sigint \$now
                herdr notification show 'Quick Shell' --body 'Press Ctrl-c again to close popup' >/dev/null 2>&1
                commandline -f repaint
            end
        end

        # Hook that runs after each command
        function on_command_execute --on-event fish_postexec
            set -l cmd_status \$status

            # Only exit on success (status 0) in quick mode
            if test $PERSIST -eq 0; and test \$cmd_status -eq 0
                exit 0
            end
        end
    "
elif command -v zsh >/dev/null 2>&1; then
    ZSH_INIT="
        # oh-my-posh prompt
        if command -v oh-my-posh >/dev/null 2>&1; then
            eval \"\$(oh-my-posh init zsh --config ~/.config/oh-my-posh/themes/custom.omp.yaml)\"
        fi

        __quick_shell_last_sigint=0
        TRAPINT() {
            local now=\$(date +%s)
            local diff=\$((now - __quick_shell_last_sigint))
            if [ \$diff -le 2 ]; then
                exit 0
            else
                __quick_shell_last_sigint=\$now
                herdr notification show 'Quick Shell' --body 'Press Ctrl-c again to close popup' >/dev/null 2>&1
                return 128
            fi
        }
    "

    if [ "$PERSIST" -eq 0 ]; then
        ZSH_INIT="${ZSH_INIT}
            __quick_shell_ran_cmd=0
            preexec() { __quick_shell_ran_cmd=1; }
            precmd() {
                local last_status=\$?
                if [ \"\$__quick_shell_ran_cmd\" -eq 1 ] && [ \$last_status -eq 0 ]; then
                    exit 0
                fi
            }
        "
    fi

    ZDOTDIR=$(mktemp -d)
    printf '%s\nrm -rf "%s"\n' "$ZSH_INIT" "$ZDOTDIR" > "${ZDOTDIR}/.zshrc"
    export ZDOTDIR
    exec zsh -i
else
    BASH_INIT='
        [ -f "$HOME/.bashrc" ] && . "$HOME/.bashrc"

        __quick_shell_last_sigint=0
        __qs_handle_sigint() {
            local now=$(date +%s)
            local diff=$((now - __quick_shell_last_sigint))
            if [ $diff -le 2 ]; then
                exit 0
            else
                __quick_shell_last_sigint=$now
                herdr notification show "Quick Shell" --body "Press Ctrl-c again to close popup" >/dev/null 2>&1
            fi
        }
        trap __qs_handle_sigint INT
    '

    if [ "$PERSIST" -eq 0 ]; then
        BASH_INIT="${BASH_INIT}"'
            __quick_shell_ran_cmd=0
            __qs_prompt_command() {
                local last_status=$?
                if [ "$__quick_shell_ran_cmd" -eq 1 ] && [ $last_status -eq 0 ]; then
                    exit 0
                fi
                __quick_shell_ran_cmd=1
            }
            PROMPT_COMMAND="__qs_prompt_command;${PROMPT_COMMAND:-}"
        '
    fi

    BASH_RCFILE=$(mktemp)
    printf '%s\nrm -f "%s"\n' "$BASH_INIT" "$BASH_RCFILE" > "$BASH_RCFILE"
    exec bash --rcfile "$BASH_RCFILE"
fi
