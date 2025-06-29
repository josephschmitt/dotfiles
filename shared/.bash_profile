# Bash login shell profile
# Source the main profile for environment setup
if [ -f "$HOME/.profile" ]; then
  . "$HOME/.profile"
fi

# Source bashrc for interactive configuration
if [ -f "$HOME/.bashrc" ]; then
  . "$HOME/.bashrc"
fi
