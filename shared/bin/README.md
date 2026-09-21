# Shared Utilities

This directory contains utility scripts available across all profiles.

## Utilities

### darwin-rebuild-wrapper.sh
Wrapper for nix-darwin rebuild operations (macOS only). Called via the `nix_rebuild` alias.

### helix-*.sh
Various Helix editor integration scripts

### immich-sync
Automated Apple Photos → Immich sync script (macOS only, mac-mini)
See `.config/immich-sync/README.md` for setup and usage

### assign_at_random.sh
Random assignment utility

### listCatalogInfo.sh
Catalog information listing utility

### optimize-monorepos
One-time fixup for repos pre-cloned before dotfiles were stowed: narrows each
monorepo's `remote.origin.fetch` to master + a branch-prefix glob and deletes
local tags / stale remote-tracking branches. Run from the sandbox profiles'
post-stow hooks. See the script header for flags/env vars.

### git-monorepo-track
Per-branch fetch-refspec management for narrowed monorepos, exposed via the
`git track` / `git untrack` / `git prune-tracks` / `git pl` aliases in each
profile's `.gitconfig-monorepo` (scoped to monorepos via `[includeIf]`).
`track` adds a branch-specific refspec so a branch outside the narrowed
namespace gets fetched; `untrack` / `prune-tracks` remove such refspecs so a
merged-and-deleted branch can't wedge every `git pull` with `fatal: couldn't
find remote ref ...`; `pl` is a self-healing pull (prune then pull).

### git-default-branch
Prints the repo's default branch name (`origin/HEAD`, falling back to a local
`main` or `master`). Exposed as `git default-branch`; used by the `br`/`plr`
aliases and by `lazygit-check-main-branch` / `workmux-merge.sh` instead of
hardcoding `master`.

### git-smart-branch
Creates a new branch from a base (defaulting to `origin/$(git
default-branch)`) or switches to an existing one. Exposed as the `br` alias.

### git-replace-branch
Switches to a new branch via `git smart-branch`, then force-deletes the old
branch (only on a successful switch). Exposed as the `brd` alias.

### git-clean-branches
Fetches, prunes remote-tracking refs, and deletes local branches whose
upstream is gone. Supports `--dry-run` to preview before deleting. Exposed as
the `cl` alias.

### git-worktree-sibling
Adds or removes a git worktree as a sibling directory (`../<repo>-<branch>`).
Exposed as the `wta` (add) / `wtr` (remove) aliases.