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

# Install lazygit
log "Installing lazygit..."
if command -v lazygit &>/dev/null; then
    log "lazygit is already installed"
else
    # Check Ubuntu version (lazygit available in apt from 25.10+)
    UBUNTU_VERSION=$(lsb_release -rs 2>/dev/null || echo "0")
    if [ "$(echo "$UBUNTU_VERSION >= 25.10" | bc)" -eq 1 ]; then
        sudo apt install -y lazygit
    else
        LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": *"v\K[^"]*')
        curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
        tar xf lazygit.tar.gz lazygit
        sudo install lazygit -D -t /usr/local/bin/
        rm -f lazygit.tar.gz lazygit
    fi
fi

# Install glow (markdown renderer) via Charm apt repository
log "Installing glow..."
if command -v glow &>/dev/null; then
    log "glow is already installed"
else
    sudo mkdir -p /etc/apt/keyrings
    curl -fsSL https://repo.charm.sh/apt/gpg.key | sudo gpg --dearmor --yes -o /etc/apt/keyrings/charm.gpg
    echo "deb [signed-by=/etc/apt/keyrings/charm.gpg] https://repo.charm.sh/apt/ * *" | sudo tee /etc/apt/sources.list.d/charm.list
    sudo apt update && sudo apt install -y glow
fi

# Install tailscale
log "Installing tailscale..."
if command -v tailscale &>/dev/null; then
    log "tailscale is already installed"
else
    curl -fsSL https://tailscale.com/install.sh | sh
fi

# Install 1password-cli
log "Installing 1password-cli..."
if command -v op &>/dev/null; then
    log "1password-cli is already installed"
else
    curl -sS https://downloads.1password.com/linux/keys/1password.asc | \
        sudo gpg --dearmor --yes --output /usr/share/keyrings/1password-archive-keyring.gpg && \
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/1password-archive-keyring.gpg] https://downloads.1password.com/linux/debian/$(dpkg --print-architecture) stable main" | \
        sudo tee /etc/apt/sources.list.d/1password.list && \
        sudo mkdir -p /etc/debsig/policies/AC2D62742012EA22/ && \
        curl -sS https://downloads.1password.com/linux/debian/debsig/1password.pol | \
        sudo tee /etc/debsig/policies/AC2D62742012EA22/1password.pol && \
        sudo mkdir -p /usr/share/debsig/keyrings/AC2D62742012EA22 && \
        curl -sS https://downloads.1password.com/linux/keys/1password.asc | \
        sudo gpg --dearmor --yes --output /usr/share/debsig/keyrings/AC2D62742012EA22/debsig.gpg && \
        sudo apt update && sudo apt install 1password-cli
fi

