#!/usr/bin/env bash
# install.sh — Initialize dotfiles: pre-create directories and run stow
#
# Usage:
#   ./install.sh shared personal          # Personal machine
#   ./install.sh shared work              # Work machine
#   ./install.sh shared ubuntu-server     # Ubuntu server
#   ./install.sh --dirs-only              # CI: only pre-create directories, skip stow
#
# Why directory pre-creation is required:
#   Stow symlinks entire directories unless they already exist at the target.
#   Pre-creating these directories forces stow to symlink individual files/subdirs
#   instead, which is required when multiple stow packages contribute to the same
#   parent directory (e.g., shared/ and personal/ both have .config/ contents).

set -e

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

# Parse flags
DIRS_ONLY=false
PROFILES=()

for arg in "$@"; do
  if [ "$arg" = "--dirs-only" ]; then
    DIRS_ONLY=true
  else
    PROFILES+=("$arg")
  fi
done

# Pre-create directories so stow symlinks individual files, not entire directories.
# Required when multiple stow packages contribute files to the same parent directory.
echo "Pre-creating directories for stow merging..."
mkdir -p "$HOME/.config/fish"
mkdir -p "$HOME/.config/shell"
mkdir -p "$HOME/.config/nix-darwin/machines"
mkdir -p "$HOME/.config/tmux"
mkdir -p "$HOME/.config/tmux/plugins"
mkdir -p "$HOME/.claude"
mkdir -p "$HOME/.ssh"
mkdir -p "$HOME/bin"

if $DIRS_ONLY; then
  echo "Done (--dirs-only: skipped stow)."
  exit 0
fi

# Default to 'shared' if no profiles given
if [ ${#PROFILES[@]} -eq 0 ]; then
  PROFILES=("shared")
fi

echo "Stowing profiles: ${PROFILES[*]}"
cd "$DOTFILES_DIR"
stow -v --target="$HOME" "${PROFILES[@]}"
