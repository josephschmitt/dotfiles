#!/bin/sh
# Herdr worktree picker (runs in a popup; see config.toml prefix+w / W / D).
#
#   wt-picker.sh                   find-or-create: type a name, matching
#                                  worktrees of this repo are listed below
#   wt-picker.sh --new             same list, but Enter always uses what you typed
#   wt-picker.sh --remove-current  remove the worktree the focused pane is in
#
# Keys (fzf): Enter opens the highlighted worktree (focus its workspace, or
# open one), or creates the typed name when nothing matches. ctrl-n creates
# the typed name even if something matches. ctrl-d removes the highlighted
# worktree. ctrl-j/ctrl-k move, Esc closes.
#
# The work is done by herdr-wt (shared/bin), which uses Worktrunk (`wt`) for
# the checkouts and hooks.

set -u

mode=pick
case "${1:-}" in
  --new) mode=new ;;
  --remove-current) mode=remove ;;
  "") ;;
  *) printf 'usage: %s [--new | --remove-current]\n' "$0" >&2; exit 2 ;;
esac

pause() {
  printf '\n\033[2m%s\033[0m' "${1:-Press any key to close}"
  old=$(stty -g 2>/dev/null)
  stty -icanon -echo 2>/dev/null
  dd bs=1 count=1 >/dev/null 2>&1 </dev/tty
  [ -n "${old}" ] && stty "${old}" 2>/dev/null
  printf '\n'
}

fail() {
  printf '\n\033[31m%s\033[0m\n' "$*"
  pause
  exit 1
}

confirm() {
  printf '%s \033[2m[y/N]\033[0m ' "$1"
  read -r ans </dev/tty || return 1
  case "${ans}" in
    y | Y | yes) return 0 ;;
  esac
  return 1
}

# Run herdr-wt; on failure show its output and wait for a key.
run() {
  if ! herdr-wt "$@"; then
    pause "Failed. Press any key to close"
    exit 1
  fi
}

# "branch<TAB>path<TAB>main" for a checkout path.
checkout_info() {
  herdr-wt checkouts | awk -F '\t' -v p="$1" '$2 == p { print; exit }'
}

# Ask, then remove a worktree (by path). Returns 1 if cancelled or refused.
remove_flow() {
  reason=""
  info=$(checkout_info "$1")
  branch=$(printf '%s' "${info}" | cut -f1)
  if [ "$(printf '%s' "${info}" | cut -f3)" = 1 ]; then
    reason="main checkout, not a worktree"
    printf '\033[33m%s is the %s.\033[0m\n' "$1" "${reason}"
    return 1
  fi
  printf '\033[1mRemove worktree %s\033[0m\n\033[2m%s\033[0m\n' "${branch:-(detached)}" "$1"
  printf 'Closes its workspace and deletes the folder; the branch goes too if merged.\n\n'
  force=""
  changes=$(herdr-wt dirty "$1")
  if [ -n "${changes}" ]; then
    printf '\033[31mUncommitted changes (will be lost):\033[0m\n%s\n\n' "${changes}"
    confirm "Discard them and remove?" || return 1
    force=-f
  else
    confirm "Remove?" || return 1
  fi
  printf '\n'
  if ! herdr-wt remove "$1" ${force}; then
    reason="failed"
    pause "Failed. Press any key to continue"
    return 1
  fi
}

here=$(herdr-wt current 2>/dev/null)
[ -n "${here}" ] || fail "Not in a git repository: ${PWD}"

if [ "${mode}" = remove ]; then
  remove_flow "${here}" || { pause; exit 1; }
  sleep 1
  exit 0
fi

if [ "${mode}" = new ]; then
  WT_HEADER="New worktree: type a branch name · Enter creates it (or opens it if it exists) · Esc"
else
  WT_HEADER="Enter open · ctrl-n create typed name · ctrl-d delete · Esc"
fi
# WT_MSG: result of the last ctrl-d, shown above the hints. Both are read by
# the transform-header bind (which redraws the header on every result change).
WT_MSG=""
export WT_HEADER WT_MSG

while :; do
  # shellcheck disable=SC2016 # $FZF_* / $WT_* expand in fzf's shell, not here
  out=$(herdr-wt list | fzf --ansi --layout=reverse --height=100% --border=none \
    --delimiter='\t' --with-nth=4 --print-query --expect=ctrl-n,ctrl-d \
    --prompt='worktree ❯ ' --header="${WT_HEADER}" --header-first \
    --with-shell='sh -c' \
    --bind 'result:transform-header:if [ "$FZF_MATCH_COUNT" -eq 0 ] && [ -n "$FZF_QUERY" ]; then printf "No match · Enter creates %s\n" "$FZF_QUERY"; fi; [ -n "$WT_MSG" ] && printf "%s\n" "$WT_MSG"; printf "%s" "$WT_HEADER"')
  rc=$?
  # 0: selection, 1: no match (query only), 130: Esc / ctrl-c.
  [ "${rc}" -le 1 ] || exit 0
  query=$(printf '%s\n' "${out}" | sed -n 1p)
  key=$(printf '%s\n' "${out}" | sed -n 2p)
  path=$(printf '%s\n' "${out}" | sed -n 3p | cut -f2)
  WT_MSG=""

  case "${key}" in
    ctrl-d)
      [ -n "${path}" ] || continue
      clear
      if remove_flow "${path}"; then
        WT_MSG="Removed ${path}"
      else
        WT_MSG="Not removed${reason:+ (${reason})}: ${path}"
      fi
      continue
      ;;
    ctrl-n) target=${query} ;;
    *)
      if [ "${mode}" = new ] && [ -n "${query}" ]; then
        target=${query}
      else
        target=${path:-${query}}
      fi
      ;;
  esac
  [ -n "${target}" ] || continue
  run open "${target}"
  exit 0
done
