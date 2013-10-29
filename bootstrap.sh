#!/usr/bin/env bash

# Install homebrew
ruby -e "$(curl -fsSL https://raw.github.com/mxcl/homebrew/go)"

# Create SSH public/private keys
ssh-keygen -t rsa -C "me@joe.sh"

# Add common hosts
echo "173.230.151.220 krang" | sudo tee -a /etc/hosts >/dev/null

# Install Cask and native apps
source .brew-cask

# Configure Bash
cd "$(dirname "${BASH_SOURCE}")"
git pull origin master
function doIt() {
	rsync --exclude ".git/" --exclude ".DS_Store" --exclude "bootstrap.sh" \
		--exclude "README.md" --exclude "LICENSE-MIT.txt" -av --no-perms . ~
	source ~/.bash_profile
}

if [ "$1" == "--force" -o "$1" == "-f" ]; then
	doIt
else
	read -p "This may overwrite existing files in your home directory. Are you sure? (y/n) " -n 1
	echo
	if [[ $REPLY =~ ^[Yy]$ ]]; then
		doIt
	fi
fi
unset doIt

# Configure Fish
cp .fish ~/.config/fish/config.fish