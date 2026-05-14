#!/usr/bin/env bash
# install.sh — Initialize dotfiles: pre-create directories and run stow
#
# Usage:
#   ./install.sh shared personal          # Personal machine (stow only)
#   ./install.sh shared work              # Work machine (stow only)
#   ./install.sh shared rca               # RCA machine (stow only)
#   ./install.sh shared ubuntu-server     # Ubuntu server (stow only)
#   ./install.sh --dirs-only              # CI: only pre-create directories, skip stow
#   ./install.sh --bootstrap              # Fresh machine: install Nix, nix-darwin,
#                                         #   etc., then stow + TPM (interactive)
#   ./install.sh --bootstrap shared work  # Bootstrap with profiles pre-selected
#   ./install.sh --bootstrap shared rca   # Bootstrap with profiles pre-selected
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
BOOTSTRAP=false
PROFILES=()

for arg in "$@"; do
  case "$arg" in
    --dirs-only) DIRS_ONLY=true ;;
    --bootstrap) BOOTSTRAP=true ;;
    *) PROFILES+=("$arg") ;;
  esac
done

# ---------------------------------------------------------------------------
# Interactive helpers — prefer `gum` when available (installed via nix-darwin),
# fall back to plain read so first-run before nix-darwin still works.
# ---------------------------------------------------------------------------

prompt() {
  # prompt "Question" "default"   — echoes the answer on stdout
  local question="$1" default="${2:-}"
  if command -v gum >/dev/null 2>&1; then
    gum input --prompt "$question " --value "$default"
  else
    local reply
    if [ -n "$default" ]; then
      printf '%s [%s]: ' "$question" "$default" >&2
    else
      printf '%s: ' "$question" >&2
    fi
    read -r reply
    printf '%s' "${reply:-$default}"
  fi
}

confirm() {
  # confirm "Question"   — exits 0 on yes, 1 on no. Defaults to No.
  local question="$1"
  if command -v gum >/dev/null 2>&1; then
    gum confirm "$question"
  else
    local reply
    printf '%s [y/N]: ' "$question" >&2
    read -r reply
    [ "$reply" = "y" ] || [ "$reply" = "Y" ]
  fi
}

info() { printf '\n\033[1;34m==>\033[0m %s\n' "$*"; }
ok()   { printf '\033[0;32m✓\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m!\033[0m %s\n' "$*" >&2; }

# ---------------------------------------------------------------------------
# Bootstrap steps (only run with --bootstrap)
# ---------------------------------------------------------------------------

IS_DARWIN=false
[ "$(uname -s)" = "Darwin" ] && IS_DARWIN=true

bootstrap_xcode_clt() {
  $IS_DARWIN || return 0
  if xcode-select -p >/dev/null 2>&1; then
    ok "Xcode Command Line Tools already installed"
    return 0
  fi
  info "Installing Xcode Command Line Tools (GUI prompt will appear)"
  xcode-select --install || true
  printf 'Press enter after the Xcode CLT installer finishes... ' >&2
  read -r _
}

bootstrap_apt_prereqs() {
  $IS_DARWIN && return 0
  command -v apt-get >/dev/null 2>&1 || return 0
  if command -v git >/dev/null 2>&1 && command -v curl >/dev/null 2>&1; then
    ok "apt prerequisites already installed"
    return 0
  fi
  info "Installing apt prerequisites (git, curl, ca-certificates)"
  sudo apt-get update -qq
  sudo apt-get install -y -qq git curl ca-certificates
}

bootstrap_convert_to_repo() {
  if git -C "$DOTFILES_DIR" rev-parse --git-dir >/dev/null 2>&1; then
    ok "Dotfiles directory is already a git repository"
    return 0
  fi
  info "Dotfiles directory is not a git repo (likely unzipped) — converting"
  local remote
  remote="$(prompt "Git remote URL" "git@github.com:josephschmitt/dotfiles.git")"
  git -C "$DOTFILES_DIR" init -q
  git -C "$DOTFILES_DIR" remote add origin "$remote"
  if ! git -C "$DOTFILES_DIR" fetch origin; then
    warn "Fetch failed — leaving repo initialized but unsynced"
    return 0
  fi
  local default_branch
  default_branch="$(git -C "$DOTFILES_DIR" symbolic-ref --short refs/remotes/origin/HEAD 2>/dev/null | sed 's|^origin/||')"
  [ -z "$default_branch" ] && default_branch="main"
  if confirm "Reset working tree to origin/$default_branch? (overwrites unzipped contents)"; then
    git -C "$DOTFILES_DIR" checkout -B "$default_branch" "origin/$default_branch"
    ok "Repo synced to origin/$default_branch"
  else
    warn "Skipped reset — repo is initialized but working tree differs from origin/$default_branch"
  fi
}

