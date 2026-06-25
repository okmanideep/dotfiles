# Pi

Dotfile-managed Pi config lives here and is symlinked into `~/.pi/agent/` by `scripts/install.sh`.

## Files
- `settings.json` — Pi defaults + installed packages
- `mcp.json` — MCP server config
- `extensions/` — custom Pi extensions

## Installed packages
- `npm:pi-web-access`
- `npm:pi-mcp-extension`

## MCP setup
Configured MCP servers are **lazy** by default, so they stay off until you enable them inside Pi.

### Start inside Pi
- `/mcp` — show MCP status
- `/mcp:start slack`
- `/mcp:start hotstar`

### Stop inside Pi
- `/mcp:stop slack`
- `/mcp:stop hotstar`

## MCP servers
- `slack` → `https://mcp.slack.com/mcp`
- `hotstar` → `https://origin-bifrost-llm-proxy.cmd.hotstar-prod.com/mcp`

## Notes
- Slack MCP needs Slack auth/app setup separately.
- Do **not** commit `~/.pi/agent/auth.json` or sessions.
