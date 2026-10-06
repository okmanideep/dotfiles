#!/bin/bash
set -e

# Colors for output
GREEN='\033[0;32m'
NC='\033[0m'

log() {
    echo -e "${GREEN}==>${NC} $1"
}

if ! command -v mise &>/dev/null; then
    echo "mise is not installed or is not on PATH" >&2
    exit 1
fi

# Preserve the former asdf global pins as mise's global configuration.
while read -r tool version; do
    [ -n "$tool" ] || continue
    mise use --global "$tool@$version"
done < "$(cd "$(dirname "$0")/.." && pwd)/.tool-versions"

log "Installing configured tool versions..."
mise install

# Keep machine-specific generated output outside the symlinked dotfiles directory.
mkdir -p "$HOME/.cache/mise"
mise activate nu > "$HOME/.cache/mise/init.nu"

log "mise setup complete!"
