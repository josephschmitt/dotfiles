# Ubuntu Server specific environment variables for POSIX shells

# NPM global packages (needed for Nix-installed node with read-only store)
export NPM_CONFIG_PREFIX="$HOME/.npm-global"
export PATH="$HOME/.npm-global/bin:$PATH"
