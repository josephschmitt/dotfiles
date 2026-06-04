function herdr-remote -d "Attach to remote herdr server with server-side keybindings" -w herdr
    herdr --remote-keybindings server --remote $argv
end
