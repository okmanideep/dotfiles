# Device-specific environment for Ubuntu
# Customize this file for your machine

# Add paths (local bins, go, android sdk, etc.)
let paths = [
    ($env.HOME | path join ".local/bin"),
    ($env.HOME | path join ".local/share/go/bin"),
    ($env.HOME | path join ".opencode/bin"),
]

let paths_to_add = $paths | where { |p| $p not-in $env.PATH }
$env.PATH = ($env.PATH | split row (char esep) | prepend $paths_to_add)

# Device-specific environment variables
# $env.NOTES_DIR = ($env.HOME | path join "notes")

# Device-specific commands
# export def --env my-project [] {
#     cd ~/code/my-project
# }