bootstrap_ssh_key() {
  if ls "$HOME/.ssh"/id_ed25519 "$HOME/.ssh"/id_rsa 2>/dev/null | grep -q .; then
    ok "SSH key already exists"
    return 0
  fi
  info "Generating SSH key (ed25519)"
  local email
  email="$(git config --global user.email 2>/dev/null || true)"
  [ -z "$email" ] && email="$(whoami)@$(hostname -s)"
  mkdir -p "$HOME/.ssh"
  chmod 700 "$HOME/.ssh"
  ssh-keygen -t ed25519 -C "$email" -f "$HOME/.ssh/id_ed25519" -N ""
  info "Your public key:"
  cat "$HOME/.ssh/id_ed25519.pub"
  printf '\nAdd it to GitHub (https://github.com/settings/ssh/new), then press enter to continue... ' >&2
  read -r _
}

bootstrap_hostname() {
  $IS_DARWIN || return 0
  local current new
  current="$(hostname -s)"
  info "Current hostname: $current"
  if confirm "Rename this machine? (used as nix-darwin config key)"; then
    new="$(prompt "New hostname (short, no spaces)" "$current")"
    if [ -n "$new" ] && [ "$new" != "$current" ]; then
      sudo scutil --set HostName "$new"
      sudo scutil --set LocalHostName "$new"
      sudo scutil --set ComputerName "$new"
      dscacheutil -flushcache 2>/dev/null || true
      ok "Hostname set to $new"
    fi
  fi
  HOSTNAME="$(hostname -s)"
}

bootstrap_nix() {
  if command -v nix >/dev/null 2>&1; then
    ok "Nix already installed"
    return 0
  fi
  info "Installing Nix (Determinate installer)"
  curl -fsSL https://install.determinate.systems/nix | sh -s -- install --determinate
  # Source the daemon profile so the rest of the script sees `nix`.
  # shellcheck disable=SC1091
  if [ -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]; then
    . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
  fi
}

bootstrap_machine_config() {
  $IS_DARWIN || return 0
  local host="${HOSTNAME:-$(hostname -s)}"
  local machines_dir="$DOTFILES_DIR/shared/.config/nix-darwin/machines"
  local target="$machines_dir/$host.nix"
  if [ -f "$target" ]; then
    ok "Machine config exists: shared/.config/nix-darwin/machines/$host.nix"
    return 0
  fi
  local arch platform
  arch="$(uname -m)"
  case "$arch" in
    arm64|aarch64) platform="aarch64-darwin" ;;
    x86_64)        platform="x86_64-darwin" ;;
    *)             platform="aarch64-darwin" ;;
  esac
  info "Creating machine config for $host"
  cat >"$target" <<EOF
{ pkgs, lib, ... }:
{
  # Machine-specific overrides for $host.
  # Add packages, homebrew casks, and system defaults here as needed.

  nixpkgs.hostPlatform = "$platform";
}
EOF
  ok "Wrote $target"
}

bootstrap_nix_darwin() {
  $IS_DARWIN || return 0
  local host="${HOSTNAME:-$(hostname -s)}"
  local flake_dir="$DOTFILES_DIR/shared/.config/nix-darwin"
  if [ -e /run/current-system ] && command -v darwin-rebuild >/dev/null 2>&1; then
    info "nix-darwin already bootstrapped — running nix_rebuild"
    "$DOTFILES_DIR/shared/bin/darwin-rebuild-wrapper.sh"
  else
    info "Bootstrapping nix-darwin for the first time (host: $host)"
    sudo nix --extra-experimental-features "nix-command flakes" \
      run nix-darwin/master#darwin-rebuild -- \
      switch --flake "$flake_dir#$host"
  fi
}

