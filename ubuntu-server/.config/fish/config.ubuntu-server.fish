# Ubuntu Server specific Fish shell configuration

# NPM global packages (needed for Nix-installed node with read-only store)
setenv NPM_CONFIG_PREFIX "$HOME/.npm-global"
fish_add_path --global --prepend "$HOME/.npm-global/bin"

# Source Ubuntu-specific aliases (overrides shared aliases)
source ~/.config/fish/aliases.ubuntu-server.fish
