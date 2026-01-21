function rerender_on_bind_mode_change --on-variable fish_bind_mode -d "Trigger oh-my-posh repaint on vim mode change"
  # Skip paste mode and avoid redundant repaints
  if test "$fish_bind_mode" != paste -a "$fish_bind_mode" != "$FISH__BIND_MODE"
    set -gx FISH__BIND_MODE $fish_bind_mode
    # omp_repaint_prompt is defined by oh-my-posh init
    if type -q omp_repaint_prompt
      omp_repaint_prompt
    end
  end
end
