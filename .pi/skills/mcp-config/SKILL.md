---
name: mcp-config
description: Add, update, or remove an MCP server from the Pi and OpenCode dotfile templates. Use when given an MCP definition, especially the Codex TOML format.
---

# MCP Configuration

Use this skill for MCP changes in this dotfiles repository. Do not rediscover the install workflow unless this skill is out of date.

## Source Format

MCP definitions commonly arrive in Codex TOML form:

```toml
[mcp_servers.example]
url = "https://example.com/mcp"

[mcp_servers.example.http_headers]
X-Api-Key = "<secret>"
```

Treat header values as secrets. Never add them to tracked files, commit them, or repeat them in output.

## Target Files

Update both tracked MCP templates for additions, edits, and removals:

- `opencode/opencode.json` — OpenCode's `mcp.servers` map.
- `pi/mcp.json` — source template for Pi's session MCP picker.

Translate a remote Streamable HTTP server into the clients' respective formats:

```jsonc
// opencode/opencode.json: mcp.servers
"example": {
  "type": "remote",
  "url": "https://example.com/mcp",
  "oauth": false,
  "disabled": true,
  "headers": {
    "X-Api-Key": "REPLACE_LOCALLY_EXAMPLE_API_KEY"
  }
}
```

```jsonc
// pi/mcp.json: mcpServers
"example": {
  "url": "https://example.com/mcp",
  "headers": {
    "X-Api-Key": "REPLACE_LOCALLY_EXAMPLE_API_KEY"
  }
}
```

Pi's template is consumed by `scripts/install.sh`, which writes the resolved definitions to `~/.pi/agent/mcps.json`. The custom `pi/extensions/mcps.ts` extension registers selected servers only when the user chooses them with `/mcps`; the selection lasts only for the current session. Do not add `enabled`, `lifecycle`, or legacy `transport` fields to the Pi template. Do not put server definitions in the built-in `~/.pi/agent/mcp.json`: the installer intentionally keeps that file empty to avoid conflicts with extension-registered servers.

Keep OpenCode servers disabled by default. The Pi picker starts with all servers off for each session. Set `oauth` to `false` in the OpenCode config for header/API-key authenticated servers. OAuth-only servers need their client-specific auth configuration instead of a secret placeholder.

For stdio servers, preserve each client's current schema. OpenCode uses `type: "local"` and a `command` array; Pi uses `command` and `args`.

## Secret Placeholders

The installer generates client configs from templates and includes a server only when every placeholder in that server resolves to a non-empty value.

For every new secret placeholder:

1. Choose an environment variable such as `MCP_EXAMPLE_API_KEY`.
2. Use a matching tracked placeholder, such as `REPLACE_LOCALLY_EXAMPLE_API_KEY`, in both templates.
3. Add the empty environment variable to both files:
   - `nushell/scripts/example-macos-device-env.nu`
   - `nushell/scripts/example-ubuntu-device-env.nu`
4. Add the supplied value only to the ignored local `nushell/scripts/device-env.nu` when the user asks to configure the current machine.
5. Update `scripts/install.sh` so `write_mcp_config` reads the environment variable and maps the placeholder. This function has explicit declarations, lookups, environment forwarding, and `placeholder_values`; update all four.

Do not create symlinks for generated MCP configs. `make install` writes:

- `~/.config/opencode/opencode.json` — generated OpenCode config.
- `~/.pi/agent/mcps.json` — resolved Pi definitions for `/mcps`.
- `~/.pi/agent/mcp.json` — overwritten with an empty `mcpServers` map so Pi's built-in MCP loader does not conflict with `/mcps`.

The generated `mcps.json` and OpenCode config can contain resolved secrets and must remain outside the repository. For server removal, remove its entry from both tracked templates and any in-scope generated local config if requested; do not leave orphaned definitions in Pi's `mcps.json`.

## Documentation And Validation

Update `pi/README.md` when its MCP server list or setup notes become inaccurate. Keep the description of `/mcps`, session-only selections, config paths, and OpenCode/Pi behavior aligned with the installer and extension.

Run after changes:

```sh
bash -n scripts/install.sh
jq empty opencode/opencode.json pi/mcp.json
git diff --check
```

Confirm supplied secrets are absent from tracked files. Do not run `make install` unless requested: it is a full workstation bootstrap. Tell the user to run it to regenerate live MCP configs, or perform only equivalent targeted generation if requested.
