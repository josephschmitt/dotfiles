#!/bin/bash
set -e

# Colors
BLUE="#61afef"
GREEN="#98c379"
YELLOW="#e5c07b"
RED="#e06c75"
PURPLE="#c678dd"
CYAN="#56b6c2"

# Parse arguments
DRY_RUN=false
if [[ "$1" == "--dry-run" ]]; then
  DRY_RUN=true
fi

# Check if gum is available
if ! command -v gum &>/dev/null; then
  echo "Error: gum is not installed. Please install gum first."
  echo "Visit: https://github.com/charmbracelet/gum"
  exit 1
fi

# Header
if [[ "$DRY_RUN" == true ]]; then
  gum style \
    --border double \
    --border-foreground "$PURPLE" \
    --padding "1 2" \
    --margin "1" \
    --align center \
    "🐳 Docker Server Bootstrap" \
    "" \
    "Automated setup for Docker CE" \
    "" \
    "🧪 DRY RUN MODE - No changes will be made"
else
  gum style \
    --border double \
    --border-foreground "$PURPLE" \
    --padding "1 2" \
    --margin "1" \
    --align center \
    "🐳 Docker Server Bootstrap" \
    "" \
    "Automated setup for Docker CE"
fi

gum style --foreground "$CYAN" "This script will install and configure Docker CE for running media and web services."
echo ""

gum style --foreground "$YELLOW" --bold "Prerequisites:"
echo "  ✓ Ubuntu 24.04 LTS or 25.04"
echo "  ✓ Sudo access"
echo "  ✓ Internet connection"
echo ""

# Confirmation
if [[ "$DRY_RUN" == true ]]; then
  if ! gum confirm "Continue with dry run?"; then
    gum style --foreground "$RED" "Dry run cancelled."
    exit 0
  fi
else
  if ! gum confirm "Continue with installation?"; then
    gum style --foreground "$RED" "Installation cancelled."
    exit 0
  fi
fi

# Step 1
echo ""
gum style \
  --foreground "$BLUE" \
  --bold \
  "Step 1/7: Installing prerequisites..."

if [[ "$DRY_RUN" == true ]]; then
  gum spin --spinner dot --title "Would install: ca-certificates, curl, cifs-utils..." -- sleep 1
  gum style --foreground "$GREEN" "✓ Prerequisites installed (dry run)"
else
  gum spin --spinner dot --title "Updating package lists..." -- \
    sudo apt-get update -qq
  gum spin --spinner dot --title "Installing ca-certificates, curl, cifs-utils..." -- \
    sudo apt-get install -y ca-certificates curl cifs-utils -qq
  gum style --foreground "$GREEN" "✓ Prerequisites installed"
fi

# Step 2
echo ""
gum style \
  --foreground "$BLUE" \
  --bold \
  "Step 2/7: Adding Docker's official GPG key..."

if [[ "$DRY_RUN" == true ]]; then
  gum spin --spinner dot --title "Would download Docker GPG key..." -- sleep 1
  gum style --foreground "$GREEN" "✓ GPG key added (dry run)"
else
  sudo install -m 0755 -d /etc/apt/keyrings
  gum spin --spinner dot --title "Downloading Docker GPG key..." -- \
    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
  sudo chmod a+r /etc/apt/keyrings/docker.asc
  gum style --foreground "$GREEN" "✓ GPG key added"
fi

# Step 3
echo ""
gum style \
  --foreground "$BLUE" \
  --bold \
  "Step 3/7: Adding Docker repository..."

if [[ "$DRY_RUN" == true ]]; then
  gum spin --spinner dot --title "Would add Docker repository..." -- sleep 1
  gum style --foreground "$GREEN" "✓ Docker repository added (dry run)"
else
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" |
    sudo tee /etc/apt/sources.list.d/docker.list >/dev/null
  gum style --foreground "$GREEN" "✓ Docker repository added"
fi

# Step 4
echo ""
gum style \
  --foreground "$BLUE" \
  --bold \
  "Step 4/7: Installing Docker CE..."

if [[ "$DRY_RUN" == true ]]; then
  gum spin --spinner dot --title "Would install Docker CE packages..." -- sleep 2
  gum style --foreground "$GREEN" "✓ Docker CE installed (dry run)"
else
  gum spin --spinner dot --title "Updating package lists..." -- \
    sudo apt-get update -qq
  gum spin --spinner dot --title "Installing Docker CE (this may take a minute)..." -- \
    sudo apt-get install -y \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    docker-buildx-plugin \
    docker-compose-plugin -qq
  gum style --foreground "$GREEN" "✓ Docker CE installed"
