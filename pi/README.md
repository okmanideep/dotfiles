# Pi

Dotfile-managed Pi config lives here and is symlinked into `~/.pi/agent/` by `scripts/install.sh`.

## Files
- `settings.json` — Pi defaults + installed packages
- `mcp.json` — MCP server config
- `extensions/` — global Pi extensions, including the idle sound notification
- Shared skills live in `claude/skills/` and are symlinked to `~/.pi/agent/skills/`.

## Installed packages
- `npm:pi-web-access`
- `npm:pi-mcp-extension`

## MCP setup
Configured MCP servers are **lazy** by default, so they stay off until you enable them inside Pi.

### Toggle inside Pi
- `/mcps` — interactive OpenCode-style picker; press Space to turn a server on/off.

### Start inside Pi
- `/mcp` — show MCP status
- `/mcp:start launchdarkly`
- `/mcp:start coralogix_nonprod`
- `/mcp:start service_catalog`
- `/mcp:start chrome-devtools`

### Stop inside Pi
- `/mcp:stop launchdarkly`
- `/mcp:stop coralogix_nonprod`
- `/mcp:stop service_catalog`
- `/mcp:stop chrome-devtools`

## MCP servers
- `launchdarkly` → `https://mcp.launchdarkly.com/mcp/launchdarkly`
- `coralogix_nonprod` → `https://origin-bifrost-llm-proxy.cmd.hotstar-prod.com/mcp`
- `service_catalog` → `https://origin-bifrost-llm-proxy.cmd.hotstar-prod.com/mcp`
- `chrome-devtools` → `npx -y chrome-devtools-mcp@latest`

## Notes
- LaunchDarkly hosted MCP uses OAuth in the client after you start/connect the server.
- Chrome DevTools MCP uses the official `chrome-devtools-mcp` package.

## Slack lookup

Use `/skill:lookup-slack` to search, read, or analyze Slack through the authenticated Codex CLI and its Slack skill. The helper uses Codex's configured default model and is read-only.
- Do **not** commit `~/.pi/agent/auth.json` or sessions.
