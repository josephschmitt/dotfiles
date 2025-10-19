# Ubuntu Server Configuration

Configuration files specific to Ubuntu server machines.

## Installation

```bash
stow ubuntu-server
```

## What's Included

- **Nix Configuration** - Flake-based package management and system configuration for Ubuntu servers
  - `flake.nix` - Package definitions and system configuration
  - `nix.conf` - Nix daemon configuration
  - System service files for Docker Compose management
  - Crontab configuration
- **Shell Aliases** - Ubuntu server-specific command aliases
  - `nix_rebuild` - Rebuild nix profile from current configuration
  - `nix_update` - Update flake lockfile and rebuild profile

## Usage

This profile is designed for Ubuntu server environments where you need:
- Nix package management
- Docker Compose service management
- Automated system maintenance via cron

Use alongside the `shared` profile for a complete server environment:

```bash
stow shared ubuntu-server
```