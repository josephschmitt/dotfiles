# Ubuntu Server specific aliases for POSIX shells

# Nix rebuild shortcuts for Ubuntu servers (override macOS darwin-rebuild)
alias nix_rebuild="nix profile upgrade ubuntu-server/.config/nix"
alias nix_update="nix flake update --flake ~/dotfiles/ubuntu-server/.config/nix && nix profile upgrade ubuntu-server/.config/nix"
