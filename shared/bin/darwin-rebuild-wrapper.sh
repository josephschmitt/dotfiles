#!/bin/bash

# Darwin rebuild wrapper that handles private profile submodule configurations
# This script determines the correct flake configuration based on hostname and submodule availability

set -e

# Get current hostname
HOSTNAME=$(hostname -s)

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Scan all private profile submodule directories for machine configs
PRIVATE_PROFILE_MACHINES=()
PRIVATE_PROFILES_AVAILABLE=false

for profile in work rca; do
  machines_dir="$SCRIPT_DIR/../../$profile/.config/nix-darwin/machines"
  if [[ -d "$machines_dir" ]]; then
    PRIVATE_PROFILES_AVAILABLE=true
    while IFS= read -r -d '' file; do
      PRIVATE_PROFILE_MACHINES+=("$(basename "$file" .nix)")
    done < <(find "$machines_dir" -type f -name '*.nix' -print0)
  fi
done

# Check if current hostname is a private profile machine
is_private_profile_machine() {
  local hostname="$1"
  for private_host in "${PRIVATE_PROFILE_MACHINES[@]}"; do
    if [[ "$hostname" == "$private_host" ]]; then
      return 0
    fi
  done
  return 1
}

if is_private_profile_machine "$HOSTNAME"; then
  if [[ "$PRIVATE_PROFILES_AVAILABLE" == "true" ]]; then
    echo "Private profile machine detected with configurations available, using impure evaluation..."
    sudo darwin-rebuild switch --impure --flake "git+file://$HOME/dotfiles?dir=shared/.config/nix-darwin&submodules=1#$HOSTNAME"
  else
    echo "ERROR: Private profile machine detected but configurations not available!"
    echo "Please ensure the relevant private submodule is initialized:"
    echo "  cd $HOME/dotfiles"
    echo "  git submodule update --init --recursive"
    exit 1
  fi
else
  echo "Personal machine detected, using pure evaluation..."
  sudo darwin-rebuild switch --flake "git+file://$HOME/dotfiles?dir=shared/.config/nix-darwin#$HOSTNAME"
fi
