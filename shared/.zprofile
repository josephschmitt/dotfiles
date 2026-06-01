# Zsh login shell profile
# On macOS, Terminal.app runs zsh as a login shell, so this file is sourced
# Keep this minimal since .zshenv already sources .profile

# OrbStack zsh-specific integration
if [ -f ~/.orbstack/shell/init.zsh ]; then
  # Added by OrbStack: command-line tools and integration
  source ~/.orbstack/shell/init.zsh 2>/dev/null || :
fi
if [ -f /Users/josephschmitt/.zshrc ]; then
  source /Users/josephschmitt/.zshrc
fi

# Source profile-specific overrides from .zprofile.d/
for config_file in "$HOME/.zprofile.d/"*.sh; do
  if [ -f "$config_file" ]; then
    . "$config_file"
  fi
done