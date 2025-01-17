#!/usr/bin/env bash

paths=$(env "YAZI_CONFIG_HOME=~/.config/yazi-single" yazi $2 --chooser-file=/dev/stdout | while read -r; do printf "%q " "$REPLY"; done)
path=${paths[0]}

# Focus editor pane
zellij action focus-next-pane

dir=$path
if [[ -f "$path" ]]; then
	dir=$(dirname "$path")
# else
	# If our path is a directory, change to that dir in editor
	# echo "First CD into $path"
	# zellij action write 27 # send <Escape> key
	# zellij action write-chars ":cd $path"
	# zellij action write 13 # send <Enter> key
	# sleep 0.25
fi

# Open paths in the editor
if [[ -n "$paths" ]]; then
	# echo "Open $paths"
	zellij action write 27 # send <Escape> key
	zellij action write-chars ":$1 $paths"
	zellij action write 13 # send <Enter> key
fi


# Re-open yazi at the dir of the first path
"$0" $1 $dir

# echo "Path: $path"
# echo "Dir: $dir"
# echo "Is dir: $([[ -d $path ]])"
