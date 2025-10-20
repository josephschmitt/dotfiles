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
sudo bootstrap
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
  - `bin/bootstrap` - One-command server configuration
  - `bin/bootstrap.md` - Detailed setup guide and manual steps
- **Docker Compose Service Manager** - Set up systemd services for Docker Compose projects
  - `bin/bootstrap-compose-service` - Register Docker Compose project as systemd service
  - `bin/docker-compose@.service` - Systemd template for Docker Compose projects
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

### Setting Up Docker Compose Services

To register a Docker Compose project as a systemd service that starts automatically on boot:

```bash
# Set up systemd service for a project
sudo bootstrap-compose-service <project-name>

# Example: Set up service for ~/hbojoe project
sudo bootstrap-compose-service hbojoe
```

This will:
1. Copy the systemd service template to `/etc/systemd/system/`
2. Enable the service to start on boot
3. Start the service immediately
4. Show the service status

The service expects your Docker Compose project to be at `~/projects/<project-name>/docker-compose.yaml`.

**Service Management:**

```bash
# Check service status
sudo systemctl status docker-compose@<project-name>.service

# Restart service
sudo systemctl restart docker-compose@<project-name>.service

# Stop service
sudo systemctl stop docker-compose@<project-name>.service

# Disable auto-start on boot
sudo systemctl disable docker-compose@<project-name>.service

# Pull latest images and restart (updates)
sudo systemctl reload docker-compose@<project-name>.service
```

**Features:**
- Automatic start on boot
- Depends on Docker service (won't start if Docker isn't running)
- Network-aware (waits for network connectivity)
- Restart on failure with rate limiting (20 attempts in 30 seconds)
- Supports `reload` for pulling updates and restarting containers