import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { Key, matchesKey } from "@earendil-works/pi-tui";
import { readFile } from "node:fs/promises";
import { homedir } from "node:os";
import { join } from "node:path";

interface McpConfig {
	mcpServers?: Record<string, Record<string, unknown>>;
}

export default function mcpsExtension(pi: ExtensionAPI) {
	const configPath = join(homedir(), ".pi", "agent", "mcps.json");
	const enabled = new Set<string>();

	pi.registerCommand("mcps", {
		description: "Select MCP servers for this session",
		handler: async (_args, ctx) => {
			if (ctx.mode !== "tui") {
				ctx.ui.notify("/mcps requires TUI mode", "error");
				return;
			}

			let servers: McpConfig["mcpServers"];
			try {
				const config = JSON.parse(await readFile(configPath, "utf8")) as McpConfig;
				servers = config.mcpServers ?? {};
			} catch (error) {
				ctx.ui.notify(`Could not read ${configPath}: ${String(error)}`, "error");
				return;
			}

			const names = Object.keys(servers).sort();
			if (names.length === 0) {
				ctx.ui.notify("No MCP servers are configured", "info");
				return;
			}

			const pending = new Set(enabled);
			const result = await ctx.ui.custom<Set<string> | undefined>((tui, theme, _keybindings, done) => {
				let cursor = 0;
				const component = {
					render(width: number) {
						const lines = [
							theme.fg("accent", theme.bold("MCP servers for this session")),
							theme.fg("muted", "  Space: toggle · Enter: apply · Esc: cancel"),
							"",
						];
						for (const [index, name] of names.entries()) {
							const marker = index === cursor ? theme.fg("accent", ">") : " ";
							const checkbox = pending.has(name) ? theme.fg("success", "[x]") : "[ ]";
							lines.push(`${marker} ${checkbox} ${name}`.slice(0, width));
						}
						return lines;
					},
					invalidate() {},
					handleInput(data: string) {
						if (matchesKey(data, Key.up)) cursor = (cursor + names.length - 1) % names.length;
						else if (matchesKey(data, Key.down)) cursor = (cursor + 1) % names.length;
						else if (matchesKey(data, Key.space)) {
							const name = names[cursor];
							if (name && pending.has(name)) pending.delete(name);
							else if (name) pending.add(name);
						} else if (matchesKey(data, Key.enter)) done(new Set(pending));
						else if (matchesKey(data, Key.escape)) done(undefined);
					tui.requestRender();
					},
				};
				return component;
			});

			if (!result) return;

			for (const name of names) {
				if (enabled.has(name) && !result.has(name)) {
					pi.unregisterMcpServer(name);
					enabled.delete(name);
				} else if (!enabled.has(name) && result.has(name)) {
					const { enabled: _configuredEnabled, ...serverConfig } = servers[name] ?? {};
					pi.registerMcpServer(name, serverConfig as Parameters<typeof pi.registerMcpServer>[1]);
					enabled.add(name);
				}
			}

			ctx.ui.notify(`Updated MCP servers for this session (${result.size} selected)`, "info");
		},
	});
}
