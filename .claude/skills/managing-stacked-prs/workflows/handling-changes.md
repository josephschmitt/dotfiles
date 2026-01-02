# Submitting, Updating, and Restacking

Guide for submitting PRs, handling feedback, and keeping your stack in sync.

## Submitting for Review

### Before Submitting

```bash
# Sync with trunk
gs rs

# Restack to catch conflicts early
gs sr

# Verify structure
gs log short

# Ensure tests pass
npm test
```

### Submit Strategies

**Submit entire stack:**
```bash
gs ss  # Stack Submit - creates/updates PRs for all branches
```

**Submit incrementally:**
```bash
gs dss  # Downstack Submit - current + below (foundation first)
# Later:
gs uss  # Upstack Submit - current + above
```

**Submit single branch:**
```bash
gs bs  # Branch Submit - just current branch
```

### Writing PR Descriptions

git-spice adds navigation comments automatically. You can enhance PRs:

```bash
# View PR after creation
gh pr view <pr-number>

# Edit PR
gh pr edit <pr-number> --body "## Summary
This PR adds authentication models.

## Stack
Part of authentication stack. See navigation comments below.

## Testing
npm test -- auth"

# Add labels
gh pr edit <pr-number> --add-label "stack" --add-label "backend"
```

## Handling Review Feedback

### Make Changes to a Branch

```bash
# 1. Checkout the branch
git checkout feature/auth-api

# 2. Make changes
# Edit files...

# 3. Commit
git add .
git commit -m "fix: address review feedback"

# 4. Restack branches above
gs upstack restack

# 5. Push (use --force-with-lease for safety)
git push --force-with-lease

# 6. Update upstack PRs
gs upstack submit
```

### Amend vs New Commit

**Amend for small fixes:**
```bash
git add .
git commit --amend --no-edit
git push --force-with-lease
```

**New commit for substantial changes:**
```bash
git add .
git commit -m "refactor: improve error handling per review"
git push
```

### Re-request Review

```bash
gh pr comment <pr-number> --body "Updated! Ready for re-review."
```

## Restacking

### When to Restack

Restack when:
- Trunk has new commits
- A lower branch in your stack was updated
- A PR in your stack was merged
- After pulling changes

### Restack Commands

**Full stack:**
```bash
gs sr  # Stack Restack - rebase all branches
```

**Upstack only:**
```bash
gs upstack restack  # After changing current branch
```

**Single branch:**
```bash
gs branch restack  # Rebase just this branch
```

### Handling Conflicts

When restacking causes conflicts:

```bash
# git-spice pauses, showing conflicts
# 1. View conflicted files
git status

# 2. Fix conflicts in your editor
# Edit files, remove <<<< ==== >>>> markers

# 3. Mark as resolved
git add <resolved-files>

# 4. Continue
git rebase --continue

# Or abort if needed
git rebase --abort
```

**Tips for conflicts:**
- Fix them one file at a time
- Test after resolving
- If stuck, abort and ask for help

## After Merges

When PRs start merging:

```bash
# 1. Sync repo (updates trunk, removes merged branches)
gs rs

# 2. Restack remaining branches
gs sr

# 3. Update remaining PRs
gs ss
```

git-spice automatically detects merged branches during `gs rs`.

## Common Scenarios

### Update After Trunk Changes

```bash
gs rs       # Pull latest trunk
gs sr       # Restack all branches
gs ss       # Update all PRs
```

### Split a Branch

If reviewer asks to split a PR:

```bash
# 1. Checkout the branch to split
git checkout feature/too-large

# 2. Create new branch from its base
base=$(git config --get branch.feature/too-large.spice-base)
git checkout $base
gs bc feature/part-1

# 3. Cherry-pick specific commits
git cherry-pick <commit-sha>

# 4. Update original branch to remove those commits
git checkout feature/too-large
git rebase -i $base
# Mark commits as 'drop' in interactive rebase

# 5. Restack
gs upstack restack

# 6. Submit both
gs ss
```

### Merge Branches

If two PRs should be combined:

```bash
# 1. Checkout lower branch
git checkout feature/part-1

# 2. Cherry-pick commits from upper branch
git cherry-pick <commits>

# 3. Delete upper branch
git branch -D feature/part-2
gh pr close <pr-number>

# 4. Update PRs
gs ss
```

### Reorder Stack

```bash
# Use interactive stack editing
gs stack edit

# Or manually:
# 1. Create new branch from desired base
# 2. Cherry-pick commits
# 3. Delete old branch
# 4. Restack
```

## Monitoring Progress

### Check Status

```bash
# View stack
gs log short

# View PRs
gh pr list --author @me

# Check specific PR
gh pr view <pr-number>

# Check PR status and reviews
gh pr status
```

### CI/CD

Monitor test status:
```bash
gh pr checks <pr-number>
```

## Best Practices

✅ **Sync regularly** - `gs rs` daily or before major work

✅ **Restack after changes** - Especially to lower branches

✅ **Test after restacking** - Ensure nothing broke

✅ **Respond to feedback quickly** - Keep the review moving

✅ **Merge bottom-up** - Lower PRs first, then dependencies

✅ **Use --force-with-lease** - Safer than --force

❌ **Don't use git rebase directly** - Use git-spice commands

❌ **Don't merge out of order** - Causes conflicts in upper PRs

❌ **Don't forget to update upstack** - Changes ripple up

## Troubleshooting

**Restack fails:**
```bash
git rebase --abort  # Start over
gs log short        # Check structure
gs sr              # Try again
```

**PR shows wrong commits:**
```bash
# Check base branch
gh pr view <pr-number> --json baseRefName
# Update if wrong
gh pr edit <pr-number> --base <correct-base>
```

**Lost in conflicts:**
```bash
git rebase --abort   # Bail out
# Ask for help or tackle one file at a time
```

See [../reference/commands.md](../reference/commands.md) for complete command reference.
