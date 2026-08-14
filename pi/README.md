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
- `/mcp:start launchdarkly`
- `/mcp:start slack`
- `/mcp:start coralogix_nonprod`
- `/mcp:start service_catalog`
- `/mcp:start chrome-devtools`

### Stop inside Pi
- `/mcp:stop launchdarkly`
- `/mcp:stop slack`
- `/mcp:stop coralogix_nonprod`
- `/mcp:stop service_catalog`
- `/mcp:stop chrome-devtools`

## MCP servers
- `launchdarkly` → `https://mcp.launchdarkly.com/mcp/launchdarkly`
- `slack` → `https://mcp.slack.com/mcp`
- `coralogix_nonprod` → `https://origin-bifrost-llm-proxy.cmd.hotstar-prod.com/mcp`
- `service_catalog` → `https://origin-bifrost-llm-proxy.cmd.hotstar-prod.com/mcp`
- `chrome-devtools` → `npx -y chrome-devtools-mcp@latest`

## Notes
- LaunchDarkly hosted MCP uses OAuth in the client after you start/connect the server.
- Slack MCP needs Slack auth/app setup separately.
- Chrome DevTools MCP uses the official `chrome-devtools-mcp` package.
- Do **not** commit `~/.pi/agent/auth.json` or sessions.
