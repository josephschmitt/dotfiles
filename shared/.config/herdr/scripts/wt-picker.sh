#!/bin/sh
# Herdr worktree pickers (run in popups; see config.toml prefix+w / W / D).
#
#   wt-picker.sh                   find-or-create in this repo (prefix+shift+w):
#                                  type a name, matching worktrees of the focused
#                                  pane's repo are listed below
#   wt-picker.sh --all             switch to any managed worktree, all repos
#                                  (prefix+w); works from any pane
#   wt-picker.sh --branch          check out an existing branch of the focused
#                                  pane's repo as a worktree (prefix+shift+b):
#                                  lists the local and origin branches that
#                                  have no worktree yet
#   wt-picker.sh --remove-current  remove the worktree the focused pane is in
#                                  (prefix+shift+d)
#
# Keys (fzf), find-or-create: Enter opens the highlighted worktree (focus its
# workspace, or open one), or creates the typed name when nothing matches.
# ctrl-n creates the typed name even if something matches. ctrl-d offers to
# delete the highlighted worktree (asks first). ctrl-g merges it into the
# default branch (`wt merge`, asks first). ctrl-j/ctrl-k move, Esc closes.
# --all: Enter switches to / opens the highlighted worktree, ctrl-d deletes it,
# ctrl-g merges it; no create (there's no repo to create in).
# --branch: Enter checks the highlighted branch out into a worktree (remote-only
# branches get a tracking branch) and opens its workspace; no create, no delete.
# Tab cycles the list all / local / remote (remote = origin-only branches).
# Refs are whatever is already local (no fetch).
#
# The work is done by herdr-wt (shared/bin), which uses Worktrunk (`wt`) for
# the checkouts and hooks. The Rex config runs this same script with
# WT_ENGINE=rex-wt, whose subcommands match herdr-wt's but drive Rex sessions
# (~/.config/rex/popups.lua).

set -u

WT=${WT_ENGINE:-herdr-wt}

mode=pick
case "${1:-}" in
  --remove-current) mode=remove ;;
  --all) mode=all ;;
  --branch) mode=branch ;;
  "") ;;
  *) printf 'usage: %s [--all | --branch | --remove-current]\n' "$0" >&2; exit 2 ;;
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

# Run the engine; on failure show its output and wait for a key.
run() {
  if ! "${WT}" "$@"; then
    pause "Failed. Press any key to close"
    exit 1
  fi
}

# "branch<TAB>path<TAB>main" for a checkout path.
checkout_info() {
  "${WT}" checkouts | awk -F '\t' -v p="$1" '$2 == p { print; exit }'
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
  changes=$("${WT}" dirty "$1")
  if [ -n "${changes}" ]; then
    printf '\033[31mUncommitted changes (will be lost):\033[0m\n%s\n\n' "${changes}"
    confirm "Discard them and remove?" || return 1
    force=-f
  else
    confirm "Remove?" || return 1
  fi
  printf '\n'
  if ! "${WT}" remove "$1" ${force}; then
    reason="failed"
    pause "Failed. Press any key to continue"
    return 1
  fi
}

# Ask, then merge a worktree (by path) into the default branch and remove it,
# closing its workspace. wt squashes its commits (and any uncommitted changes),
# rebases onto the target, fast-forwards it and runs the merge hooks. Returns 1
# if cancelled, refused or failed (a conflict leaves the rebase to resolve in the
# worktree).
merge_flow() {
  reason=""
  info=$(checkout_info "$1")
  branch=$(printf '%s' "${info}" | cut -f1)
  if [ "$(printf '%s' "${info}" | cut -f3)" = 1 ]; then
    reason="main checkout, not a worktree"
    printf '\033[33m%s is the %s.\033[0m\n' "$1" "${reason}"
    return 1
  fi
  if [ -z "${branch}" ]; then
    reason="detached HEAD, no branch"
    printf '\033[33m%s has no branch (detached HEAD).\033[0m\n' "$1"
    return 1
  fi
  target=$("${WT}" default-branch)
  printf '\033[1mMerge %s into %s\033[0m\n\033[2m%s\033[0m\n' "${branch}" "${target}" "$1"
  printf 'Squashes its commits, rebases onto %s and fast-forwards it, runs the merge\n' "${target}"
  printf 'hooks, then removes the worktree and branch and closes its workspace.\n\n'
  changes=$("${WT}" dirty "$1")
  if [ -n "${changes}" ]; then
    printf '\033[33mUncommitted changes (committed with the merge):\033[0m\n%s\n\n' "${changes}"
  fi
  confirm "Merge?" || return 1
  printf '\n'
  if ! "${WT}" merge-close "$1"; then
    reason="failed"
    pause "Failed. Press any key to continue"
    return 1
  fi
}

