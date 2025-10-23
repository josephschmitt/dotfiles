#!/usr/bin/env bash
# Install shell startup tools for performance testing
# This script installs all tools that run on shell startup

set -e

echo "Installing shell startup tools..."

# Install oh-my-posh (default prompt)
echo "Installing oh-my-posh..."
curl -s https://ohmyposh.dev/install.sh | bash -s -- -d /usr/local/bin

# Install starship (optional prompt)
echo "Installing starship..."
curl -sS https://starship.rs/install.sh | sh -s -- -y

# Install zoxide (smart directory jumping)
echo "Installing zoxide..."
curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
if [ "$RUNNER_OS" = "Linux" ]; then
  sudo mv ~/.local/bin/zoxide /usr/local/bin/
fi

# Install fzf (fuzzy finder)
echo "Installing fzf..."
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install --bin
if [ "$RUNNER_OS" = "Linux" ]; then
  sudo mv ~/.fzf/bin/fzf /usr/local/bin/
fi

# Install basher (bash package manager)
echo "Installing basher..."
git clone --depth=1 https://github.com/basherpm/basher.git ~/.basher
echo 'export PATH="$HOME/.basher/bin:$PATH"' >> ~/.bashrc
export PATH="$HOME/.basher/bin:$PATH"

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
