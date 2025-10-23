# Fish Shell Environment Configuration
# Environment variables and PATH setup

# Use starship for the custom prompt instead of OMP
setenv USE_STARSHIP true

setenv XDG_CONFIG_HOME "$HOME/.config"
setenv EDITOR nvim
setenv BAT_THEME tokyonight_night
setenv EZA_ICONS_AUTO always
setenv EZA_CONFIG_DIR "$XDG_CONFIG_HOME/eza"

setenv ZJ_ALWAYS_NAME true
setenv ZJ_DEFAULT_LAYOUT ide
setenv ZJ_LAYOUTS_DIR $HOME/development/zj/layouts

# Homebrew configuration
set -gx HOMEBREW_NO_ENV_HINTS 1

# Volta Node.js version manager
setenv VOLTA_HOME "$HOME/.volta"

# PNPM package manager
set -gx PNPM_HOME $HOME/Library/pnpm

# ASDF version manager shims
if test -z $ASDF_DATA_DIR
    set -l _asdf_shims "$HOME/.asdf/shims"
else
    set -l _asdf_shims "$ASDF_DATA_DIR/shims"
end

# PATH configuration - prepend directories in reverse priority order
# (later entries take precedence)
set -l path_prepends \
    "$HOME/.nix-profile/bin" \
    /run/current-system/sw/bin \
    /nix/var/nix/profiles/default/bin \
    /opt/homebrew/bin \
    "$HOME/.bun/bin" \
    "$HOME/.cargo/bin" \
    "$VOLTA_HOME/bin" \
    "$HOME/bin" \
    "$HOME/go/bin" \
    "$HOME/.local/bin" \
    "$HOME/development/zide/bin" \
    "$HOME/development/zj/bin" \
    $_asdf_shims \
    $PNPM_HOME

# Apply all path additions in one operation
set -gx PATH $path_prepends $PATH

# Append LM Studio to the end of PATH
set -gx PATH $PATH $HOME/.lmstudio/bin

setenv ZELLIJ_CONFIG_DIR "$HOME/.config/zellij"
setenv ZIDE_DEFAULT_LAYOUT compact_lazygit_focus
setenv ZIDE_LAYOUT_DIR "$ZELLIJ_CONFIG_DIR/layouts/zide"
setenv ZIDE_ALWAYS_NAME true
setenv ZIDE_USE_YAZI_CONFIG false
setenv ZIDE_USE_FOCUS_PLUGIN true
