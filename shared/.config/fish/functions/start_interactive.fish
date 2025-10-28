function start_interactive -d "Load interactive shell customizations (prompt, keybindings, etc.)"
    # Prompt configuration
    # Use Starship if USE_STARSHIP env var is set, otherwise use oh-my-posh (default)
    if set -q USE_STARSHIP; and type -q starship
        # Starship prompt (fast enough to init directly)
        starship init fish | source

        # Enable transient prompt (matches oh-my-posh behavior)
        # After command execution, previous prompts simplify to just the arrow
        function starship_transient_prompt_func
            starship module character
        end
        enable_transience
    else if type -q oh-my-posh
        # oh-my-posh prompt (default)
        oh-my-posh init fish --config ~/.config/oh-my-posh/themes/custom.omp.yaml | source
    end

    # Vi-mode configuration
    fish_vi_key_bindings

    # Reduce escape timeout for faster tmux navigation
    set fish_escape_delay_ms 10

    # Custom keybindings
    bind shift-u redo
    bind gh beginning-of-line
    bind gl end-of-line

    # Cursor shapes for different vi modes
    set fish_cursor_default block
    set fish_cursor_insert line
    set fish_cursor_replace_one underscore
    set fish_cursor_replace underscore
    set fish_cursor_external line
    set fish_cursor_visual block

    # Mark as loaded (only when inside tmux to skip in future tmux panes)
    if set -q TMUX
        set -gx TMUX_INTERACTIVE_LOADED 1
    end
end
