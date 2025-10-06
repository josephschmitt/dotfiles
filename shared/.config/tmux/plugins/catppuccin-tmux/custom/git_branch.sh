show_git_branch() {
  local index=$1 # this variable is used by the module loader in order to know the position of this module
  local icon="$(get_tmux_option "@catppuccin_git_branch_icon" "")"
  local color="$(get_tmux_option "@catppuccin_git_branch_color" "$thm_yellow")"

  # Use double quotes so your linter stops yelling; tmux will evaluate #{...} at draw time.
  # symbolic-ref returns branch for normal cases; fallback to short SHA when detached.
  local text="#(git -C \"#{pane_current_path}\" symbolic-ref --short -q HEAD 2>/dev/null \
    || git -C \"#{pane_current_path}\" rev-parse --short HEAD 2>/dev/null)"

  local module
  module="$(build_status_module "$index" "$icon" "$color" "$text")"
  printf '%s' "$module"
}
