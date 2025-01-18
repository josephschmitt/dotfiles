#!/usr/bin/env bash

command=${1:-"open"} # Command to perform on the paths, one of "open" (default), "vsplit", "hsplit"
config=${2:-"~/.config/yazi"} # Yazi picker config location
working_dir=${3} # Optionally specify a working directory to open yazi into

# Point yazi to the config directory for opening as a single layout pane
export YAZI_CONFIG_HOME="${config}"

paths=$(yazi $working_dir --chooser-file=/dev/stdout | while read -r; do printf "%q " "$REPLY"; done)
path=${paths[0]}

# Focus editor pane, must be the next pane after yazi
zellij action focus-next-pane

# Grab the directory of the first provided path
dir=$path
if [[ -f "$path" ]]; then
	dir=$(dirname "$path")
else
 # If our path is already a directory, change the working dir to it in our editor
 # This ensures any other commands in our editor (such as :open, :mv, etc) have the correct cwd
 zellij action write 27 # send <Escape> key to enter NORMAL mode
 zellij action write-chars ":cd $path"
 zellij action write 13 # send <Enter> key
 sleep 0.25
fi

# Open paths in the editor
if [[ -n "$paths" ]]; then
	zellij action write 27 # send <Escape> key to enter NORMAL mode
	zellij action write-chars ":$command $paths"
	zellij action write 13 # send <Enter> key
fi

# Yazi exits once we pick paths, so re-open it manually by re-running this very script, and set
# the working dir to be the dir of the first path
"$0" $command $config $dir
