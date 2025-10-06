show_git_branch() {
  local index=$1 # this variable is used by the module loader in order to know the position of this module
  local icon="$(get_tmux_option "@catppuccin_git_branch_icon" "")"
  local color="$(get_tmux_option "@catppuccin_git_branch_color" "$thm_yellow")"

  # Build the module format first so we can embed it in the conditional
  local module_template
  module_template="$(build_status_module "$index" "$icon" "$color" "BRANCH_PLACEHOLDER")"

  # Use double quotes so your linter stops yelling; tmux will evaluate #{...} at draw time.
  # Only show module if inside a git repo.
  # symbolic-ref returns branch for normal cases; fallback to short SHA when detached.
  local module
  module="#(branch=\$(git -C \"#{pane_current_path}\" symbolic-ref --short -q HEAD 2>/dev/null \
    || git -C \"#{pane_current_path}\" rev-parse --short HEAD 2>/dev/null); \
    if [ -n \"\$branch\" ]; then echo '${module_template}' | sed \"s/BRANCH_PLACEHOLDER/\$branch/\"; fi)"

  echo "$module"
}
