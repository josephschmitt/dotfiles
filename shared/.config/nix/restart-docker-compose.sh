#!/bin/bash

# Auto-restart Docker Compose services after Docker daemon restart
# This script restarts all Docker Compose services that were running before daemon crash

set -e

LOG_FILE="/var/log/docker-compose-restart.log"
COMPOSE_DIRS=("/home/josephschmitt/hbojoe" "/home/josephschmitt/schmitt.town")

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

log "Starting Docker Compose auto-restart after daemon restart"

# Wait for Docker daemon to be fully ready
sleep 10

for dir in "${COMPOSE_DIRS[@]}"; do
    if [ -f "$dir/docker-compose.yaml" ]; then
        log "Restarting services in $dir"
        cd "$dir"
        
        # Pull latest images and restart services
        if docker-compose pull && docker-compose up -d; then
            log "Successfully restarted services in $dir"
        else
            log "ERROR: Failed to restart services in $dir"
        fi
    else
        log "WARNING: No docker-compose.yaml found in $dir"
    fi
done

log "Docker Compose auto-restart completed"