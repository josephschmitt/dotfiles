# Fish Shell Configuration
# Personal configuration for Fish shell with development tools integration

# Environment Variables (Fish-specific syntax)
setenv XDG_CONFIG_HOME "$HOME/.config"
setenv EDITOR nvim
setenv BAT_THEME tokyonight_night

# Zellij configuration
setenv ZJ_ALWAYS_NAME true
setenv ZJ_DEFAULT_LAYOUT ide
setenv ZJ_LAYOUTS_DIR $HOME/development/zj/layouts

# PATH Configuration
# Nix paths (set first to resolve before other paths like homebrew)
set -gx PATH "$HOME/.nix-profile/bin" $PATH
set -gx PATH /run/current-system/sw/bin $PATH
set -gx PATH /nix/var/nix/profiles/default/bin $PATH

# Package managers and development tools
set -gx PATH /opt/homebrew/bin $PATH
set -gx PATH "$HOME/.bun/bin" $PATH
set -gx PATH "$HOME/.cargo/bin" $PATH

# Node.js version manager
setenv VOLTA_HOME "$HOME/.volta"
set -gx PATH "$VOLTA_HOME/bin" $PATH

# Custom bin directories
set -gx PATH "$HOME/bin" $PATH
set -gx PATH "$HOME/go/bin" $PATH
set -gx PATH "$HOME/.local/bin" $PATH
set -gx PATH "$HOME/development/zide/bin" $PATH
set -gx PATH "$HOME/development/zj/bin" $PATH

# ASDF version manager
if test -z $ASDF_DATA_DIR
    set _asdf_shims "$HOME/.asdf/shims"
else
    set _asdf_shims "$ASDF_DATA_DIR/shims"
end
set -gx PATH $_asdf_shims $PATH

# PNPM package manager
set -gx PNPM_HOME /Users/josephschmitt/Library/pnpm
if not string match -q -- $PNPM_HOME $PATH
    set -gx PATH "$PNPM_HOME" $PATH
end

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

    # Completions for twm
    twm --print-fish-completion | source

    # Smart directory jumping
    if type -q zoxide
        zoxide init fish | source
    end
end

# Fish-specific aliases and functions
alias groot="echo 'I am Groot!' && cd (git rev-parse --show-toplevel)"
alias darwin_rebuild="~/dotfiles/shared/bin/darwin-rebuild-wrapper.sh"
alias darwin_update="nix flake update --flake ~/dotfiles/shared/.config/nix-darwin"
alias nix_rebuild="nix profile upgrade ~/dotfiles/shared/.config/nix"
alias nix_update="nix flake update ~/dotfiles/shared/.config/nix && nix profile upgrade ~/dotfiles/shared/.config/nix"
alias lg="lazygit"
alias c="clear"
alias vim="nvim"
alias claude="~/.claude/local/claude"
alias cat="bat"

# Git-spice workflow aliases
alias gsb="gs branch"
alias gsbc="gs branch checkout"
alias gsbcr="gs branch create"
alias gsbs="gs branch submit"
alias gsbt="gs branch track"
alias gsc="gs commit"
alias gsca="gs commit amend"
alias gscc="gs commit commit"
alias gsl="gs log long -a"
alias gsll="gs log long"
alias gsls="gs log short"
alias gsr="gs repo"
alias gsrs="gs repo sync"
alias gss="gs stack"
alias gssr="gs stack restack"
alias gsss="gs stack submit"

# Fish-specific functions
function cdd
    cd ~/development/$argv[1]
end

# Environment loading with replay (for sensitive configs)
if type -q replay
    # Load work-specific configuration (if available)
    if test -f "$HOME/.compassrc"
        replay "source $HOME/.compassrc"
    end

    # Load personal environment variables
    if test -f "$HOME/.env"
        replay "source $HOME/.env"
    end
end

# Ghostty workaround for terminal compatibility
if test $TERM_PROGRAM = ghostty
    set -gx TERM xterm-256color
end

# Added by LM Studio CLI (lms)
set -gx PATH $PATH /Users/josephschmitt/.lmstudio/bin
# End of LM Studio CLI section
