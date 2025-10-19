# Ubuntu Server Configuration

Configuration files specific to Ubuntu server machines.

## Installation

### First Time Setup

For a fresh Ubuntu server, use the bootstrap script to set up Docker and system dependencies:

```bash
# Clone the repo
git clone git@github.com:josephschmitt/dotfiles.git ~/dotfiles
cd ~/dotfiles

# Run bootstrap script (requires sudo)
sudo ubuntu-server/bin/bootstrap.sh
```

The bootstrap script automates:
- Docker CE installation (official repository)
- Docker systemd overrides for resilience
- System package installation (cifs-utils, build tools)
- User permissions (docker group)
- Docker network creation

See `ubuntu-server/bin/bootstrap.md` for detailed setup documentation.

### Install Dotfiles

After bootstrap (or on an already configured server):

```bash
stow shared ubuntu-server
```

## What's Included

- **Bootstrap Script** - Automated server setup for Docker and dependencies
  - `bin/bootstrap.sh` - One-command server configuration
  - `bin/bootstrap.md` - Detailed setup guide and manual steps
- **Nix Configuration** - Flake-based package management and system configuration
  - `flake.nix` - Package definitions and system configuration
  - `nix.conf` - Nix daemon configuration
  - System service files for Docker Compose management
  - Crontab configuration
- **Shell Aliases** - Ubuntu server-specific command aliases
  - `nix_rebuild` - Rebuild nix profile from current configuration
  - `nix_update` - Update flake lockfile and rebuild profile

## Usage

This profile is designed for Ubuntu server environments running Docker-based services. It provides:
- Automated server bootstrap process
- Nix package management
- Docker Compose service management
- Automated system maintenance via cron

Use alongside the `shared` profile for a complete server environment:

```bash
stow shared ubuntu-server
```