# Shared aliases for all POSIX-compatible shells

# Navigation and utilities
alias groot="echo 'I am Groot!' && cd \$(git rev-parse --show-toplevel)"
alias lg="lazygit"
alias c="clear"
alias vim="nvim"

# Nix and Darwin rebuild shortcuts
alias darwin_rebuild="sudo darwin-rebuild switch --flake ~/.config/nix-darwin"
alias darwin_update="nix flake update --flake ~/.config/nix-darwin"
alias nix_rebuild="nix profile upgrade --all"
alias nix_update="nix flake update --flake ~/.config/nix"

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
