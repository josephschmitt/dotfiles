# Immich Sync

Automated synchronization from Apple Photos to [Immich](https://immich.app) self-hosted photo management.

## Overview

This setup provides daily automated sync of new and modified photos from Apple Photos to your Immich instance:

- **Source**: Apple Photos (primary library)
- **Destination**: Immich (backup/self-hosted)
- **Schedule**: Daily at 2:00 AM
- **Features**: Preserves albums, metadata, and folder structure

## Tools

- **[osxphotos](https://github.com/RhetTbull/osxphotos)**: Exports from Apple Photos library
- **[immich-go](https://github.com/simulot/immich-go)**: Uploads to Immich with album support

## Setup

### 1. Initial Configuration

Copy the example configuration file and fill in your Immich details:

```bash
mkdir -p ~/.config/immich-sync
cp ~/.config/immich-sync/config.example ~/.config/immich-sync/config
```

Edit `~/.config/immich-sync/config`:
```bash
IMMICH_URL="https://your-immich-instance.com"
IMMICH_API_KEY="your-api-key-from-immich"
```

**To get your Immich API key:**
1. Log into your Immich instance
2. Go to User Settings → API Keys
3. Create a new API key
4. Copy the key to your config file

### 2. Apply nix-darwin Configuration

The LaunchAgent is declared in `shared/.config/nix-darwin/machines/mac-mini.nix` and will be automatically installed when you rebuild:

```bash
nix_rebuild
```

This will:
- Install `osxphotos` and `immich-go` via Homebrew
- Create the LaunchAgent to run daily at 2 AM
- Link the `immich-sync` script to `~/bin/`

### 3. Verify Setup

Check that the LaunchAgent is loaded:

```bash
launchctl list | grep immich-sync
```

## Usage

### Manual Sync

Run the sync script manually at any time:

```bash
immich-sync
```

### Check Sync Logs

View sync logs to monitor progress or troubleshoot issues:

```bash
tail -f ~/Library/Logs/immich-sync/sync.log
```

View LaunchAgent logs:

```bash
# Standard output
tail -f ~/Library/Logs/immich-sync/launchd-output.log

# Errors
tail -f ~/Library/Logs/immich-sync/launchd-error.log
```

### Control LaunchAgent

```bash
# Stop the agent
launchctl unload ~/Library/LaunchAgents/org.nixos.immich-sync.plist

# Start the agent
launchctl load ~/Library/LaunchAgents/org.nixos.immich-sync.plist

# Run immediately (don't wait for scheduled time)
launchctl start org.nixos.immich-sync
```

## How It Works

1. **Export**: `osxphotos` exports new/modified photos from Apple Photos
   - Uses `--update --only-new` for incremental sync
   - Organizes by date: `{year}/{month}/` structure
   - Preserves album associations via `--album-keyword`
   - Maintains export database to track what's been synced

2. **Upload**: `immich-go` uploads exported files to Immich
   - Creates albums matching Apple Photos albums
   - Preserves metadata and EXIF data
   - Handles duplicates intelligently

3. **Schedule**: LaunchAgent runs daily at 2 AM
   - Runs in background
   - Logs all output for monitoring
   - Automatically handles failures

## Directory Structure

```
~/Pictures/immich-sync/           # Export staging directory
  2024/
    01/                            # Photos organized by date
    02/
~/Library/Logs/immich-sync/       # Log files
  sync.log                         # Main sync log
  export.db                        # osxphotos export database
  launchd-output.log              # LaunchAgent stdout
  launchd-error.log               # LaunchAgent stderr
~/.config/immich-sync/
  config                           # Your configuration (gitignored)
```

## Troubleshooting

### Sync not running

1. Check LaunchAgent is loaded: `launchctl list | grep immich-sync`
2. Check system logs: `log show --predicate 'subsystem == "com.apple.launchd"' --last 1h | grep immich`
3. Verify configuration file exists and is readable: `cat ~/.config/immich-sync/config`

### Permission errors

osxphotos needs Full Disk Access to read Apple Photos library:
1. System Settings → Privacy & Security → Full Disk Access
2. Add Terminal (or the app running the script)
3. Restart the LaunchAgent

### Upload failures

1. Verify Immich URL is reachable: `curl -I $IMMICH_URL`
2. Check API key is valid in Immich settings
3. Review logs: `tail ~/Library/Logs/immich-sync/sync.log`

## Customization

### Change sync schedule

Edit `shared/.config/nix-darwin/machines/mac-mini.nix`:

```nix
StartCalendarInterval = [
  {
    Hour = 2;    # Change hour (0-23)
    Minute = 0;  # Change minute (0-59)
  }
];
```

Then rebuild: `nix_rebuild`

### Adjust export options

Edit `shared/bin/immich-sync` and modify the `osxphotos export` command flags. See [osxphotos documentation](https://rhettbull.github.io/osxphotos/) for available options.

### Multiple syncs per day

Add additional `StartCalendarInterval` entries:

```nix
StartCalendarInterval = [
  { Hour = 2; Minute = 0; }
  { Hour = 14; Minute = 0; }
];
```
