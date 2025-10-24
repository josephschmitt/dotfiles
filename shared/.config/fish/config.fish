# Fish Shell Configuration
# Personal configuration for Fish shell with development tools integration

source ~/.config/fish/env.fish
source ~/.config/fish/aliases.fish

# Interactive shell configuration
if status is-interactive
    # Load interactive customizations first (before tmux auto-start)
    # Only skip if we're inside tmux AND already loaded
    if not set -q TMUX; or not set -q TMUX_INTERACTIVE_LOADED
        start_interactive
    end

    # Auto-start tmux if available (skip for IDE/editor integrated terminals)
    if not set -q VSCODE_INJECTION; and not set -q INSIDE_EMACS
        auto_start_tmux
    end
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
