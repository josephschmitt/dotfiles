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

### `install.sh` links nothing on a fresh host ("All operations aborted")

**Symptom:** On a brand-new machine, `./install.sh shared ubuntu-server` prints `WARNING! stowing shared would cause conflicts ... All operations aborted.` and *no* profile is linked — not even packages that had no conflict. An automated caller wrapping the run in `./install.sh ... || true` swallows the error and boots with none of the dotfiles stowed.

**Cause:** A fresh host ships plain-file `~/.bashrc`, `~/.profile`, `~/.zshrc` (distro skeletons). GNU stow treats each as a conflict and aborts *all* packages on any single conflict — it is all-or-nothing per run.

**Fix:** `install.sh` now backs up these well-known defaults to `~/.dotfiles-pre-stow-backup/` before stowing (only plain files a selected profile actually provides — pre-existing symlinks are left alone). If stow still fails on some *other* conflict, the script exits non-zero with a loud message instead of continuing silently. To resolve a leftover conflict by hand:
```bash
mkdir -p ~/.dotfiles-pre-stow-backup
for f in .bashrc .profile .zshrc; do
  [ -e "$HOME/$f" ] && [ ! -L "$HOME/$f" ] && mv "$HOME/$f" ~/.dotfiles-pre-stow-backup/
done
cd ~/dotfiles && ./install.sh shared ubuntu-server
```

### `nix profile install` fails with "mismatch in field 'narHash'" for multica

**Symptom:** On the Ubuntu server, `nix profile install ~/dotfiles/ubuntu-server/.config/nix#default` fails with `error: mismatch in field 'narHash' of input 'multica-bin-arm64'` even though the checkout is clean.

**Cause:** The `multica` inputs used to point at a moving `releases/latest/download/...` URL. Every multica release changed the bytes behind that URL while `flake.lock` still held the old `narHash`, so the lock self-staled.

**Fix:** `ubuntu-server/.config/nix/flake.nix` now pins a fixed release tag (e.g. `releases/download/v0.4.7/...`), so the lock is stable. Bump deliberately with `nix flake update multica-bin-amd64 multica-bin-arm64` (or `bin/nix_bump`) after editing the tag, then commit the refreshed `flake.lock`.

### Wrong profile's files active (Mac config on a server, or vice-versa)

**Symptom:** A machine behaves as if it belongs to the wrong profile — e.g. an Ubuntu/Pi server has GPG commit signing forced on (`gpg failed to sign the data`), commits show the wrong email, or `~/.config/nix/flake.nix` is a macOS (`aarch64-darwin`) flake that can't build on Linux. `readlink ~/.gitconfig` points into `personal/` on a server (or `ubuntu-server/` on a Mac).

**Cause:** Profiles (`personal`, `work`, `ubuntu-server`, …) are **mutually exclusive** — a machine stows exactly one identity profile plus `shared`. If two are stowed on the same host, every file they both ship (`.gitconfig`, `.config/nix/flake.nix`, `.config/nix/nix.conf`, …) collides on the same `$HOME` target. Stow gives it to whichever profile it linked first and silently skips the rest, so the wrong profile can win. Fish makes this easy to miss: `config.fish` sources `~/.config/fish/config.*.fish` by glob, so a stray `config.personal.fish` loads with no profile gate.

**Fix:** Stow only the intended profiles for the host (servers: `stow shared ubuntu-server`; never add `personal`). Confirm no foreign links remain:
```bash
find ~ -type l -lname '*dotfiles/personal/*'   # on a server, should print nothing
readlink ~/.gitconfig                          # should resolve into the host's own profile
```
Anything genuinely universal that lived in a single profile (e.g. the `direnv` hook) belongs in `shared/`, guarded so it no-ops where the tool is absent (`if command -q direnv; …; end`).

## tmux

### Status bar shows plain default (no hostname/git/time info)

**Symptom:** Tmux status bar is plain (e.g., just `[1:fish#]`) instead of showing hostname, directory, git branch, and time.

