# Fish Shell Configuration
# Personal configuration for Fish shell with development tools integration

source ~/.config/fish/env.fish
source ~/.config/fish/aliases.fish

# Interactive shell configuration
if status is-interactive
    # Auto-start tmux if available (skip for IDE/editor integrated terminals)
    if not set -q VSCODE_INJECTION; and not set -q INSIDE_EMACS
        auto_start_tmux
    end

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
        set -l omp_config ~/.config/oh-my-posh/themes/custom.omp.yaml
        set -l omp_cache ~/.cache/oh-my-posh-init.fish

        # Set a simple temporary prompt for instant shell readiness
        function fish_prompt
            echo -n (set_color cyan)(prompt_pwd)(set_color normal)' > '
        end

        # Load oh-my-posh asynchronously after the first prompt is displayed
        function _load_oh_my_posh --on-event fish_prompt
            # Only run once
            functions -e _load_oh_my_posh

            # Regenerate cache if missing or config is newer than cache
            if not test -f $omp_cache; or test $omp_config -nt $omp_cache
                mkdir -p (dirname $omp_cache)
                oh-my-posh init fish --config $omp_config > $omp_cache
            end

            # Source the cached initialization (much faster than generating)
            source $omp_cache
        end
    end

    # Suppress the default fish greeting
    set fish_greeting

    # Package managers
    if type -q basher
        . (basher init - fish | psub)
    end

    # Zoxide (smart directory jumper)
    if type -q zoxide
        zoxide init fish | source
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
end

# Fish-specific functions
function cdd
    cd ~/development/$argv[1]
end

# Load personal environment variables from .env
if test -f "$HOME/.env"
    load_env "$HOME/.env"
end

# Ghostty workaround for terminal compatibility
if test "$TERM_PROGRAM" = ghostty
    set -gx TERM xterm-256color
end

# Auto-load additional configuration modules
for config_file in ~/.config/fish/config.*.fish
    if test -f $config_file
        source $config_file
    end
end
