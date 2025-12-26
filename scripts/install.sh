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

    # Run custom Linux installations (asdf, neovim, opencode)
    "$DOTFILES_DIR/scripts/custom-install-linux.sh"
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
"$DOTFILES_DIR/scripts/init-starship.sh"

# Initialize asdf completions
"$DOTFILES_DIR/scripts/init-asdf.sh"

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

