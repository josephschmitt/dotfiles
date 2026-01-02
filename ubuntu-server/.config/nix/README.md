# Nix setup on Linux/Ubuntu

## Install

```sh
# First time:
$ nix profile install ~/dotfiles/ubuntu-server/.config/nix#default

# On later updates:
$ cd ~/dotfiles/ubuntu-server/.config/nix
$ nix flake update           # refresh nixpkgs revision in flake.lock
$ nix profile upgrade --all  # rebuild your profile to the new lock file
```

## Various Ubuntu things

### Docker compose service

Copy the templates `docker-compose@.service` file to `/etc/systemd/system/`. To start up a service, run:

```sh
sudo systemctl enable --now docker-compose@{service-name}
```

Some other relevant commands:
```sh
# check health / logs
systemctl status docker-compose@{service-name}
journalctl -u docker-compose@{service-name} -f   # live logs

# graceful restart after editing compose.yml
sudo systemctl reload docker-compose@{service-name}

# stop or disable autostart
sudo systemctl stop docker-compose@{service-name}
sudo systemctl disable docker-compose@{service-name}
```

### Network Mounts Management (mounts command)

Global tool for managing systemd network mounts (NFS/SMB) across projects. Mount configurations are stored in project repositories (e.g., `~/schmitt.town/systemd/`), not in dotfiles.

**Usage:**
```sh
# From project directory with systemd/ folder
cd ~/schmitt.town
sudo mounts mount          # Install units, enable, and start mounts
mounts status              # Check status (no sudo needed)
sudo mounts unmount        # Stop, disable, and remove units

# From anywhere with explicit path
sudo mounts mount ~/schmitt.town
mounts status ~/schmitt.town

# Get help
mounts help
```

**How it works:**
1. Projects define mount units in `systemd/` directory (version-controlled)
2. `mounts mount` copies units to `/etc/systemd/system/` and enables them
3. Mounts auto-mount on first access, auto-unmount after inactivity
4. `mounts status` shows if units are out of sync with project sources

See your project's README (e.g., `~/schmitt.town/README.md`) for mount-specific setup instructions.

### Docker network mount dependency

Prevents Docker from starting before Tailscale and network mounts (NFS/SMB) are ready. Without this, containers may bind to empty local directories instead of mounted network shares during boot.

**Setup:**
```sh
# Copy drop-in override to system directory
sudo mkdir -p /etc/systemd/system/docker.service.d
sudo cp ~/dotfiles/ubuntu-server/.config/nix/docker.service.d/10-wait-for-nfs.conf \
        /etc/systemd/system/docker.service.d/10-wait-for-nfs.conf
sudo systemctl daemon-reload
```

**Verify:**
```sh
# Check that Docker waits for network mounts
systemctl show docker.service | grep -E "^(After|Wants)=" | grep -E '(nfs|mac-mini)'
```

### Docker daemon crash auto-restart

If Docker daemon crashes with segfaults (SIGSEGV), containers won't auto-restart because Docker treats them as "manually stopped". This service automatically restarts all compose services when Docker daemon restarts.

**Setup:**
```sh
# Copy service files to system directories
sudo cp ~/dotfiles/ubuntu-server/.config/nix/docker-compose-restart.service /etc/systemd/system/
sudo cp ~/dotfiles/ubuntu-server/.config/nix/restart-docker-compose.sh /usr/local/bin/
sudo chmod +x /usr/local/bin/restart-docker-compose.sh
sudo systemctl enable docker-compose-restart.service
```

**How it works:**
- `BindsTo=docker.service` triggers the service whenever Docker daemon starts
- Script waits 10 seconds for Docker to be ready, then restarts compose services
- Monitors compose directories: `~/hbojoe` and `~/schmitt.town`
- Logs activity to `/var/log/docker-compose-restart.log`

**Troubleshooting:**
```sh
# Check if service is enabled
systemctl is-enabled docker-compose-restart.service

# View logs
journalctl -u docker-compose-restart.service -f
tail -f /var/log/docker-compose-restart.log

# Test manually
sudo systemctl start docker-compose-restart.service
```

### Setting default editor in sudo
```sh
$ sudo update-alternatives --install /usr/bin/editor editor $(which nvim) 70
```
* `/usr/bin/editor`: the generic symlink every program (including sudo systemctl edit) consults
* `editor`: the name of the alternatives group
* `/usr/bin/nvim`: the real binary you want to add
* `70`: its priority (higher than nano’s 40 and vim.basic’s 30 so it wins in auto mode)
