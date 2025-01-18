#!/usr/bin/env bash

cwd=${1:-$(pwd)} # Working directory to open in, defaults to pwd
layout=${2:-"ide_compact"} # Layout to use. Defined in zellij layouts dir

# No way to specify the working dir to the zellij CLI, so we change the working dir before opening
# zellij, and change it back once we exit
pushd $cwd > /dev/null
  zellij --layout "$layout"
popd > /dev/null