# --all: every managed worktree, from any pane (repo or not).
if [ "${mode}" = all ]; then
  WT_HEADER="Enter switch/open · ctrl-d delete · ctrl-g merge · Esc"
  WT_MSG=""
  export WT_HEADER WT_MSG
  while :; do
    # shellcheck disable=SC2016 # $WT_* expand in fzf's shell, not here
    out=$("${WT}" all | fzf --ansi --layout=reverse --height=100% --border=none \
      --delimiter='\t' --with-nth=4 --expect=ctrl-d,ctrl-g \
      --prompt='worktree ❯ ' --header="${WT_HEADER}" --header-first \
      --with-shell='sh -c' \
      --bind 'result:transform-header:[ -n "$WT_MSG" ] && printf "%s\n" "$WT_MSG"; printf "%s" "$WT_HEADER"')
    rc=$?
    [ "${rc}" -le 1 ] || exit 0
    key=$(printf '%s\n' "${out}" | sed -n 1p)
    sel=$(printf '%s\n' "${out}" | sed -n 2p)
    path=$(printf '%s' "${sel}" | cut -f1)
    main=$(printf '%s' "${sel}" | cut -f2)
    WT_MSG=""
    if [ -z "${path}" ]; then
      [ "${key}" = ctrl-d ] && WT_MSG="ctrl-d: highlight a worktree to delete it"
      [ "${key}" = ctrl-g ] && WT_MSG="ctrl-g: highlight a worktree to merge it"
      continue
    fi
    if [ "${key}" = ctrl-g ]; then
      clear
      # Like ctrl-d: merge_flow resolves against the repo of $PWD, so run it
      # from the worktree's main checkout.
      res=$(cd "${main}" && { merge_flow "${path}" >/dev/tty 2>&1 && echo ok || printf '%s\n' "${reason}"; })
      if [ "${res}" = ok ]; then
        WT_MSG="Merged ${path}"
      else
        WT_MSG="Not merged${res:+ (${res})}: ${path}"
      fi
      continue
    fi
    if [ "${key}" = ctrl-d ]; then
      clear
      # remove_flow and herdr-wt resolve against the repo of $PWD; the
      # subshell keeps our cwd. Its $reason comes back as the last line.
      res=$(cd "${main}" && { remove_flow "${path}" >/dev/tty 2>&1 && echo ok || printf '%s\n' "${reason}"; })
      if [ "${res}" = ok ]; then
        WT_MSG="Removed ${path}"
      else
        WT_MSG="Not removed${res:+ (${res})}: ${path}"
      fi
      continue
    fi
    cd "${path}" || fail "Can't enter ${path}"
    run open "${path}"
    exit 0
  done
fi

here=$("${WT}" current 2>/dev/null)
[ -n "${here}" ] || fail "Not in a git repository: ${PWD}"

if [ "${mode}" = remove ]; then
  remove_flow "${here}" || { pause; exit 1; }
  sleep 1
  exit 0
fi

# The repo's name (its main checkout's folder), shown in the prompt.
repo=$(basename "$("${WT}" checkouts | sed -n '1p' | cut -f2)")

