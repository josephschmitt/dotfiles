#!/usr/bin/env bash

paths=$(env "YAZI_CONFIG_HOME=~/.config/yazi-single" yazi $2 --chooser-file=/dev/stdout | while read -r; do printf "%q " "$REPLY"; done)

if [[ -n "$paths" ]]; then
	zellij action focus-next-pane
	zellij action write 27 # send <Escape> key
	zellij action write-chars ":$1 $paths"
	zellij action write 13 # send <Enter> key
else
	zellij action focus-next-pane
fi

# Re-open yazi at the dir of the first path
path=${paths[0]}
dir=$path
[[ -f "$path" ]] && dir=$(dirname "$path")

"$0" $1 $dir
