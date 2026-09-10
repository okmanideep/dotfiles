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

Update both tracked MCP templates:

- `opencode/opencode.json`
- `pi/mcp.json`

For a remote Streamable HTTP server, translate the TOML server name and URL as follows:

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
  "transport": "streamable-http",
  "url": "https://example.com/mcp",
  "headers": {
    "X-Api-Key": "REPLACE_LOCALLY_EXAMPLE_API_KEY"
  },
  "lifecycle": "lazy"
}
```

Keep OpenCode remote servers disabled by default and Pi servers lazy, matching the existing configuration. Set `oauth` to `false` only for header/API-key authenticated servers. OAuth-only servers need their client-specific auth configuration instead of a secret placeholder.

For stdio servers, preserve each client’s existing local/stdio schema rather than using the remote examples above.

## Secret Placeholders

The installer generates client configs from templates and only includes a server when every placeholder in that server resolves to a non-empty value.

For every new secret placeholder:

1. Choose an environment variable such as `MCP_EXAMPLE_API_KEY`.
2. Use a matching tracked placeholder, such as `REPLACE_LOCALLY_EXAMPLE_API_KEY`, in both templates.
3. Add the empty environment variable to both files:
   - `nushell/scripts/example-macos-device-env.nu`
   - `nushell/scripts/example-ubuntu-device-env.nu`
4. Add the supplied value only to the ignored local `nushell/scripts/device-env.nu` when the user asks to configure the current machine.
5. Update `scripts/install.sh` so `write_mcp_config` reads the environment variable and maps the placeholder. This function currently has explicit declarations, lookups, environment forwarding, and `placeholder_values` entries; update all four.

Do not create a symlink for either MCP config. `make install` writes generated files to:

- `~/.config/opencode/opencode.json`
- `~/.pi/agent/mcp.json`

The generated files intentionally contain resolved secrets and must remain outside the repository.

## Documentation And Validation

Update `pi/README.md` when its MCP server list or setup notes become inaccurate.

Run after changes:

```sh
bash -n scripts/install.sh
jq empty opencode/opencode.json pi/mcp.json
git diff --check
```

Confirm the supplied secret is absent from tracked files. Do not run `make install` unless requested: it is a full workstation bootstrap. Tell the user to run it to regenerate the live MCP configs, or perform only the equivalent targeted generation if requested.
