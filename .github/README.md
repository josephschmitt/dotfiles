# GitHub Actions

This directory contains GitHub Actions workflows and scripts for automated testing and quality checks.

## Workflows

### Shell Startup Performance (`shell-performance.yml`)

Automatically measures and reports shell startup performance on pull requests that modify shell configuration files.

**Triggers on changes to:**
- Shell configuration files (`.bashrc`, `.zshrc`, `.profile`, etc.)
- Shell module files (`.config/shell/**`, `.config/fish/**`)
- Any profile-specific shell configurations

**What it does:**
1. Measures startup time for bash, zsh, and fish shells (10 iterations each)
2. Compares PR branch performance against the base branch
3. Posts a comment on the PR with performance comparison table
4. Updates the comment if already exists (no comment spam)

**Performance indicators:**
- 🚀 **Faster** - PR improves startup time
- ✅ **Similar** - Changes within 5ms (acceptable)
- ⚠️ **Slower** - PR degrades startup time by >5ms

**Debugging:**
- Check the workflow logs in the Actions tab
- The script outputs detailed timing data for each iteration
- Both raw JSON results are included in the collapsed details section

## Scripts

### `scripts/measure-shell-startup.sh`

Measures shell startup times by running each shell with `exit` command and timing it.

**Usage:**
```bash
./measure-shell-startup.sh [iterations] [output-file]
```

**Parameters:**
- `iterations` - Number of times to measure (default: 10)
- `output-file` - JSON output file path (default: startup-times.json)

**Output format:**
```json
{
  "bash": {"avg": 45.2, "min": 42.1, "max": 48.9},
  "zsh": {"avg": 78.5, "min": 75.2, "max": 82.1},
  "fish": {"avg": 52.3, "min": 49.8, "max": 55.7}
}
```

All times are in milliseconds.

## Local Testing

You can test shell performance locally using the measurement script:

```bash
# From repository root
.github/scripts/measure-shell-startup.sh 10 my-times.json
cat my-times.json
```

This helps identify performance regressions before creating a PR.
