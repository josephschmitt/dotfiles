# Shared functions for all POSIX-compatible shells

# Change directories from ~/development
cdd() {
  cd ~/development/"$1" || exit
}

# Find the given path in zoxide, or enter interactive mode
zq() {
  zoxide query "$@" || zoxide query -i
}

# Convenience function to change directory and run twm
twmp() {
  target_dir="$(zq "${@:-$(pwd)}")"
  name="$(basename "$target_dir")"

  pushd "$target_dir" >/dev/null || return
  twm --path "$target_dir" --name "$name" --command nvim
  popd >/dev/null || return
}
