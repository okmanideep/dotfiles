#!/bin/bash
set -euo pipefail

# Colors for output
GREEN='\033[0;32m'
NC='\033[0m'

# Tools installed and pinned by the dotfiles setup.
MISE_TOOLS=(
	"nodejs@25.2.1"
	"ruby@3.4.8"
	"golang@1.27.3"
	"uv@0.13.5"
	"java@openjdk-21"
	"kotlin@2.3.0"
	"flutter@3.35.6-stable"
	"zig@0.16.0"
	"stylua@2.5.2"
	"bun@1.4.3"
)

log() {
    echo -e "${GREEN}==>${NC} $1"
}

if ! command -v mise &>/dev/null; then
    echo "mise is not installed or is not on PATH" >&2
    exit 1
fi

# Configure the pinned tools for mise's global configuration.
for tool in "${MISE_TOOLS[@]}"; do
    mise use --global "$tool"
done

log "Installing configured tool versions..."
mise install

# Keep machine-specific generated output outside the symlinked dotfiles directory.
mkdir -p "$HOME/.cache/mise"
mise activate nu > "$HOME/.cache/mise/init.nu"

log "mise setup complete!"
