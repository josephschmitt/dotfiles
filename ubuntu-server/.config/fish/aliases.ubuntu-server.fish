# Ubuntu Server specific aliases for Fish shell

# Nix rebuild shortcuts for Ubuntu servers
alias nix_rebuild="nix profile upgrade ~/dotfiles/ubuntu-server/.config/nix"
alias nix_update="nix flake update --flake ~/dotfiles/ubuntu-server/.config/nix && nix profile upgrade ~/dotfiles/ubuntu-server/.config/nix"