fi

# Step 5
echo ""
gum style \
  --foreground "$BLUE" \
  --bold \
  "Step 5/7: Configuring Docker systemd overrides..."

if [[ "$DRY_RUN" == true ]]; then
  gum spin --spinner dot --title "Would create systemd override..." -- sleep 1
  gum style --foreground "$GREEN" "✓ Systemd overrides configured (dry run)"
else
  sudo mkdir -p /etc/systemd/system/docker.service.d
  sudo tee /etc/systemd/system/docker.service.d/override.conf >/dev/null <<'EOF'
[Service]
Restart=on-failure
RestartSec=10

[Unit]
StartLimitIntervalSec=30
StartLimitBurst=20
EOF
  sudo systemctl daemon-reload
  gum style --foreground "$GREEN" "✓ Systemd overrides configured"
fi

# Step 6
echo ""
gum style \
  --foreground "$BLUE" \
  --bold \
  "Step 6/7: Adding user to docker group..."

if [[ "$DRY_RUN" == true ]]; then
  gum spin --spinner dot --title "Would add $USER to docker group..." -- sleep 1
  gum style --foreground "$GREEN" "✓ User added to docker group (dry run)"
else
  sudo usermod -aG docker $USER
  gum style --foreground "$GREEN" "✓ User added to docker group"
fi

# Step 7
echo ""
gum style \
  --foreground "$BLUE" \
  --bold \
  "Step 7/7: Creating Docker networks..."

if [[ "$DRY_RUN" == true ]]; then
  gum spin --spinner dot --title "Would create 'edge' network..." -- sleep 1
  gum style --foreground "$GREEN" "✓ 'edge' network created (dry run)"
else
  if ! docker network ls | grep -q edge; then
    docker network create edge >/dev/null 2>&1
    gum style --foreground "$GREEN" "✓ Created 'edge' network"
  else
    gum style --foreground "$YELLOW" "✓ 'edge' network already exists"
  fi
fi

# Success summary
echo ""
if [[ "$DRY_RUN" == true ]]; then
  gum style \
    --border double \
    --border-foreground "$GREEN" \
    --padding "1 2" \
    --margin "1" \
    --align center \
    "✓ Bootstrap Complete (Dry Run)!"
else
  gum style \
    --border double \
    --border-foreground "$GREEN" \
    --padding "1 2" \
    --margin "1" \
    --align center \
    "✓ Bootstrap Complete!"
fi

echo ""
gum style --foreground "$CYAN" --bold "Docker versions installed:"

if [[ "$DRY_RUN" == true ]]; then
  gum style --foreground "$GREEN" "  Client: 28.5.1"
  gum style --foreground "$GREEN" "  Server: 28.5.1"
  echo ""
  gum style --foreground "$GREEN" "  Compose: v2.40.1"
else
  CLIENT_VERSION=$(docker version --format '{{.Client.Version}}' 2>/dev/null || echo "N/A")
  SERVER_VERSION=$(docker version --format '{{.Server.Version}}' 2>/dev/null || echo "N/A")
  gum style --foreground "$GREEN" "  Client: $CLIENT_VERSION"
  gum style --foreground "$GREEN" "  Server: $SERVER_VERSION"
  echo ""
  COMPOSE_VERSION=$(docker compose version --short 2>/dev/null || echo "N/A")
  gum style --foreground "$GREEN" "  Compose: $COMPOSE_VERSION"
fi

# Important notes
echo ""
gum style \
  --border rounded \
  --border-foreground "$YELLOW" \
  --padding "0 1" \
  --margin "1 0" \
  "⚠️  IMPORTANT: Log out and back in for docker group to take effect" \
  "   Or run: newgrp docker"

# Next steps
echo ""
gum style --foreground "$PURPLE" --bold "Next steps:"

echo "  1. Restore/clone your other projects to ~/projects/"
echo "  2. Navigate to each project and run: $(gum style --foreground "$CYAN" "docker compose up -d")"
echo "  3. Verify services: $(gum style --foreground "$CYAN" "docker ps")"

echo ""
gum style --foreground "$YELLOW" "📚 See docs/bootstrap.md for more information"

if [[ "$DRY_RUN" == true ]]; then
  echo ""
  gum style \
    --border rounded \
    --border-foreground "$CYAN" \
    --padding "0 1" \
    --margin "1 0" \
    "ℹ️  This was a dry run. No changes were made to your system." \
    "   Run the real bootstrap: ./scripts/bootstrap-server.sh"
fi
