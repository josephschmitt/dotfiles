export IGNORE_PYTHON_VERSION_REQUIREMENT="1"  ##compass5ea843
export VIRTUALENVWRAPPER_PYTHON="/usr/bin/python2.7"  ##compass5ea843
export GITROOT="/Users/josephschmitt/development"  ##compass5ea843

# This function is for use on Macs with multiple brew installations (usually M1/arm64) Macs. This
# function will attempt to set your brew PATH to point to the correct brew based on the system arch.
#
# Usage:
#   # will automatically set brew based on architecture
#   $ switch_brew
#
#   # will set brew for arm64
#   $ switch_brew arm64
#
#   # will set brew for x86_64
#   $ switch_brew x86_64
function switch_brew {
  armBrewPath="/opt/homebrew/bin"
  switch_to=${1:-"$(uname -m)"}

  if [ "${switch_to}" = "arm64" ]; then
    PATH="${armBrewPath}:$PATH"
  else
    PATH=${PATH/":$armBrewPath"/} # delete any instances in the middle or at the end
    PATH=${PATH/"$armBrewPath:"/} # delete any instances at the beginning
  fi
}

switch_brew
export PATH="$HOME/.jenv/bin:$PATH"
eval "$(jenv init -)"
export PATH="$PATH:/Applications/Banyan.app/Contents/Resources/bin"  ##compass5ea843