# --branch: branches (local, and origin's) that have no worktree yet.
if [ "${mode}" = branch ]; then
  list=$("${WT}" branches) || { pause "Failed. Press any key to close"; exit 1; }
  if [ -z "${list}" ]; then
    printf '\n\033[33mNo branches without a worktree in %s.\033[0m\n' "${repo}"
    pause
    exit 0
  fi
  # Tab cycles the scope all -> local -> remote and re-opens fzf with the typed
  # query kept. "local": has a local branch (local or both); "remote": origin
  # only, i.e. the rows tagged "remote".
  scope=all
  query=""
  while :; do
    # branch<TAB>display: bold branch, yellow "remote" for origin-only ones, dim
    # age and subject; columns aligned. fzf shows and matches the display only.
    out=$(printf '%s\n' "${list}" | awk -F '\t' -v scope="${scope}" '
      scope == "local" && $2 == "remote" { next }
      scope == "remote" && $2 != "remote" { next }
      {
        n++; b[n] = $1; k[n] = $2; d[n] = $3; s[n] = $4
        if (length($1) > bw) bw = length($1)
        if (length($3) > dw) dw = length($3)
      }
      END {
        for (i = 1; i <= n; i++)
          printf "%s\t\033[1m%s\033[0m \033[33m%-6s\033[0m \033[2m%s  %s\033[0m\n", b[i],
            sprintf("%-" bw "s", b[i]), (k[i] == "remote" ? "remote" : ""),
            sprintf("%-" dw "s", d[i]), s[i]
      }' | fzf --ansi --layout=reverse --height=100% --border=none \
      --delimiter='\t' --with-nth=2 --print-query --query="${query}" --expect=tab \
      --prompt="${scope} branch (${repo}) ❯ " \
      --header="Enter check out in a worktree · Tab all/local/remote · Esc" --header-first)
    rc=$?
    # 0: selection, 1: no match (Tab still reports), 130: Esc / ctrl-c.
    [ "${rc}" -le 1 ] || exit 0
    query=$(printf '%s\n' "${out}" | sed -n '1p')
    key=$(printf '%s\n' "${out}" | sed -n '2p')
    if [ "${key}" = tab ]; then
      case "${scope}" in
        all) scope=local ;;
        local) scope=remote ;;
        *) scope=all ;;
      esac
      continue
    fi
    sel=$(printf '%s\n' "${out}" | sed -n '3p')
    [ -n "${sel}" ] || exit 0
    run open "$(printf '%s' "${sel}" | cut -f1)"
    exit 0
  done
fi

WT_HEADER="Enter open (or create typed name) · ctrl-n create typed name · ctrl-d delete · ctrl-g merge · Esc"
# WT_MSG: result of the last ctrl-d, shown above the hints. Both are read by
# the transform-header bind (which redraws the header on every result change).
WT_MSG=""
export WT_HEADER WT_MSG

main_path=$("${WT}" checkouts | sed -n '1p' | cut -f2)

while :; do
  # Merging or removing the worktree this popup was opened in deletes our cwd.
  [ -d "${PWD}" ] || cd "${main_path}" || exit 1
  # shellcheck disable=SC2016 # $FZF_* / $WT_* expand in fzf's shell, not here
  out=$("${WT}" list | fzf --ansi --layout=reverse --height=100% --border=none \
    --delimiter='\t' --with-nth=4 --print-query --expect=ctrl-n,ctrl-d,ctrl-g \
    --prompt="worktree (${repo}) ❯ " --header="${WT_HEADER}" --header-first \
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
      # Refusals go in the header (WT_MSG), where they stay visible; the
      # confirmation screen is only for something that can be deleted.
      if [ -z "${path}" ]; then
        WT_MSG="ctrl-d: highlight a worktree to delete it"
        continue
      fi
      if [ "$(checkout_info "${path}" | cut -f3)" = 1 ]; then
        WT_MSG="Can't delete ${path}: it's the main checkout, not a worktree"
        continue
      fi
      clear
      if remove_flow "${path}"; then
        WT_MSG="Removed ${path}"
      else
        WT_MSG="Not removed${reason:+ (${reason})}: ${path}"
      fi
      continue
      ;;
    ctrl-g)
      if [ -z "${path}" ]; then
        WT_MSG="ctrl-g: highlight a worktree to merge it"
        continue
      fi
      if [ "$(checkout_info "${path}" | cut -f3)" = 1 ]; then
        WT_MSG="Can't merge ${path}: it's the main checkout, not a worktree"
        continue
      fi
      clear
      if merge_flow "${path}"; then
        WT_MSG="Merged ${path}"
      else
        WT_MSG="Not merged${reason:+ (${reason})}: ${path}"
      fi
      continue
      ;;
    ctrl-n) target=${query} ;;
    *) target=${path:-${query}} ;;
  esac
  [ -n "${target}" ] || continue
  run open "${target}"
  exit 0
done
