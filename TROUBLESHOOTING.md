# Troubleshooting

Common issues and fixes for tools in this dotfiles repository.

## Fresh-machine setup

### `darwin-rebuild` fails with "attribute 'X' missing" / hostname not in flake

**Symptom:** Running `nix_rebuild` on a new Mac fails because the short hostname (`hostname -s`) doesn't match any key under `darwinConfigurations`.

**Cause:** `shared/.config/nix-darwin/flake.nix` auto-discovers personal machine configs from `shared/.config/nix-darwin/machines/*.nix`. If no file exists for the current hostname, the flake has no entry to build.

**Fix:** Run `./install.sh --bootstrap` from the repo root. It creates an empty-overrides stub at `shared/.config/nix-darwin/machines/<hostname>.nix` and then runs `nix_rebuild`. Alternatively, create the file by hand:
```nix
{ pkgs, lib, ... }:
{
  nixpkgs.hostPlatform = "aarch64-darwin";  # or "x86_64-darwin"
}
```

### tmux plugins not loading (`prefix + I` does nothing useful)

**Symptom:** tmux starts but bindings from configured plugins (sessionx, floax, etc.) don't work.

**Cause:** TPM (tmux plugin manager) is not installed or its plugins directory is empty. Nothing in nix-darwin or stow puts TPM on disk.

**Fix:** Run `./install.sh --bootstrap`, which clones TPM into `~/.config/tmux/plugins/tpm` and runs `~/.config/tmux/plugins/tpm/bin/install_plugins` non-interactively. Or do it manually:
```bash
git clone https://github.com/tmux-plugins/tpm ~/.config/tmux/plugins/tpm
~/.config/tmux/plugins/tpm/bin/install_plugins
```

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
