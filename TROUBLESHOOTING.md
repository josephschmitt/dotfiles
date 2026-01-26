# Troubleshooting

Common issues and fixes for tools in this dotfiles repository.

## tmux

### Server exited unexpectedly

**Symptom:** Running `tmux` gives the error:
```
server exited unexpectedly
```

**Cause:** A stale socket file remains after tmux crashed, was killed abruptly, or the system rebooted.

**Fix:**
```bash
rm -f /tmp/tmux-$(id -u)/default
```

Then start tmux normally.
