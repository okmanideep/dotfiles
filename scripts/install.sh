#!/bin/bash
set -e

DOTFILES_DIR="$(cd "$(dirname "$0")/.." && pwd)"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log() {
    echo -e "${GREEN}==>${NC} $1"
}

warn() {
    echo -e "${YELLOW}WARNING:${NC} $1"
}

error() {
    echo -e "${RED}ERROR:${NC} $1" >&2
    exit 1
}

# Detect OS
detect_os() {
    case "$(uname -s)" in
        Darwin)
            echo "macos"
            ;;
        Linux)
            if command -v apt &>/dev/null; then
                echo "ubuntu"
            else
                error "Unsupported Linux distribution. Only Ubuntu (apt-based) is supported."
            fi
            ;;
        *)
            error "Unsupported operating system: $(uname -s)"
            ;;
    esac
}

# Create symlink with backup
create_symlink() {
    local src="$1"
    local dest="$2"

    if [ -L "$dest" ]; then
        log "Removing existing symlink: $dest"
        rm "$dest"
    elif [ -e "$dest" ]; then
        local backup="$dest.backup.$(date +%s)"
        warn "Backing up existing file: $dest -> $backup"
        mv "$dest" "$backup"
    fi

    mkdir -p "$(dirname "$dest")"
    ln -s "$src" "$dest"
    log "Created symlink: $dest -> $src"
}

OS=$(detect_os)
log "Detected OS: $OS"

# Set up git config
log "Setting up git config..."
git config --global user.name "Manideep Polireddi"
git config --global user.email "okmanideep@users.noreply.github.com"

# Install packages
log "Installing packages..."
if [ "$OS" = "macos" ]; then
    brew bundle --file="$DOTFILES_DIR/Brewfile"
else
    sudo apt update
    xargs -a "$DOTFILES_DIR/apt-packages.txt" sudo apt install -y

    # Install starship (not available in apt)
    log "Installing starship..."
    if ! command -v starship &>/dev/null; then
        curl -sS https://starship.rs/install.sh | sh -s -- -y
    else
        log "starship is already installed"
    fi

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
fi

# Create symlinks
log "Creating symlinks..."
create_symlink "$DOTFILES_DIR/nvim" "$HOME/.config/nvim"

# Nushell config path differs by OS
if [ "$OS" = "macos" ]; then
    create_symlink "$DOTFILES_DIR/nushell" "$HOME/Library/Application Support/nushell"
else
    create_symlink "$DOTFILES_DIR/nushell" "$HOME/.config/nushell"
fi

create_symlink "$DOTFILES_DIR/starship/starship.toml" "$HOME/.config/starship.toml"
create_symlink "$DOTFILES_DIR/wezterm" "$HOME/.config/wezterm"
create_symlink "$DOTFILES_DIR/opencode/opencode.json" "$HOME/.config/opencode/opencode.json"

# Initialize starship
log "Initializing starship..."
mkdir -p ~/.cache/starship
starship init nu > ~/.cache/starship/init.nu

# Initialize asdf completions
log "Initializing asdf completions..."
mkdir -p ~/.asdf/completions
asdf completion nushell > ~/.asdf/completions/nushell.nu

# Copy device-env template if needed
log "Setting up device-env.nu..."
if [ "$OS" = "macos" ]; then
    NUSHELL_CONFIG_DIR="$HOME/Library/Application Support/nushell"
else
    NUSHELL_CONFIG_DIR="$HOME/.config/nushell"
fi
DEVICE_ENV="$NUSHELL_CONFIG_DIR/scripts/device-env.nu"
if [ ! -f "$DEVICE_ENV" ]; then
    cp "$DOTFILES_DIR/nushell/scripts/example-${OS}-device-env.nu" "$DEVICE_ENV"
    log "Created device-env.nu from template. Please review and customize: $DEVICE_ENV"
else
    log "device-env.nu already exists, skipping"
fi

# Set nushell as default shell
log "Setting nushell as default shell..."
NU_PATH=$(which nu)
if ! grep -q "$NU_PATH" /etc/shells; then
    log "Adding $NU_PATH to /etc/shells"
    echo "$NU_PATH" | sudo tee -a /etc/shells
fi
chsh -s "$NU_PATH"

# Set nvim as default editor (already configured in env.nu, but also set system-wide)
log "Setting nvim as default editor..."
if [ "$OS" = "ubuntu" ]; then
    sudo update-alternatives --set editor "$(which nvim)" 2>/dev/null || true
fi

log "Installation complete!"

