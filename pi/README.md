# Pi

Dotfile-managed Pi config lives here and is symlinked into `~/.pi/agent/` by `scripts/install.sh`.

## Files
- `settings.json` — Pi defaults + installed packages
- `web-search.json` — Pi Web Access provider and credential configuration
- `mcp.json` — empty built-in config; MCP connections are managed by the session picker
- `mcps.json` — generated server definitions, with secrets from local `device-env.nu`
- `extensions/` — global Pi extensions, including the idle sound notification
- `prompts/` — global prompt templates, including `/review`.
- Shared skills live in `agents/skills/` and are symlinked to `~/.pi/agent/skills/`, including LaunchDarkly, Jira, and Confluence workflows.
- The MCP configuration skill is project-local at `.pi/skills/mcp-config/` and is not installed globally.

## Installed packages
- `npm:pi-web-access`

## MCP setup
`scripts/install.sh` generates `~/.pi/agent/mcps.json` from this template, substituting MCP keys from the local `device-env.nu`. Servers with missing required keys are omitted. The built-in `mcp.json` is kept empty so the custom extension can register selected servers without conflicts. `/mcps` opens a session-only checklist: use Up/Down to move, Space to toggle, Enter to apply, or Esc to cancel. Selected servers connect for the current session; nothing is written to global configuration. `/mcp` remains available for Pi's built-in MCP status and OAuth actions.

## MCP servers
- `launchdarkly` → `https://mcp.launchdarkly.com/mcp/launchdarkly` (OAuth; sign in via `/mcp`)
- `coralogix_nonprod` → Bifrost MCP endpoint
- `coralogix_prod` → Bifrost MCP endpoint
- `hotstar_eks` → Bifrost MCP endpoint
- `service_catalog` → Bifrost MCP endpoint
- `chrome-devtools` → `npx -y chrome-devtools-mcp@latest`

## Web search

Pi Web Access uses Parallel as its default search provider. The API key is read
from `$PARALLEL_API_KEY` at runtime and is not stored in this repository.

## Slack lookup

Use `/skill:lookup-slack` to search, read, or analyze Slack through the authenticated Codex CLI and its Slack skill. The helper uses Codex's configured default model and is read-only.

## Google Drive lookup

Use `/skill:lookup-google-drive` to search, read, or analyze Google Drive files, including Google Sheets, through the authenticated Codex CLI and its Google Drive skill. The helper uses Codex's configured default model and is read-only.
- Do **not** commit `~/.pi/agent/auth.json` or sessions.
