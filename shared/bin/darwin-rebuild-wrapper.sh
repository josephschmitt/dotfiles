#!/bin/bash

# Darwin rebuild wrapper that handles work submodule configurations
# This script determines the correct flake configuration based on hostname and submodule availability

set -e

# Get current hostname
HOSTNAME=$(hostname -s)

# Dynamically extract work machine hostnames from .nix files in work machines directory
WORK_MACHINES=()
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
WORK_MACHINES_DIR="$SCRIPT_DIR/../../work/.config/nix-darwin/machines"
if [[ -d "$WORK_MACHINES_DIR" ]]; then
  while IFS= read -r -d '' file; do
    hostname=$(basename "$file" .nix)
    WORK_MACHINES+=("$hostname")
  done < <(find "$WORK_MACHINES_DIR" -type f -name '*.nix' -print0)
fi

# Check if current hostname is a work machine
is_work_machine() {
  local hostname="$1"
  for work_host in "${WORK_MACHINES[@]}"; do
    if [[ "$hostname" == "$work_host" ]]; then
      return 0
    fi
  done
  return 1
}

# Check if work submodule is available and initialized
WORK_DIR="$SCRIPT_DIR/../../work"
WORK_AVAILABLE=false
if [[ -d "$WORK_DIR/.config/nix-darwin/machines" ]]; then
  WORK_AVAILABLE=true
fi

if is_work_machine "$HOSTNAME"; then
  if [[ "$WORK_AVAILABLE" == "true" ]]; then
    echo "Work machine detected with work configurations available, using impure evaluation..."
    sudo darwin-rebuild switch --impure --flake "git+file://$HOME/dotfiles?dir=shared/.config/nix-darwin&submodules=1#$HOSTNAME"
  else
    echo "ERROR: Work machine detected but work configurations not available!"
    echo "Please ensure the work submodule is initialized:"
    echo "  cd $HOME/dotfiles"
    echo "  git submodule update --init --recursive"
    exit 1
  fi
else
  echo "Personal machine detected, using pure evaluation..."
  sudo darwin-rebuild switch --flake "git+file://$HOME/dotfiles?dir=shared/.config/nix-darwin#$HOSTNAME"
fi

