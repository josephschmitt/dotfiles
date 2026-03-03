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

### Yazi crashes tmux server when opened in popup

**Symptom:** Opening yazi in a tmux popup shows "Terminal response timeout" and crashes the entire tmux server.

**Cause:** Yazi sends terminal capability detection queries via passthrough sequences at startup. tmux 3.6a does not support passthrough in `display-popup` (passthrough only works in regular panes). The unhandled sequences corrupt the tmux server state.

**Status:** A fix was proposed in [tmux issue #4329](https://github.com/tmux/tmux/issues/4329) but has not been committed yet. The issue is closed but the code change was never merged into tmux master or any release.

**Current implementation:** The yazi binding (`prefix + Y`) opens yazi in a new tmux window instead of a popup to avoid this issue. Passthrough works correctly in regular windows.

**Future:** Once tmux releases a version with the passthrough popup fix, the binding can be changed back to use a popup if desired.

**References:**
- tmux issue: https://github.com/tmux/tmux/issues/4329
- yazi issue: https://github.com/sxyazi/yazi/issues/2308

## television

### tv opens `files` channel instead of the requested channel (e.g. `sesh`, `pj`)

**Symptom:** Running `tv sesh` or `tv pj` from a directory like `~/development` opens the default `files` channel instead of the requested cable channel.

**Cause:** Television's CLI has ambiguous positional args `[CHANNEL] [PATH]`. When a filesystem entry matching the argument name exists in the CWD (e.g. `~/development/sesh/` or `~/development/pj`), tv treats the argument as a PATH and falls back to the default channel.

**Fix:** Pass `-d $HOME` to `tmux-popup` so the popup opens with CWD set to `$HOME`, which is unlikely to contain files/dirs named after tv channels. The `tmux-popup` script forwards `-d` directly to `tmux display-popup`.

All affected bindings (`Prefix+o`, `Prefix+f`, `Prefix+P`) and `sesh-or-stay.sh` have been updated to use `-d $HOME`.
