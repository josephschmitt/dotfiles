# This function is for use on Macs with multiple brew installations (usually M1/arm64) Macs. This
# function will attempt to set your brew PATH to point to the correct brew based on the system arch.
#
# Usage:
#   # will automatically set brew based on architecture
#   $ switch_brew (uname -m)
#
#   # will set brew for x86_64
#   $ switch_brew x86_64
#
#   # will set brew for arm64
#   $ switch_brew arm64
function switch_brew
  set -l arm_brew_path "/opt/homebrew/bin"
  set -l switch_to $argv[1]

  if test "$switch_to" = "x86_64"
    if set -l index (contains -i $arm_brew_path $PATH)
      set -e PATH[$index]
    end
  else if test "$switch_to" = "arm64"
    set PATH $arm_brew_path $PATH
  end
end
