# Shared aliases for all POSIX-compatible shells

# Navigation and utilities
alias c="clear"
alias cat="bat"
alias groot="echo 'I am Groot!' && cd \$(git rev-parse --show-toplevel)"
alias lg="env TMPDIR=/tmp lazygit"
alias lazyvim='nvim'
alias vim='NVIM_APPNAME=astronvim nvim'
alias nvim='NVIM_APPNAME=astronvim nvim'
alias astrovim='NVIM_APPNAME=astronvim nvim'
alias avim='NVIM_APPNAME=astronvim nvim'
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
