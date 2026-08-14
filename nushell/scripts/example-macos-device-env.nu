# Device-specific environment for macOS
# Customize this file for your machine

# Add paths (homebrew, local bins, etc.)
let paths = [
    "/opt/homebrew/bin",
    ($env.HOME | path join ".local/bin"),
    ($env.HOME | path join ".opencode/bin"),
]

let paths_to_add = $paths | where { |p| $p not-in $env.PATH }
$env.PATH = ($env.PATH | split row (char esep) | prepend $paths_to_add)

# Device-specific environment variables
# $env.NOTES_DIR = ($env.HOME | path join "notes")

# Pi MCP secrets consumed by scripts/install.sh to generate ~/.pi/agent/mcp.json
$env.PI_MCP_CORALOGIX_NONPROD_BF_VK = ""
$env.PI_MCP_HOTSTAR_EKS_BF_VK = ""
$env.PI_MCP_SERVICE_CATALOG_BF_VK = ""

# Device-specific commands
# export def --env my-project [] {
#     cd ~/code/my-project
# }
