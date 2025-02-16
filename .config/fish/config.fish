setenv XDG_CONFIG_HOME "$HOME/.config"

# Set nix paths first to resolve before other paths (like homebrew)
set -gx PATH "$HOME/.nix-profile/bin" $PATH
set -gx PATH /run/current-system/sw/bin $PATH
set -gx PATH /nix/var/nix/profiles/default/bin $PATH

set -gx PATH "$HOME/.bun/bin" $PATH
set -gx PATH "$HOME/.cargo/bin" $PATH

# Configure basher https://github.com/basherpm/basher
if test -d ~/.basher ##basher5ea843
    set basher ~/.basher/bin ##basher5ea843
end ##basher5ea843
set -gx PATH $basher $PATH ##basher5ea843
status --is-interactive; and . (basher init - fish | psub) ##basher5ea843

setenv EDITOR hx

setenv DEBUG 1
setenv BASHLOG_FILE 1

if status is-interactive
    if type -q oh-my-posh
        # Initialize oh-my-posh
        oh-my-posh init fish --config ~/.config/oh-my-posh/themes/custom.omp.yaml | source
    end

    # Suppress the greeting
    set fish_greeting

    # Initialize basher
    if type -q basher
        . (basher init - fish | psub)
    end

    # Set up fzf
    fzf --fish | source
    setenv FZF_DEFAULT_COMMAND "fd --type f --hidden --follow --exclude={.git,OrbStack}"

    setenv ZELLIJ_CONFIG_DIR "$HOME/.config/zellij"
    setenv ZIDE_DEFAULT_LAYOUT compact_lazygit_focus

    alias zj="zellij -l welcome"
    setenv ZIDE_ALWAYS_NAME true
    setenv ZIDE_DEFAULT_LAYOUT default_lazygit
    setenv ZIDE_USE_YAZI_CONFIG false
end

# Add some more bin paths to PATH for custom bin scripts
set -gx PATH "$HOME/bin" $PATH
set -gx PATH "$HOME/go/bin" $PATH
set -gx PATH "$HOME/.local/bin" $PATH
set -gx PATH "$HOME/development/zide/bin" $PATH

alias gr="cd (git rev-parse --show-toplevel)"
alias zellij_clear="zellij list-sessions --no-formatting | awk '/EXITED/ {print \$1}' | xargs -n 1 zellij delete-session"
alias darwin_rebuild="darwin-rebuild switch --flake ~/dotfiles/.config/nix-darwin"
alias darwin_update="nix flake update --flake ~/dotfiles/.config/nix-darwin"

# Git-spice aliases
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

# pnpm
set -gx PNPM_HOME /Users/josephschmitt/Library/pnpm
if not string match -q -- $PNPM_HOME $PATH
    set -gx PATH "$PNPM_HOME" $PATH
end
# pnpm end

if type -q replay
    replay "source $HOME/.compassrc"
end

# direnv
if type -q direnv
    # If installed, source the direnv hook for Fish
    direnv hook fish | source
end
