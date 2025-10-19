# Server Bootstrap Guide

This document describes how to recreate this Docker server from scratch.

## Prerequisites

- Ubuntu 25.04 (or 24.04 LTS recommended)
- SSH access to the server
- Backups of Docker project directories
- Network access to NAS at 192.168.4.54

## Quick Start

```bash
# 1. Clone this repo and run bootstrap script
git clone git@github.com:josephschmitt/dotfiles.git ~/dotfiles
cd ~/dotfiles
sudo ubuntu-server/bin/bootstrap.sh

# 2. Restore other project directories
# - Clone/restore ~/projects/schmitt.town

# 3. Start services
cd ~/projects/schmitt.town && docker compose up -d
cd ~/projects/hbojoe && docker compose up -d
```

## What the Bootstrap Script Does

The `scripts/bootstrap-server.sh` script automates:

1. ✅ Install Docker CE (official repository)
2. ✅ Configure Docker systemd overrides
3. ✅ Install required system packages
4. ✅ Configure user permissions (add to docker group)
5. ✅ Set up Docker networks
6. ✅ Install docker-compose plugin

## Manual Steps (for reference)

### 1. Install Docker CE

```bash
# Add Docker's official GPG key
sudo apt-get update
sudo apt-get install -y ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add Docker repository
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker CE
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io \
  docker-buildx-plugin docker-compose-plugin

# Add user to docker group
sudo usermod -aG docker $USER

# Enable Docker service
sudo systemctl enable docker
sudo systemctl start docker
```

### 2. Configure Docker Systemd Override

This increases restart resilience for the daemon:

```bash
sudo mkdir -p /etc/systemd/system/docker.service.d
sudo tee /etc/systemd/system/docker.service.d/override.conf <<EOF
[Service]
Restart=on-failure
RestartSec=10

[Unit]
StartLimitIntervalSec=30
StartLimitBurst=20
EOF

sudo systemctl daemon-reload
sudo systemctl restart docker
```

### 3. Create Docker Networks

```bash
# Create external networks as needed
# (none required by default)
```

### 4. Install Additional System Packages

```bash
# CIFS utilities for mounting NAS shares
sudo apt-get install -y cifs-utils

# Optional monitoring/debugging tools
sudo apt-get install -y htop iotop ncdu
```

## Project Structure

After setup, your project structure should be:

```
~/projects/
├── schmitt.town/            # Web services
│   └── docker-compose.yaml
└── hbojoe/                  # Media services (this repo)
    ├── docker-compose.yaml
    ├── scripts/
    │   ├── bootstrap-server.sh
    │   └── restore-from-backup.sh
    └── docs/
        ├── bootstrap.md
        └── backup-restore.md
```

## NAS/CIFS Configuration

### Current CIFS Mounts

All media mounts are managed by Docker volumes (defined in docker-compose.yaml):

- `//192.168.4.54/media` → hbojoe_media (Plex)
- `//192.168.4.54/media/Movies` → hbojoe_movies (Radarr)
- `//192.168.4.54/media/Movies (4K)` → hbojoe_movies_4k (Radarr 4K)
- `//192.168.4.54/media/TV Shows` → hbojoe_shows (Sonarr)
- `//192.168.4.54/media/TV Shows (4K)` → hbojoe_shows_4k (Sonarr 4K)

Credentials are stored in `docker-compose.yaml` (ensure this file is backed up securely).

### Alternative: OS-level CIFS Mounts

If you prefer OS-level mounts (more stable), see `docs/cifs-os-mounts.md`.

## Backup Strategy

### What to Backup

**Critical (must backup)**:

- `~/projects/` - All docker-compose files and configs
- `/var/lib/docker/volumes/*/config` - Application configurations
- NAS credentials (in compose files or .env files)

**Optional (can recreate)**:

- Docker images (can be re-pulled)
- Container state (will be recreated)

**External (already backed up on NAS)**:

- Media files
- Download history

### Backup Commands

```bash
# Backup all project directories
tar -czf ~/backup-projects-$(date +%Y%m%d).tar.gz ~/projects/

# Backup Docker volume configs
sudo tar -czf ~/backup-docker-configs-$(date +%Y%m%d).tar.gz \
  /var/lib/docker/volumes/hbojoe_*/
```

### Restore from Backup

See `docs/backup-restore.md` for detailed restore procedures.

## Verification Checklist

After bootstrap, verify:

- [ ] Docker version: `docker version` (should show 28.x client and server)
- [ ] Docker Compose: `docker compose version` (should show v2.40+)
- [ ] User in docker group: `groups | grep docker`
- [ ] Docker daemon running: `systemctl status docker`

- [ ] Can pull images: `docker pull hello-world`

## Troubleshooting

### Docker daemon not starting

```bash
# Check logs
sudo journalctl -u docker.service -n 50

# Verify configuration
docker info
```

### Permission denied

```bash
# Ensure user in docker group
sudo usermod -aG docker $USER
# Log out and back in, or:
newgrp docker
```

### CIFS mounts failing

```bash
# Test NAS connectivity
ping 192.168.4.54

# Install CIFS utilities
sudo apt-get install -y cifs-utils

# Check mount manually
sudo mount -t cifs -o username=plex,password=XXX //192.168.4.54/media /tmp/test
```

## Security Considerations

### Secrets Management

**Current approach**: Credentials in docker-compose.yaml files

**Recommendations for production**:

- Use `.env` files with restricted permissions (chmod 600)
- Keep .env files out of git (.gitignore)
- Store encrypted backups of .env files separately
- Consider using Docker secrets or vault for production

### Example .env file structure

```bash
# ~/projects/hbojoe/.env
NAS_USERNAME_PLEX=plex
NAS_PASSWORD_PLEX=<password>
NAS_USERNAME_MEDIADL=mediadl
NAS_PASSWORD_MEDIADL=<password>
```

Then reference in docker-compose.yaml:

```yaml
volumes:
  media:
    driver_opts:
      type: cifs
      o: "username=${NAS_USERNAME_PLEX},password=${NAS_PASSWORD_PLEX},vers=3.0,uid=1027,gid=100"
      device: "//192.168.4.54/media"
```

## Monitoring

### Check for Docker crashes

```bash
# Recent daemon crashes
journalctl -u docker.service --since "7 days ago" | grep -i "SEGV\|core-dump"

# Daemon uptime
systemctl status docker | grep Active
```

### Container health

```bash
# All containers
docker ps -a

# Health status
docker ps --filter "health=healthy"

# Container logs
docker compose logs -f [service_name]
```

## Updates

### Docker CE

```bash
# Update Docker to latest version
sudo apt update
sudo apt upgrade docker-ce docker-ce-cli containerd.io \
  docker-buildx-plugin docker-compose-plugin
```

### Container images

Watchtower handles automatic updates (if configured), or manually:

```bash
cd ~/projects/hbojoe
docker compose pull
docker compose up -d
```

## Additional Resources

- [Official Docker Documentation](https://docs.docker.com/)
- [Docker Compose Reference](https://docs.docker.com/compose/compose-file/)
- [This Server's Analysis](./2025-10-19/analysis.md) - Root cause of previous crashes
- [Migration Plan](./2025-10-19/plan.md) - How we migrated to Docker CE

---

**Last Updated**: 2025-10-19  
**Server**: buntubox  
**Maintained by**: josephschmitt
