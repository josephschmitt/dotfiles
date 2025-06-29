# Fish Shell Configuration
# Personal configuration for Fish shell with development tools integration

# XDG Base Directory Specification
setenv XDG_CONFIG_HOME "$HOME/.config"

# PATH Configuration
# Set nix paths first to resolve before other paths (like homebrew)
set -gx PATH "$HOME/.nix-profile/bin" $PATH
set -gx PATH /run/current-system/sw/bin $PATH
set -gx PATH /nix/var/nix/profiles/default/bin $PATH

# Development tools
set -gx PATH "$HOME/.bun/bin" $PATH
set -gx PATH "$HOME/.cargo/bin" $PATH

# Node.js version manager
setenv VOLTA_HOME "$HOME/.volta"
set -gx PATH "$VOLTA_HOME/bin" $PATH

# Default editor
setenv EDITOR nvim

# Interactive shell configuration
if status is-interactive
    # Prompt configuration
    if type -q oh-my-posh
        # Initialize oh-my-posh with custom theme
        oh-my-posh init fish --config ~/.config/oh-my-posh/themes/custom.omp.yaml | source
    end

    # Suppress the default fish greeting
    set fish_greeting

    # Package managers
    if type -q basher
        . (basher init - fish | psub)
    end

    # Fuzzy finder setup
    fzf --fish | source
    setenv FZF_DEFAULT_COMMAND "fd --type f --hidden --follow --exclude={.git,OrbStack}"

    # Terminal multiplexer configurations
    setenv ZELLIJ_CONFIG_DIR "$HOME/.config/zellij"
    setenv ZIDE_DEFAULT_LAYOUT compact_lazygit_focus
    setenv ZIDE_LAYOUT_DIR "$ZELLIJ_CONFIG_DIR/layouts/zide"

    setenv ZIDE_ALWAYS_NAME true
    setenv ZIDE_DEFAULT_LAYOUT default_lazygit
    setenv ZIDE_USE_YAZI_CONFIG false
    setenv ZIDE_USE_FOCUS_PLUGIN true

    setenv ZJ_ALWAYS_NAME true
    setenv ZJ_LAYOUTS_DIR $HOME/development/zj/layouts
    setenv ZJ_DEFAULT_LAYOUT ide

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

    # Smart directory jumping
    if type -q zoxide
        zoxide init fish | source
    end
end

# Additional PATH entries for custom tools
set -gx PATH "$HOME/bin" $PATH
set -gx PATH "$HOME/go/bin" $PATH
set -gx PATH "$HOME/.local/bin" $PATH
set -gx PATH "$HOME/development/zide/bin" $PATH
set -gx PATH "$HOME/development/zj/bin" $PATH

# Version manager configuration
if test -z $ASDF_DATA_DIR
    set _asdf_shims "$HOME/.asdf/shims"
else
    set _asdf_shims "$ASDF_DATA_DIR/shims"
end

# Useful aliases
alias groot="echo 'I am Groot!' && cd (git rev-parse --show-toplevel)"  # Navigate to git root
alias darwin_rebuild="sudo darwin-rebuild switch --flake ~/dotfiles/.config/nix-darwin"  # Rebuild Nix Darwin
alias darwin_update="nix flake update --flake ~/dotfiles/.config/nix-darwin"  # Update Nix Darwin flake
alias nix_rebuild="nix profile upgrade --all"  # Upgrade all Nix packages
alias nix_update="nix flake update --flake ~/dotfiles/.config/nix"  # Update Nix flake
alias lg="lazygit"  # Quick access to lazygit

# Git-spice workflow aliases
# Branch management
alias gsb="gs branch"
alias gsbc="gs branch checkout"
alias gsbcr="gs branch create"
alias gsbs="gs branch submit"
alias gsbt="gs branch track"

# Commit operations
alias gsc="gs commit"
alias gsca="gs commit amend"
alias gscc="gs commit commit"

# Log viewing
alias gsl="gs log long -a"
alias gsll="gs log long"
alias gsls="gs log short"

# Repository operations
alias gsr="gs repo"
alias gsrs="gs repo sync"

# Stack management
alias gss="gs stack"
alias gssr="gs stack restack"
alias gsss="gs stack submit"

# Package manager: pnpm
set -gx PNPM_HOME /Users/josephschmitt/Library/pnpm
if not string match -q -- $PNPM_HOME $PATH
    set -gx PATH "$PNPM_HOME" $PATH
end

# Environment loading with replay (for sensitive configs)
if type -q replay
    # Load work-specific configuration
    replay "source $HOME/.compassrc"

    # Load personal environment variables
    if test -f "$HOME/.env"
        replay "source $HOME/.env"
    end
end
