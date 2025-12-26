#!/bin/bash
set -e

# Colors for output
GREEN='\033[0;32m'
NC='\033[0m'

log() {
    echo -e "${GREEN}==>${NC} $1"
}

# Install asdf (not available in apt)
log "Installing asdf..."
if ! command -v asdf &>/dev/null; then
    ASDF_VERSION=$(curl -s https://api.github.com/repos/asdf-vm/asdf/releases/latest | grep '"tag_name"' | sed -E 's/.*"([^"]+)".*/\1/')
    ASDF_BINARY="asdf-${ASDF_VERSION}-linux-amd64.tar.gz"
    curl -LO "https://github.com/asdf-vm/asdf/releases/download/${ASDF_VERSION}/${ASDF_BINARY}"
    tar -xzf "$ASDF_BINARY"
    mkdir -p "$HOME/.local/bin"
    mv asdf "$HOME/.local/bin/"
    rm "$ASDF_BINARY"
    log "asdf ${ASDF_VERSION} installed to ~/.local/bin/asdf"
else
    log "asdf is already installed"
fi

# Install neovim (apt version is outdated)
log "Installing neovim..."
if [ ! -d "$HOME/.local/share/nvim" ]; then
    NVIM_VERSION=$(curl -s https://api.github.com/repos/neovim/neovim/releases/latest | grep '"tag_name"' | sed -E 's/.*"([^"]+)".*/\1/')
    NVIM_TARBALL="nvim-linux-x86_64.tar.gz"
    curl -LO "https://github.com/neovim/neovim/releases/download/${NVIM_VERSION}/${NVIM_TARBALL}"
    mkdir -p "$HOME/.local/share"
    tar -xzf "$NVIM_TARBALL" -C "$HOME/.local/share"
    mv "$HOME/.local/share/nvim-linux-x86_64" "$HOME/.local/share/nvim"
    rm "$NVIM_TARBALL"
    mkdir -p "$HOME/.local/bin"
    ln -sf "$HOME/.local/share/nvim/bin/nvim" "$HOME/.local/bin/nvim"
    log "neovim ${NVIM_VERSION} installed to ~/.local/share/nvim"
else
    log "neovim is already installed"
fi

# Install opencode (not available in apt)
log "Installing opencode..."
if ! command -v opencode &>/dev/null; then
    curl -fsSL https://opencode.ai/install | bash
else
    log "opencode is already installed"
fi

# Install rustup (for Ruby YJIT support)
log "Installing rustup..."
if command -v rustc &>/dev/null; then
    log "Rust toolchain already installed"
else
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
fi
