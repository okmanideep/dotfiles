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

# Plugin versions (plugin:version format for readability)
PLUGIN_SPECS=(
    "java:openjdk-21"
    "kotlin:2.3.0"
    "ruby:3.4.8"
    "golang:1.25.5"
    "nodejs:25.2.1"
    "uv:0.9.21"
    "flutter:3.35.6-stable"
    "zig:0.15.2"
)

# Install plugins
for spec in "${PLUGIN_SPECS[@]}"; do
    plugin="${spec%%:*}"
    if ! asdf plugin list | grep -q "^$plugin$"; then
        log "Adding asdf plugin: $plugin"
        asdf plugin add "$plugin"
    else
        log "asdf plugin already installed: $plugin"
    fi
done

# Install pinned versions
for spec in "${PLUGIN_SPECS[@]}"; do
    plugin="${spec%%:*}"
    version="${spec#*:}"
    log "Installing $plugin $version..."
    asdf install "$plugin" "$version"
    asdf set -u "$plugin" "$version"
done

log "asdf setup complete!"
