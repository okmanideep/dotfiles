#!/bin/bash
set -e

# Colors for output
GREEN='\033[0;32m'
NC='\033[0m'

log() {
    echo -e "${GREEN}==>${NC} $1"
}

# Initialize asdf completions
log "Initializing asdf completions..."
mkdir -p ~/.asdf/completions
# Temporary fix for [asdf-vm/asdf#2156](https://github.com/asdf-vm/asdf/issues/2156)
asdf completion nushell | sed 's/get --ignore-errors/get -o/g' > ~/.asdf/completions/nushell.nu

# Install plugins
PLUGINS=(java kotlin ruby golang nodejs uv)

for plugin in "${PLUGINS[@]}"; do
    if ! asdf plugin list | grep -q "^$plugin$"; then
        log "Adding asdf plugin: $plugin"
        asdf plugin add "$plugin"
    else
        log "asdf plugin already installed: $plugin"
    fi
done

# Install latest versions
for plugin in "${PLUGINS[@]}"; do
    log "Installing latest $plugin..."
    if [ "$plugin" = "java" ]; then
        asdf install "$plugin" openjdk-21
        asdf set -u "$plugin" openjdk-21
    else
        asdf install "$plugin" latest
        asdf set -u "$plugin" latest
    fi
done

log "asdf setup complete!"
