This is what allows me to setup a new machine to my liking as quickly as possible.

| Type     | Program           |
| ---      | ---               |
| Editor   | Neovim(,IDEA,Zed) |
| Shell    | Nushell           |
| Terminal | Wezterm           |
| Prompt   | Starship          |

The installer merges shared Codex settings from `codex/codex.toml` into the local,
writable `~/.codex/config.toml`, preserving machine-specific settings such as
project trust and local paths. It uses `uv` to run the TOML merge helper in
`codex/merge_config.py`; `scripts/init-mise.sh` installs the pinned uv version
through mise. MCP server definitions are kept alongside the Pi and OpenCode
templates. Add MCP credentials to the local Nushell `device-env.nu`; Codex reads
their environment variable names from `env_http_headers`, while the installer
resolves the same values into Pi and OpenCode's generated configs.

Supported operating systems: Ubuntu, Macos
