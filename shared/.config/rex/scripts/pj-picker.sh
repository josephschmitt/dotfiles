#!/bin/sh
# pj project picker for Rex (prefix+O, popup): fuzzy-find a `pj` project and open
# it as a session, or switch to the one already working there. The Rex
# counterpart of the pj-herdr plugin / the Herdr Mac app's pj-picker mod.
#
# Enter opens (rex-open), Esc closes. ctrl-j/ctrl-k move.

set -u

PATH="${PATH}:${HOME}/bin:${HOME}/.local/bin:/opt/homebrew/bin:/run/current-system/sw/bin:${HOME}/.nix-profile/bin:/usr/local/bin"
export PATH

# path<TAB>icon + name, so fzf shows (and matches) the display column only.
sel=$(pj --icons --ansi --sort alpha --format '%P	%i %n' |
  fzf --ansi --layout=reverse --height=100% --border=none \
    --delimiter='\t' --with-nth=2 --nth=1.. \
    --prompt='project ❯ ' --header='Enter open · Esc' --header-first \
    --bind 'ctrl-j:down,ctrl-k:up') || exit 0

path=$(printf '%s' "${sel}" | cut -f1)
[ -n "${path}" ] || exit 0

pause() {
  printf '\n\033[2m%s\033[0m' "$1"
  old=$(stty -g 2>/dev/null)
  stty -icanon -echo 2>/dev/null
  dd bs=1 count=1 >/dev/null 2>&1 </dev/tty
  [ -n "${old}" ] && stty "${old}" 2>/dev/null
}

rex-open "${path}"
case $? in
  0) ;;
  # The session exists, but the app refused to switch to it (Remote Control off).
  2)
    printf '\n\033[33mOpened, but Rex needs Remote Control to switch to it\n(Rex > Settings > Server > Client Info). Pick it in the sidebar.\033[0m\n'
    pause 'Press any key to close'
    ;;
  *)
    pause 'Failed. Press any key to close'
    exit 1
    ;;
esac
