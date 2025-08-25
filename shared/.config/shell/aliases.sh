# Shared aliases for all POSIX-compatible shells

# Navigation and utilities
alias groot="echo 'I am Groot!' && cd \$(git rev-parse --show-toplevel)"
alias lg="lazygit"
alias c="clear"
alias vim="nvim"
alias cat="bat"

# Nix and Darwin rebuild shortcuts
alias darwin_rebuild="~/dotfiles/shared/bin/darwin-rebuild-wrapper.sh"
alias darwin_update="nix flake update --flake ~/.config/nix-darwin"
alias nix_rebuild="nix profile upgrade personal/.config/nix"
alias nix_update="nix flake update --flake ~/dotfiles/personal/.config/nix && nix profile upgrade personal/.config/nix"
alias claude="~/.claude/local/claude"

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
