This is what allows me to setup a new machine to my liking as quickly as possible.

| Type     | Program           |
| ---      | ---               |
| Editor   | Neovim(,IDEA,Zed) |
| Shell    | Nushell           |
| Terminal | Wezterm           |
| Prompt   | Starship          |

The installer also links `codex/config.toml` to `~/.codex/config.toml`. MCP server
definitions are kept alongside the Pi and OpenCode templates. Add MCP credentials
to the local Nushell `device-env.nu`; Codex reads their environment variable names
from `env_http_headers`, while the installer resolves the same values into Pi and
OpenCode's generated configs.

Supported operating systems: Ubuntu, Macos