**Cause:** TPM plugins haven't been installed yet. The tmux config declares the plugins in `shared/.config/tmux/conf.d/30-plugins.conf`, but they must be downloaded to `~/.config/tmux/plugins/`.

**Fix:**
```bash
tmux-bootstrap
```

Or manually inside any tmux session: Press `Ctrl-s I` (prefix + I)

**Why this happens:** The `plugins/` directory is in `.gitignore`, so plugins aren't tracked in git. They must be installed locally by TPM after stowing the dotfiles.

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

## Homebrew / nix-darwin

### `brew bundle` fails with `undefined method 'to_sym' for nil` in `cask_struct_generator.rb`

**Symptom:** `nix_rebuild` fails during the Homebrew bundle step:
```
Error: undefined method 'to_sym' for nil
.../cask_struct_generator.rb:100:in 'block in ...process_depends_on'
Failed to fetch <cask names>...
`brew bundle` failed!
```

**Cause:** Homebrew 5.1.7 (pinned by nix-homebrew) has a regression where `process_depends_on` crashes on casks that return empty `depends_on: { macos: {} }` metadata from the API. This was introduced by a bump in `flake.lock` from `brew-src` 5.0.12 → 5.1.7. Tracked upstream as [nix-homebrew #138](https://github.com/zhaofengli/nix-homebrew/issues/138).

**Fix:** Pin `brew-src` explicitly in `flake.nix` to Homebrew 5.1.10, which includes the fix. The `flake.nix` already has this override set. Run:
```bash
cd shared/.config/nix-darwin && nix flake update nix-homebrew
```

Note: Homebrew 5.0.12 has the same class of bug in `api/cask.rb` (different method — `first` instead of `to_sym`). Only 5.1.10+ is known to work against the current Homebrew API.

**Resume:** Once nix-homebrew pins its own `brew-src` to a version ≥ 5.1.10, the explicit override in `flake.nix` (the `nix-homebrew.inputs.brew-src.url` line) can be removed.

## Neovim (Kickstart)

### LSP servers/formatters never auto-install ("X is not executable", "vscode-json-language-server not found")

**Symptom:** Opening a file (e.g. a `.json`, `.md`, or `.rs` file) in the Kickstart config shows an LSP error like `<server> is not executable`, or the server just never attaches. `:Mason` shows only `lua-language-server` and `stylua` installed, no matter how many filetypes you've opened. Most noticeable on machines where nix-darwin doesn't happen to install the LSP as a system package (e.g. personal Macs, which lack `vscode-langservers-extracted`) — work Macs can mask this because `G5FXQQ0D00.nix`/`W2TD37NJKN.nix` install `vscode-langservers-extracted` etc. as system packages.

**Cause:** `shared/.config/nvim/lua/custom/plugins/mason-auto-install.lua` had `opts = {}`. `mason-auto-install.nvim` does **not** auto-detect servers from `lua/custom/lsp-servers.lua` or `vim.lsp.enable()` calls — despite the old comment claiming otherwise, it only installs packages explicitly listed in its own `opts.packages`, using **Mason registry names** (which often differ from lspconfig names, e.g. `jsonls` -> `json-lsp`, `rust_analyzer` -> `rust-analyzer`). With an empty list, it silently never installed anything.

**Fix:** List every enabled server's Mason registry name in `mason-auto-install.lua`'s `opts.packages`. Keep this list in sync with `lua/custom/lsp-servers.lua` (plus `lua_ls`, which is enabled separately in `init.lua`) whenever a server is added or removed. See `shared/.config/nvim/CLAUDE.md` LSP Server Management section for the full mapping rule.

### (Work only) Aborted Mason npm install shows `Resolved node ... / Using Hermetic NodeJS ...` instead of the real error

**Symptom:** A Mason npm-based install (e.g. `json-lsp`) fails and the error message is just hnvm's banner (`Resolved node X to Y`, `Using Hermetic NodeJS vX`) with no actual npm error visible.

**Cause:** `hnvm` (Compass's Node version manager, installed via the `work` nix-darwin machine configs) prints a diagnostic banner on every `node`/`npm` invocation. When an install aborts, that banner is whatever ends up in the captured stderr, burying the real failure reason.

**Fix:** `work/.config/shell/exports.work.sh` and `work/.config/fish/config.work.fish` set `HNVM_QUIET=true`, which silences the banner so real npm errors surface cleanly.

### `[nvim-treesitter/install/<lang>] error: ... ENOENT ... (cmd): 'tree-sitter'`

**Symptom:** Opening any file (e.g. a `.env`) triggers a parser install and fails with an ENOENT on the `tree-sitter` command, for one or more of the pinned parsers (`bash`, `c`, `diff`, `html`, `lua`, `luadoc`, `markdown`, `markdown_inline`, `query`, `vim`, `vimdoc`).

**Cause — two distinct scenarios that produce the identical error text:**
1. **Transient race (macOS, tree-sitter actually installed):** `vim.system`/libuv raise the same ENOENT whether the `tree-sitter` binary is missing *or* the working directory nvim-treesitter tries to spawn the process into doesn't exist. nvim-treesitter computes and deletes that cwd from a cache directory shared across all concurrent nvim instances (`~/.cache/nvim/tree-sitter-<lang>`), so with multiple nvim windows open and a parser needing (re)install, one window can delete the cwd out from under another's spawn. Diagnostic signature: intermittent, only some parsers fail, `which tree-sitter` and `vim.fn.exepath('tree-sitter')` both resolve fine, and multiple nvim processes were running concurrently.
2. **Missing binary (remote-sandbox / Linux, tree-sitter never installed):** On a `remote-sandbox`-profile machine, `tree-sitter` was only ever provisioned via `shared/.config/nix-darwin/darwin.nix` (macOS/nix-darwin only) — `remote-sandbox/bin/install-deps.sh` had no installer for it. Diagnostic signature: **100% reproducible**, every pinned parser fails every time, `which tree-sitter` fails outright, `vim.fn.exepath('tree-sitter')` returns empty in headless nvim, `~/.local/share/nvim/site/parser/` doesn't exist at all, and there's no concurrency (a single nvim process reproduces it).

**Fix:**
- If diagnostics match scenario 1 (binary present, only intermittent failures, multiple nvim windows open): no action needed — reopen the file or restart nvim; it's benign.
- If diagnostics match scenario 2 (binary genuinely absent): `remote-sandbox/bin/install-deps.sh` now installs `tree-sitter` as part of the `core` preset (downloads the pinned release's `tree-sitter-linux-x64.gz` from `tree-sitter/tree-sitter` releases on GitHub). Re-run `~/bin/install-deps.sh --preset core` (or `full`) on the affected machine, or `./install.sh` from the repo root, then restart nvim.

**Note on nvim-treesitter itself:** The upstream `nvim-treesitter/nvim-treesitter` repo was archived by its maintainer in April 2026 after a contentious rewrite requiring Neovim 0.12+. This repo's `shared/.config/nvim/init.lua` and `lazy-lock.json` still point at that now-archived (read-only) repo, pinned to a commit on its `main` branch (the post-rewrite API this config already uses). It still works as pinned, but will receive no further fixes/parsers from upstream. The community has organized a continuation at `neovim-treesitter/nvim-treesitter`; migrating `init.lua`'s plugin source to that fork is a separate, not-yet-done follow-up (tracked here so it isn't lost, not yet actioned).

### `:checkhealth` shows `opts.jump.float is deprecated` after upgrading to Neovim 0.12

**Symptom:** `:checkhealth vim.deprecated` reports:
```
WARNING opts.jump.float is deprecated. Feature will be removed in Nvim 0.14
ADVICE: use opts.jump.on_jump instead.
```
pointing at the `vim.diagnostic.config { jump = { float = true } }` call in `init.lua`.

**Cause:** Neovim 0.12 replaced `vim.diagnostic.Opts.Jump.float` with an `on_jump` callback. But `on_jump` **does not exist on 0.11** — setting it there doesn't error, it's just silently ignored (confirmed by testing against a real 0.11.4 binary: `vim.diagnostic.jump()` moves the cursor but never opens the float). Since this config's `init.lua`/`lazy-lock.json` are shared across every machine in the fleet, and machines upgrade to a new Neovim version on their own schedule, naively switching to `on_jump` would silently break the auto-float-on-jump behavior on any machine still running 0.11.

**Fix:** Version-gate the option with `vim.fn.has 'nvim-0.12'` so the same `init.lua` behaves correctly whichever Neovim version is currently installed:
```lua
jump = (vim.fn.has 'nvim-0.12' == 1) and {
  on_jump = function(_, bufnr) vim.diagnostic.open_float { bufnr = bufnr, scope = 'cursor', focus = false } end,
} or { float = true },
```
This is the general pattern for any future 0.11→0.12 (or later) deprecation surfaced by `:checkhealth` on a fleet that upgrades machine-by-machine rather than all at once: gate on `vim.fn.has 'nvim-0.12'` rather than doing a hard cutover, until every machine is confirmed upgraded.

### Resizing the terminal sometimes crashes with `picker.lua:229: attempt to index field 'preview' (a nil value)`

**Symptom:** Resizing the terminal window (e.g. tmux pane resize) while the Snacks explorer sidebar is open occasionally throws:
```
vim.schedule callback: .../snacks/picker/core/picker.lua:229: attempt to index field 'preview' (a nil value)
stack traceback:
        .../snacks/picker/core/picker.lua:229: in function 'init_layout'
        .../snacks/picker/core/picker.lua:373: in function 'set_layout'
        .../snacks/picker/core/picker.lua:280: in function <.../snacks/picker/core/picker.lua:279>
```

**Cause:** A race between two independent `VimResized` handlers on the same explorer picker instance. `shared/.config/nvim/lua/custom/plugins/picker.lua` registers a `snacks-explorer-auto-resize` autocmd that calls `picker:close()` synchronously when the terminal narrows past `filetree_auto_close_width`. `snacks.nvim`'s own picker (`lua/snacks/picker/core/picker.lua`, `attach()`) independently listens for `VimResized` on every open picker to relayout itself, and defers that relayout via `vim.schedule`. `picker:close()` does most of its teardown synchronously but *also* defers the actual field cleanup (including setting `self.preview = nil`) via `vim.schedule`. Because our autocmd is registered earlier (at `VimEnter`) than the picker's own listener (registered when the explorer opens), our `close()` call reaches its `vim.schedule` first, so our teardown callback runs *before* snacks' own relayout callback — which then dereferences the now-nil `self.preview`.

**Fix:** Wrap the body of the `snacks-explorer-auto-resize` autocmd callback in an extra `vim.schedule()`. This defers the actual `close()`/`open()` call by one tick, so snacks' own relayout callback (scheduled earlier in the same `VimResized` pass) runs and completes *before* our close's teardown nils out `self.preview`. Same pattern already used by the `nvim-tree` provider's `WinLeave` auto-close handler in the same file, for the same class of race.

### Yanking in Neovim doesn't populate the system clipboard when SSH'd into a remote-sandbox box

**Symptom:** `y`/yank in Neovim over SSH into a `remote-sandbox` (or `rca`/`crafting`) box doesn't reach the local clipboard — pasting outside Neovim gets nothing. Copying via the terminal/multiplexer itself (e.g. herdr's own text selection) works fine, and it may also work in *other* SSH sessions into the same class of box.

**Cause:** Two things compound:
1. `remote-sandbox/bin/install-deps.sh` never installs a clipboard binary (`xclip`/`xsel`/`wl-copy`/`pbcopy`) — these are rootless Ubuntu boxes with no X/Wayland session, so there's nothing for Neovim's clipboard provider to shell out to.
2. Neovim 0.10+'s built-in OSC-52 auto-detect (`autoload/provider/clipboard.vim`) only activates when `'clipboard'` is empty (`&clipboard ==# ''`). Kickstart's `init.lua` sets `vim.o.clipboard = 'unnamedplus'`, so that auto-detect path is always skipped.

The only remaining path is via tmux: if Neovim sees `$TMUX` set, it shells out to `tmux set-buffer`, and `remote-sandbox/.tmux.conf`'s `set -g set-clipboard on` (+ `allow-passthrough on`) relays that up through the SSH connection as OSC-52. That's why it can appear to work in some sessions (attached to tmux) and not others (not attached, or nvim started before attaching) — the underlying gap is the same in both cases, only the tmux relay happens to paper over it.

**Fix:** `shared/.config/nvim/lua/custom/plugins/options.lua` now explicitly sets `vim.g.clipboard` to the OSC-52 provider (`require('vim.ui.clipboard.osc52')`) whenever `vim.env.SSH_TTY` **or** `vim.env.SSH_CONNECTION` is set, bypassing the tool/tmux dependency entirely. Local (non-SSH) sessions are unaffected and keep using `pbcopy`/etc.

Note: this originally keyed off `SSH_TTY` alone. `SSH_TTY` is only set by sshd when a pty was allocated for the session — on some boxes (e.g. this fleet's remote-sandbox machines) it comes back empty even for normal interactive logins, so the gate never fired there. `SSH_CONNECTION` is set whenever there's a remote client at all, TTY or not, and is the more reliable signal — but checking both covers whatever quirk a given server/client combo has, since it's plausible some other setup has `SSH_TTY` set without `SSH_CONNECTION` (or vice versa).

This does still require the terminal on the *local* end of the SSH connection (herdr, iTerm2, etc.) to understand OSC-52 — if the fix doesn't work, check that next.

### `p`/`P` hangs forever with "Waiting for OSC 52 response from the terminal" over SSH

**Symptom:** After the OSC-52 yank fix above, pasting (`p`/`P`) in Neovim over SSH into a `remote-sandbox`/`rca`/`crafting` box hangs indefinitely, with the command line showing `Waiting for OSC 52 response from the terminal. Press Ctrl-C to interrupt...`.

**Cause:** The `vim.g.clipboard` override in `shared/.config/nvim/lua/custom/plugins/options.lua` originally wired up both `copy` *and* `paste` to `require('vim.ui.clipboard.osc52')`. OSC-52 copy is one-way (nvim just writes an escape sequence, no reply expected), but OSC-52 *paste* requires nvim to send a query and then block reading the terminal's reply off the same TTY. Most terminals — and definitely anything behind tmux/multiplexing — either don't implement that response leg or disable it by default (it's a security-sensitive feature, since it lets any program that can write to the TTY read the system clipboard). With no reply ever arriving, every `p`/`P` blocked forever.

**Fix:** Removed the `paste` table from the `vim.g.clipboard` override entirely, leaving only `copy`. Without a custom `paste` provider, `p`/`P` fall back to normal register behavior (instant, no host-clipboard fetch) — yank-out still reaches the local clipboard via OSC-52, paste just no longer tries to pull the host clipboard back in.

## lazygit

### Dedicated lazygit pane/tab is slow to open on remote-sandbox/crafting boxes (auto-fetches)

**Symptom:** The `lg` shell alias opens lazygit instantly (no auto-fetch), but opening lazygit via a dedicated multiplexer pane/tab (tmux `prefix+g`, or herdr `prefix+G`) is slow and shows a fetch spinner/delay on open, especially on large monorepos (e.g. the crafting box's urbancompass repo).

**Cause:** Three separate launchers each hardcoded their own `--use-config-file` list (or none at all), so none of them picked up `config-remote-sandbox.yml` — the overlay that sets `autoFetch: false` / `fetchAll: false` for the `remote-sandbox` profile:
- `shared/.config/tmux/scripts/lazygit-tab.sh` (`prefix+g` tab) only checked for `config-work.yml` (added for the `work` profile; nobody updated it when `remote-sandbox` got its own overlay).
- `shared/.config/tmux/conf.d/50-apps.conf`'s `prefix+G` popup binding ran plain `lazygit` via `tmux-popup` — **no** `--use-config-file` at all, not even the base `config.yml`.
- `shared/.config/herdr/config.toml`'s `prefix+G` binding ran plain `bash -lc lazygit` — same, no config file at all.

The `lg` alias was the only launcher that loaded the overlay correctly, because it hardcodes `config-remote-sandbox.yml` directly (it's defined in the `remote-sandbox` profile's own alias override).

**Fix:** Added `shared/bin/lazygit-launch`, a shared launcher script that builds the `--use-config-file` list (`config.yml,config-tab.yml` plus whichever of `config-work.yml`/`config-remote-sandbox.yml` exists on the current box) and `exec`s lazygit with it. All three launch sites (`lazygit-tab.sh`, the tmux popup binding, and herdr's `prefix+G` binding) now call `lazygit-launch` instead of duplicating (or omitting) the config-file logic. File-existence checks make it safe everywhere — a missing overlay just has no effect.

**Takeaway:** When there's more than one entry point into the same tool (shell alias, tmux binding, herdr binding, ...), duplicated config-building logic silently drifts. Centralize it in one script on `$PATH` and have every entry point call that.

### lazygit still hangs on open even with autoFetch/fetchAll disabled and the right config file loaded

**Symptom:** After the fix above (all launchers loading `config-remote-sandbox.yml`), lazygit was still slow/unresponsive opening in some monorepos (e.g. urbancompass, uc-frontend) even though auto-fetch was confirmed off — the delay was lazygit loading branch/tag/ref data, not fetching.

**Cause:** Sheer git data scale, unrelated to lazygit's own config. The sandbox image pre-clones these repos with git's default wide refspec (`+refs/heads/*:refs/remotes/origin/*`) and full tags *before* dotfiles are stowed. On monorepos with a long history of feature branches and CI tags, that means tens of thousands of stale remote-tracking branches and tags baked into the local repo (uc-frontend had ~137K tags and ~18K remote branches) — lazygit (and plain `git` commands) have to enumerate all of that on every open, regardless of fetch behavior.

`remote-sandbox/.gitconfig-monorepo`'s `tagOpt = --no-tags` (activated per-repo via `[includeIf]`) only prevents *future* tag fetches — it can't narrow a refspec or delete refs that already exist in a clone made before the config took effect.

**Fix:** Added `shared/bin/optimize-monorepos`, a one-time fixup script run from each sandbox profile's post-stow hook (see `crafting/.hooks/post-stow.sh`) right after repos are bootstrapped. For every repo under `~/development/*/` where `.gitconfig-monorepo` is already active (sentinel: `remote.origin.tagOpt == --no-tags`), it: narrows `remote.origin.fetch` to `master` + a configurable branch-prefix glob (`MONOREPO_BRANCH_PREFIX`, default `jjs`) via `git remote set-branches`, deletes all local tags, and deletes remote-tracking branches outside that allowed set. Idempotent — a repo that's already narrowed is a fast no-op on rerun. An optional `--gc` flag runs `git gc --aggressive --prune=now` per repo afterward.

**Takeaway:** A config setting that only affects *future* fetches (`tagOpt`, narrowed refspecs, etc.) can't fix data that's already on disk from before the config existed. Pre-baked sandbox images need an explicit one-time migration step, not just a config change, to bring existing clones in line.

## television

### tv opens `files` channel instead of the requested channel (e.g. `sesh`, `pj`)

**Symptom:** Running `tv sesh` or `tv pj` from a directory like `~/development` opens the default `files` channel instead of the requested cable channel.

**Cause:** Television's CLI has ambiguous positional args `[CHANNEL] [PATH]`. When a filesystem entry matching the argument name exists in the CWD (e.g. `~/development/sesh/` or `~/development/pj`), tv treats the argument as a PATH and falls back to the default channel.

**Fix:** Pass `-d $HOME` to `tmux-popup` so the popup opens with CWD set to `$HOME`, which is unlikely to contain files/dirs named after tv channels. The `tmux-popup` script forwards `-d` directly to `tmux display-popup`.

All affected bindings (`Prefix+o`, `Prefix+f`, `Prefix+P`) and `sesh-or-stay.sh` have been updated to use `-d $HOME`.
