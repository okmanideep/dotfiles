#!/bin/bash
set -e

# Colors for output
GREEN='\033[0;32m'
NC='\033[0m'

log() {
    echo -e "${GREEN}==>${NC} $1"
}

# Initialize starship
log "Initializing starship..."
mkdir -p ~/.cache/starship
starship init nu > ~/.cache/starship/init.nu
