# Shared functions for all POSIX-compatible shells

# Change directories from ~/development
cdd() {
  cd ~/development/"$1" || exit
}

zq() {
  zoxide query "$@" || zoxide query -i
}

twmp() {
  pushd >/dev/null || exit
  twm --project "$(zq "${@:-$(pwd)}")"
  popd >/dev/null || exit
}
