# Shared aliases for all POSIX-compatible shells

# Navigation and utilities
alias c="clear"
alias cat="bat"
alias groot="echo 'I am Groot!' && cd \$(git rev-parse --show-toplevel)"
alias lg="env TMPDIR=/tmp lazygit"
alias lazyvim='NVIM_APPNAME=lazyvim command nvim'
alias astrovim='NVIM_APPNAME=astronvim command nvim'
alias wm="workmux"

# Eza (modern ls replacement) aliases
alias ls="eza"
alias ll="eza -l"
alias la="eza -la"
alias lt="eza --tree"
alias tree="eza --tree"

# Nix rebuild shortcuts (nix-darwin on macOS)
alias nix_rebuild="~/dotfiles/shared/bin/darwin-rebuild-wrapper.sh"
alias nix_update="nix flake update --flake ~/dotfiles/shared/.config/nix-darwin"

# Git-spice workflow aliases
# Branch management
alias gsb="git-spice branch"
alias gsbc="git-spice branch checkout"
alias gsbcr="git-spice branch create"
alias gsbs="git-spice branch submit"
alias gsbt="git-spice branch track"

# Commit operations
alias gsc="git-spice commit"
alias gsca="git-spice commit amend"
alias gscc="git-spice commit commit"

# Log viewing
alias gsl="git-spice log long -a"
alias gsll="git-spice log long"
alias gsls="git-spice log short"

# Repository operations
alias gsr="git-spice repo"
alias gsrs="git-spice repo sync"

# Stack management
alias gss="git-spice stack"
alias gssr="git-spice stack restack"
alias gsss="git-spice stack submit"
