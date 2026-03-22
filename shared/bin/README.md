# Shared Utilities

This directory contains utility scripts available across all profiles.

## Utilities

### darwin-rebuild-wrapper.sh
Wrapper for nix-darwin rebuild operations (macOS only). Called via the `nix_rebuild` alias.

### helix-*.sh
Various Helix editor integration scripts

### immich-sync
Automated Apple Photos → Immich sync script (macOS only, mac-mini)
See `.config/immich-sync/README.md` for setup and usage

### bubble
Interactive dialog wrapper around [gum](https://github.com/charmbracelet/gum). Prompts for user input (text, choice, confirmation) and runs a command with the result. Works standalone or inside tmux popups.

### assign_at_random.sh
Random assignment utility

### listCatalogInfo.sh
Catalog information listing utility