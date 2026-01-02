# Fish Shell Environment Configuration
# Environment variables and PATH setup

setenv XDG_CONFIG_HOME "$HOME/.config"
setenv TMUX_CONFIG_DIR "$XDG_CONFIG_HOME/tmux"
setenv EDITOR nvim
setenv COLORTERM truecolor
setenv BAT_THEME tokyonight_night
setenv EZA_ICONS_AUTO always
setenv EZA_CONFIG_DIR "$XDG_CONFIG_HOME/eza"

setenv ZJ_ALWAYS_NAME true
setenv ZJ_DEFAULT_LAYOUT ide
setenv ZJ_LAYOUTS_DIR $HOME/development/zj/layouts

setenv ZELLIJ_CONFIG_DIR "$HOME/.config/zellij"
setenv ZIDE_DEFAULT_LAYOUT compact_lazygit_focus
setenv ZIDE_LAYOUT_DIR "$ZELLIJ_CONFIG_DIR/layouts/zide"
setenv ZIDE_ALWAYS_NAME true
setenv ZIDE_USE_YAZI_CONFIG false
setenv ZIDE_USE_FOCUS_PLUGIN true

# FZF configuration
# fd respects .ignore files automatically, just exclude .git
setenv FZF_DEFAULT_COMMAND "fd --type f --hidden --follow --exclude=.git"

fish_add_path --prepend "$HOME/.nix-profile/bin"
fish_add_path --prepend /run/current-system/sw/bin
fish_add_path --prepend /nix/var/nix/profiles/default/bin

fish_add_path --prepend /opt/homebrew/bin
fish_add_path --prepend "$HOME/.bun/bin"
fish_add_path --prepend "$HOME/.cargo/bin"
fish_add_path --prepend "$HOME/.volta/bin"

fish_add_path --prepend "$HOME/bin"
fish_add_path --prepend "$HOME/go/bin"
fish_add_path --prepend "$HOME/.local/bin"
fish_add_path --prepend "$HOME/development/zide/bin"
fish_add_path --prepend "$HOME/development/zj/bin"

set -gx PNPM_HOME $HOME/Library/pnpm
fish_add_path --prepend "$PNPM_HOME"

# Application paths
fish_add_path --append $HOME/.opencode/bin
fish_add_path --append $HOME/.lmstudio/bin
fish_add_path --append $HOME/.antigravity/antigravity/bin

# Homebrew configuration
set -gx HOMEBREW_NO_ENV_HINTS 1
