# Nix setup on Linux/Ubuntu

## Install

```sh
# First time:
$ nix profile install ~/dotfiles/.config/nix#default

# On later updates:
$ cd ~/dotfiles/.config/nix
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

### Docker daemon crash auto-restart

If Docker daemon crashes with segfaults (SIGSEGV), containers won't auto-restart because Docker treats them as "manually stopped". This service automatically restarts all compose services when Docker daemon restarts.

**Setup:**
```sh
# Copy service files to system directories
sudo cp ~/dotfiles/.config/nix/docker-compose-restart.service /etc/systemd/system/
sudo cp ~/dotfiles/.config/nix/restart-docker-compose.sh /usr/local/bin/
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
