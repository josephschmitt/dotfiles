#!/usr/bin/env bash
# Install shell startup tools for performance testing
# This script installs all tools that run on shell startup

set -e

# Add user local bin directories to PATH for tool installations
export PATH="$HOME/.local/bin:$HOME/.fzf/bin:$PATH"

echo "Installing shell startup tools..."

# Install oh-my-posh (default prompt)
echo "Installing oh-my-posh..."
curl -s https://ohmyposh.dev/install.sh | bash -s -- -d /usr/local/bin

# Install starship (optional prompt)
echo "Installing starship..."
curl -sS https://starship.rs/install.sh | sh -s -- -y

# Install zoxide (smart directory jumping)
echo "Installing zoxide..."
if [ "$RUNNER_OS" = "macOS" ]; then
  brew install zoxide
else
  curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
  sudo mv ~/.local/bin/zoxide /usr/local/bin/
fi

# Install fzf (fuzzy finder)
echo "Installing fzf..."
if [ "$RUNNER_OS" = "macOS" ]; then
  brew install fzf
else
  git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
  ~/.fzf/install --bin
  sudo mv ~/.fzf/bin/fzf /usr/local/bin/
fi

# Install basher (bash package manager)
echo "Installing basher..."
git clone --depth=1 https://github.com/basherpm/basher.git ~/.basher
echo 'export PATH="$HOME/.basher/bin:$PATH"' >> ~/.bashrc
export PATH="$HOME/.basher/bin:$PATH"

# Pre-create directories that need to be merged across stow packages
# This forces stow to symlink individual files/subdirs instead of the entire directory
echo ""
echo "Pre-creating directories for stow package merging..."
mkdir -p "$HOME/.config/fish"
mkdir -p "$HOME/.config/shell"
mkdir -p "$HOME/.config/nix"
mkdir -p "$HOME/.config/nix-darwin"
mkdir -p "$HOME/bin"

# Verify installations
echo ""
echo "Verifying installations..."
oh-my-posh version
starship --version
zoxide --version
fzf --version
basher help

echo ""
echo "All startup tools installed successfully!"
