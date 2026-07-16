#!/usr/bin/env bash
# post-stow hook for shared profile
#
# 1. Rebuilds bat theme/syntax cache
# 2. Installs/updates TPM and tmux plugins
# 3. Applies the herdr plugin manifest (plugins.manifest.toml)

info() { printf '\n\033[1;34m==>\033[0m %s\n' "$*"; }
ok()   { printf '\033[0;32m✓\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m!\033[0m %s\n' "$*" >&2; }

# Rebuild bat cache
if command -v bat >/dev/null 2>&1; then
  info "Rebuilding bat cache"
  bat cache --build
fi

# Install/update TPM and tmux plugins
tpm_dir="$HOME/.config/tmux/plugins/tpm"
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

# Apply herdr plugin manifest
if command -v herdr >/dev/null 2>&1 && command -v herdr-plugins >/dev/null 2>&1; then
  info "Applying herdr plugin manifest"
  herdr-plugins || warn "herdr plugin sync reported errors — rerun manually: herdr-plugins"
fi
