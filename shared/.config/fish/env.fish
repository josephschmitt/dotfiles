# Fish Shell Environment Configuration
# Environment variables and PATH setup

# Use starship for the custom prompt instead of OMP
# setenv USE_STARSHIP false

setenv XDG_CONFIG_HOME "$HOME/.config"
setenv EDITOR nvim
setenv COLORTERM truecolor
setenv BAT_THEME tokyonight_night
setenv EZA_ICONS_AUTO always
setenv EZA_CONFIG_DIR "$XDG_CONFIG_HOME/eza"

setenv ZJ_ALWAYS_NAME true
setenv ZJ_DEFAULT_LAYOUT ide
setenv ZJ_LAYOUTS_DIR $HOME/development/zj/layouts

set -gx PATH "$HOME/.nix-profile/bin" $PATH
set -gx PATH /run/current-system/sw/bin $PATH
set -gx PATH /nix/var/nix/profiles/default/bin $PATH

# Homebrew configuration
set -gx HOMEBREW_NO_ENV_HINTS 1

set -gx PATH /opt/homebrew/bin $PATH
set -gx PATH "$HOME/.bun/bin" $PATH
set -gx PATH "$HOME/.cargo/bin" $PATH

setenv VOLTA_HOME "$HOME/.volta"
set -gx PATH "$VOLTA_HOME/bin" $PATH

set -gx PATH "$HOME/bin" $PATH
set -gx PATH "$HOME/go/bin" $PATH
set -gx PATH "$HOME/.local/bin" $PATH
set -gx PATH "$HOME/development/zide/bin" $PATH
set -gx PATH "$HOME/development/zj/bin" $PATH

if test -z $ASDF_DATA_DIR
    set _asdf_shims "$HOME/.asdf/shims"
else
    set _asdf_shims "$ASDF_DATA_DIR/shims"
end
set -gx PATH $_asdf_shims $PATH

set -gx PNPM_HOME $HOME/Library/pnpm
if not string match -q -- $PNPM_HOME $PATH
    set -gx PATH "$PNPM_HOME" $PATH
end

setenv ZELLIJ_CONFIG_DIR "$HOME/.config/zellij"
setenv ZIDE_DEFAULT_LAYOUT compact_lazygit_focus
setenv ZIDE_LAYOUT_DIR "$ZELLIJ_CONFIG_DIR/layouts/zide"
setenv ZIDE_ALWAYS_NAME true
setenv ZIDE_USE_YAZI_CONFIG false
setenv ZIDE_USE_FOCUS_PLUGIN true

set -gx PATH $PATH $HOME/.lmstudio/bin
