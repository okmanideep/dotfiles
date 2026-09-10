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
    local env_value="${!env_name:-}"

    if [ -n "$env_value" ]; then
        printf '%s\n' "$env_value"
        return
    fi

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

write_mcp_config() {
    local device_env="$1"
    local mcp_template="$2"
    local mcp_path="$3"
    local client_name="$4"
    local coralogix_nonprod_key
    local coralogix_prod_key
    local hotstar_eks_key
    local service_catalog_key
    local slack_key

    remove_if_symlink "$mcp_path"

    coralogix_nonprod_key="$(get_device_env_value "$device_env" "MCP_CORALOGIX_NONPROD_BF_VK")"
    coralogix_prod_key="$(get_device_env_value "$device_env" "MCP_CORALOGIX_PROD_BF_VK")"
    hotstar_eks_key="$(get_device_env_value "$device_env" "MCP_HOTSTAR_EKS_BF_VK")"
    service_catalog_key="$(get_device_env_value "$device_env" "MCP_SERVICE_CATALOG_BF_VK")"
    slack_key="$(get_device_env_value "$device_env" "MCP_SLACK_BF_VK")"

    mkdir -p "$(dirname "$mcp_path")"
    MCP_TEMPLATE="$mcp_template" CORALOGIX_NONPROD_KEY="$coralogix_nonprod_key" CORALOGIX_PROD_KEY="$coralogix_prod_key" HOTSTAR_EKS_KEY="$hotstar_eks_key" SERVICE_CATALOG_KEY="$service_catalog_key" SLACK_KEY="$slack_key" MCP_PATH="$mcp_path" python3 - <<'PY'
import json
import os
import pathlib

placeholder_values = {
    "REPLACE_LOCALLY_CORALOGIX_NONPROD_BF_VK": os.environ.get("CORALOGIX_NONPROD_KEY", ""),
    "REPLACE_LOCALLY_CORALOGIX_PROD_BF_VK": os.environ.get("CORALOGIX_PROD_KEY", ""),
    "REPLACE_LOCALLY_HOTSTAR_EKS_BF_VK": os.environ.get("HOTSTAR_EKS_KEY", ""),
    "REPLACE_LOCALLY_SERVICE_CATALOG_BF_VK": os.environ.get("SERVICE_CATALOG_KEY", ""),
    "REPLACE_LOCALLY_SLACK_BF_VK": os.environ.get("SLACK_KEY", ""),
}

with pathlib.Path(os.environ["MCP_TEMPLATE"]).open() as f:
    config = json.load(f)

if "mcpServers" in config:
    servers = config["mcpServers"]
else:
    servers = config.get("mcp", {}).get("servers", {})
filtered_servers = {}

for name, server in servers.items():
    raw = json.dumps(server)
    placeholders = [token for token in placeholder_values if token in raw]

    if placeholders and any(not placeholder_values[token] for token in placeholders):
        continue

    resolved = raw
    for token, value in placeholder_values.items():
        resolved = resolved.replace(token, value)

    filtered_servers[name] = json.loads(resolved)

path = pathlib.Path(os.environ["MCP_PATH"])
if "mcpServers" in config:
    config["mcpServers"] = filtered_servers
else:
    config.setdefault("mcp", {})["servers"] = filtered_servers

path.write_text(json.dumps(config, indent=2) + "\n")
PY
    log "Wrote $client_name MCP config from template: $mcp_path"
}

setup_cloudflare_r2_aws_profile() {
    local device_env="$1"
    local cloudflare_api_token
    local access_key_id
    local secret_access_key
    local verify_response

    cloudflare_api_token="$(get_device_env_value "$device_env" "CLOUDFLARE_API_TOKEN")"

    if [ -z "$cloudflare_api_token" ]; then
        log "CLOUDFLARE_API_TOKEN not set; skipping AWS CLI R2 profile setup"
        return
    fi

    if ! command -v aws &>/dev/null; then
        warn "aws CLI not found; skipping AWS CLI R2 profile setup"
        return
    fi

    if ! command -v curl &>/dev/null; then
        warn "curl not found; skipping AWS CLI R2 profile setup"
        return
    fi

    log "Setting up AWS CLI R2 profile..."

    if ! verify_response="$(curl -fsS https://api.cloudflare.com/client/v4/user/tokens/verify -H "Authorization: Bearer $cloudflare_api_token")"; then
        warn "Unable to verify CLOUDFLARE_API_TOKEN; skipping AWS CLI R2 profile setup"
        return
    fi

    access_key_id="$(VERIFY_RESPONSE="$verify_response" python3 - <<'PY'
import json
import os

payload = json.loads(os.environ["VERIFY_RESPONSE"])
result = payload.get("result") or {}
print(result.get("id", ""))
PY
)"

    if [ -z "$access_key_id" ]; then
        warn "Could not determine Cloudflare token ID; skipping AWS CLI R2 profile setup"
        return
    fi

    secret_access_key="$(CLOUDFLARE_API_TOKEN="$cloudflare_api_token" python3 - <<'PY'
import hashlib
import os

print(hashlib.sha256(os.environ["CLOUDFLARE_API_TOKEN"].encode()).hexdigest())
PY
)"

    aws configure set aws_access_key_id "$access_key_id" --profile r2
    aws configure set aws_secret_access_key "$secret_access_key" --profile r2
    aws configure set region auto --profile r2
    aws configure set output json --profile r2

    log "Configured AWS CLI profile: r2"
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

write_mcp_config "$DEVICE_ENV" "$DOTFILES_DIR/opencode/opencode.json" "$HOME/.config/opencode/opencode.json" "OpenCode"
create_symlink "$DOTFILES_DIR/opencode/plugins/idle-sound.ts" "$HOME/.config/opencode/plugins/idle-sound.ts"

log "Setting up Pi config..."
mkdir -p "$HOME/.pi/agent"
create_symlink "$DOTFILES_DIR/pi/settings.json" "$HOME/.pi/agent/settings.json"
create_symlink "$DOTFILES_DIR/pi/extensions" "$HOME/.pi/agent/extensions"
write_mcp_config "$DEVICE_ENV" "$DOTFILES_DIR/pi/mcp.json" "$HOME/.pi/agent/mcp.json" "Pi"
setup_cloudflare_r2_aws_profile "$DEVICE_ENV"
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