bootstrap_tpm() {
  local tpm_dir="$HOME/.config/tmux/plugins/tpm"
  if [ ! -d "$tpm_dir" ]; then
    info "Cloning TPM into $tpm_dir"
    mkdir -p "$HOME/.config/tmux/plugins"
    git clone https://github.com/tmux-plugins/tpm "$tpm_dir"
  else
    ok "TPM already installed"
  fi
  if [ -x "$tpm_dir/bin/install_plugins" ]; then
    info "Installing/updating tmux plugins via TPM"
    "$tpm_dir/bin/install_plugins" || warn "TPM plugin install reported errors — you can retry with prefix+I inside tmux"
  fi
}

bootstrap_work_submodule() {
  local work_machines="$DOTFILES_DIR/work/.config/nix-darwin/machines"
  if [ -d "$work_machines" ]; then
    ok "Work submodule already initialized"
    return 0
  fi
  if confirm "Initialize the private work submodule? (requires repo access)"; then
    info "Initializing work submodule"
    (cd "$DOTFILES_DIR" && git submodule update --init --recursive work)
  fi
}

bootstrap_rca_submodule() {
  if [ -f "$DOTFILES_DIR/rca/.git" ] || [ -d "$DOTFILES_DIR/rca/.git" ]; then
    ok "RCA submodule already initialized"
    return 0
  fi
  if confirm "Initialize the private rca submodule? (requires repo access)"; then
    info "Initializing rca submodule"
    (cd "$DOTFILES_DIR" && git submodule update --init --recursive rca)
  fi
}

select_profiles_interactively() {
  # Only prompt if user ran --bootstrap without explicit profiles.
  [ ${#PROFILES[@]} -eq 0 ] || return 0
  local default
  if $IS_DARWIN; then
    default="shared personal"
  else
    default="shared ubuntu-server"
  fi
  info "Stow profile selection"
  echo "Common choices: 'shared personal', 'shared work', 'shared rca', 'shared ubuntu-server'" >&2
  local answer
  answer="$(prompt "Profiles to stow (space-separated)" "$default")"
  # shellcheck disable=SC2206
  PROFILES=($answer)
}

has_profile() {
  local target="$1"
  for p in "${PROFILES[@]}"; do
    [ "$p" = "$target" ] && return 0
  done
  return 1
}

run_bootstrap() {
  info "Bootstrap mode — setting up a fresh machine"
  if ! $IS_DARWIN; then
    warn "Not on macOS — skipping Darwin-specific steps (hostname, machine config, nix-darwin)"
  fi
  bootstrap_xcode_clt
  bootstrap_apt_prereqs
  has_profile rca || bootstrap_ssh_key
  bootstrap_convert_to_repo
  if ! has_profile rca; then
    bootstrap_hostname
    bootstrap_nix
    bootstrap_machine_config
    bootstrap_nix_darwin
  fi
  bootstrap_tpm
  has_profile work && bootstrap_work_submodule
  has_profile rca && bootstrap_rca_submodule
  select_profiles_interactively
}

# ---------------------------------------------------------------------------
# Main flow
# ---------------------------------------------------------------------------

if $BOOTSTRAP; then
  run_bootstrap
fi

# Pre-create directories so stow symlinks individual files, not entire directories.
# Required when multiple stow packages contribute files to the same parent directory.
info "Pre-creating directories for stow merging"
mkdir -p "$HOME/.config/fish"
mkdir -p "$HOME/.config/shell"
mkdir -p "$HOME/.config/nix-darwin/machines"
mkdir -p "$HOME/.config/tmux"
mkdir -p "$HOME/.config/tmux/plugins"
mkdir -p "$HOME/.claude"
mkdir -p "$HOME/.ssh"
mkdir -p "$HOME/bin"

if $DIRS_ONLY; then
  ok "Done (--dirs-only: skipped stow)."
  exit 0
fi

# Default to 'shared' if no profiles given
if [ ${#PROFILES[@]} -eq 0 ]; then
  PROFILES=("shared")
fi

# Run RCA dependency installer before stow (installs stow + userland tools)
for p in "${PROFILES[@]}"; do
  if [ "$p" = "rca" ]; then
    info "Installing RCA userland dependencies"
    "$DOTFILES_DIR/rca/bin/install-deps.sh"
    break
  fi
done

info "Stowing profiles: ${PROFILES[*]}"
cd "$DOTFILES_DIR"
stow -v --target="$HOME" "${PROFILES[@]}"

if command -v bat >/dev/null 2>&1; then
  info "Rebuilding bat cache"
  bat cache --build
fi

bootstrap_tpm

ok "Done."
