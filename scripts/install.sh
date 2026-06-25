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

create_bin_symlinks() {
    local source_dir="$1"
    local target_dir="$2"
    local entry

    if [ ! -d "$source_dir" ]; then
        return
    fi

    mkdir -p "$target_dir"

    for entry in "$source_dir"/*; do
        if [ ! -e "$entry" ]; then
            continue
        fi

        if [ -x "$entry" ]; then
            create_symlink "$entry" "$target_dir/$(basename "$entry")"
        fi
    done
}

install_pi_package() {
    local package="$1"
    local package_name="${package#npm:}"
    local package_path="$HOME/.pi/agent/npm/node_modules/$package_name"

    if ! command -v pi &>/dev/null; then
        warn "pi is not installed; skipping package install for $package"
        return
    fi

    if [ -d "$package_path" ]; then
        log "Pi package already installed: $package"
        return
    fi

    log "Installing Pi package: $package"
    pi install "$package"
}

remove_if_symlink() {
    local path="$1"

    if [ -L "$path" ]; then
        log "Removing existing symlink: $path"
        rm "$path"
    fi
}

get_device_env_value() {
    local device_env="$1"
    local env_name="$2"

    if [ ! -f "$device_env" ]; then
        return
    fi

    python3 - "$device_env" "$env_name" <<'PY'
import pathlib
import re
import sys

path = pathlib.Path(sys.argv[1])
name = re.escape(sys.argv[2])
pattern = re.compile(r'^\s*\$env\.' + name + r'\s*=\s*"([^"]*)"', re.MULTILINE)
match = pattern.search(path.read_text())
if match:
    print(match.group(1))
PY
}

write_pi_mcp_config() {
    local device_env="$1"
    local mcp_path="$HOME/.pi/agent/mcp.json"
    local coralogix_prod_key
    local hotstar_eks_key

    remove_if_symlink "$mcp_path"

    coralogix_prod_key="$(get_device_env_value "$device_env" "PI_MCP_CORALOGIX_PROD_BF_VK")"
    hotstar_eks_key="$(get_device_env_value "$device_env" "PI_MCP_HOTSTAR_EKS_BF_VK")"

    if [ -z "$coralogix_prod_key" ] && [ -z "$hotstar_eks_key" ]; then
        log "Skipping Pi MCP config generation; no Pi MCP keys set in $device_env"
        return
    fi

    mkdir -p "$(dirname "$mcp_path")"
    CORALOGIX_PROD_KEY="$coralogix_prod_key" HOTSTAR_EKS_KEY="$hotstar_eks_key" MCP_PATH="$mcp_path" python3 - <<'PY'
import json
import os
import pathlib

servers = {}
url = "https://origin-bifrost-llm-proxy.cmd.hotstar-prod.com/mcp"
entries = [
    ("coralogix_prod", os.environ.get("CORALOGIX_PROD_KEY", "")),
    ("hotstar_eks", os.environ.get("HOTSTAR_EKS_KEY", "")),
]

for name, key in entries:
    if not key:
        continue
    servers[name] = {
        "transport": "streamable-http",
        "url": url,
        "headers": {
            "x-bf-vk": key,
        },
        "lifecycle": "lazy",
    }

path = pathlib.Path(os.environ["MCP_PATH"])
path.write_text(json.dumps({"mcpServers": servers}, indent=2) + "\n")
PY
    log "Wrote Pi MCP config: $mcp_path"
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

    # Initialize rustup
    log "Initializing rustup..."
    if command -v rustc &>/dev/null; then
        log "Rust toolchain already installed"
    else
        RUSTUP_BIN="$(brew --prefix rustup)/bin/rustup"
        if [ -x "$RUSTUP_BIN" ]; then
            "$RUSTUP_BIN" default stable
        else
            error "rustup is installed but the executable was not found"
        fi
    fi
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

# GitHub CLI authentication
log "Setting up GitHub CLI..."
if gh auth status &>/dev/null; then
    log "GitHub CLI already authenticated"
else
    log "Please authenticate with GitHub CLI..."
    gh auth login
fi

# Set up commit signing with SSH key
log "Setting up commit signing..."
if git config --global --get user.signingkey &>/dev/null; then
    log "Commit signing already configured"
else
    log "Configuring commit signing..."
    # Find SSH key (prefer ed25519, fallback to rsa)
    if [ -f "$HOME/.ssh/id_ed25519.pub" ]; then
        SSH_KEY="$HOME/.ssh/id_ed25519.pub"
    elif [ -f "$HOME/.ssh/id_rsa.pub" ]; then
        SSH_KEY="$HOME/.ssh/id_rsa.pub"
    else
        warn "No SSH key found. Please generate one and re-run"
        SSH_KEY=""
    fi

    if [ -n "$SSH_KEY" ]; then
        git config --global gpg.format ssh
        git config --global user.signingkey "$SSH_KEY"
        git config --global commit.gpgsign true
        log "Commit signing configured with $SSH_KEY"
    fi
fi

# Create symlinks
log "Creating symlinks..."
create_bin_symlinks "$DOTFILES_DIR/bin" "$HOME/.local/bin"
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
create_symlink "$DOTFILES_DIR/claude/skills" "$HOME/.claude/skills"
create_symlink "$DOTFILES_DIR/claude/settings.json" "$HOME/.claude/settings.json"
create_symlink "$DOTFILES_DIR/claude/skills" "$HOME/.config/opencode/skills"
create_symlink "$DOTFILES_DIR/claude/statusline.sh" "$HOME/.claude/statusline.sh"
create_symlink "$DOTFILES_DIR/bat/bat.conf" "$HOME/.config/bat/config"
create_symlink "$DOTFILES_DIR/lazygit/config.yml" "$HOME/Library/Application Support/lazygit/config.yml"

# Nushell config path differs by OS
if [ "$OS" = "macos" ]; then
    NUSHELL_CONFIG_DIR="$HOME/Library/Application Support/nushell"
else
    NUSHELL_CONFIG_DIR="$HOME/.config/nushell"
fi

# Copy device-env template if needed
log "Setting up device-env.nu..."
DEVICE_ENV="$NUSHELL_CONFIG_DIR/scripts/device-env.nu"
if [ ! -f "$DEVICE_ENV" ]; then
    cp "$DOTFILES_DIR/nushell/scripts/example-${OS}-device-env.nu" "$DEVICE_ENV"
    log "Created device-env.nu from template. Please review and customize: $DEVICE_ENV"
else
    log "device-env.nu already exists, skipping"
fi

log "Setting up Pi config..."
mkdir -p "$HOME/.pi/agent"
create_symlink "$DOTFILES_DIR/pi/settings.json" "$HOME/.pi/agent/settings.json"
remove_if_symlink "$HOME/.pi/agent/mcp.json"
write_pi_mcp_config "$DEVICE_ENV"
create_symlink "$DOTFILES_DIR/pi/extensions" "$HOME/.pi/agent/extensions"
install_pi_package "npm:pi-web-access"
install_pi_package "npm:pi-mcp-extension"

# Initialize starship
"$DOTFILES_DIR/scripts/init-starship.sh"

# Initialize asdf completions
"$DOTFILES_DIR/scripts/init-asdf.sh"

# Set nushell as default shell
log "Setting nushell as default shell..."
NU_PATH=$(which nu)
if ! grep -q "$NU_PATH" /etc/shells; then
    log "Adding $NU_PATH to /etc/shells"
    echo "$NU_PATH" | sudo tee -a /etc/shells
fi
CURRENT_SHELL=$(dscl . -read /Users/"$USER" UserShell 2>/dev/null | awk '{print $2}')
if [ "$CURRENT_SHELL" = "$NU_PATH" ]; then
    log "nushell is already the default shell"
else
    chsh -s "$NU_PATH"
fi

# Set nvim as default editor (already configured in env.nu, but also set system-wide)
log "Setting nvim as default editor..."
if [ "$OS" = "ubuntu" ]; then
    sudo update-alternatives --set editor "$(which nvim)" 2>/dev/null || true
fi

log "Installation complete!"

