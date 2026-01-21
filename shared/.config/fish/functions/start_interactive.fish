function start_interactive -d "Load interactive shell customizations (prompt, keybindings, etc.)"
    # Prompt configuration
    if type -q oh-my-posh
        # oh-my-posh prompt
        oh-my-posh init fish --config ~/.config/oh-my-posh/themes/custom.omp.yaml | source
    end

    # Vi-mode configuration
    fish_vi_key_bindings

    # Initialize vim mode env var for oh-my-posh and trigger event handler registration
    set -gx FISH__BIND_MODE $fish_bind_mode
    # Explicitly load the rerender function to ensure event handler is registered
    functions -q rerender_on_bind_mode_change; or source ~/.config/fish/functions/rerender_on_bind_mode_change.fish

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
