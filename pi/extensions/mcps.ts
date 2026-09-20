/**
 * Interactive MCP server toggle for pi-mcp-extension.
 *
 * pi-mcp-extension deliberately exposes start/stop as separate commands. This
 * provides an OpenCode-style picker that sends the appropriate command.
 */

import type { ExtensionAPI, ExtensionCommandContext } from "@earendil-works/pi-coding-agent";
import { getSettingsListTheme } from "@earendil-works/pi-coding-agent";
import { readFile } from "node:fs/promises";
import { homedir } from "node:os";
import { join } from "node:path";
import { Container, type SettingItem, SettingsList, Text } from "@earendil-works/pi-tui";

interface McpConfig {
	settings?: { toolPrefix?: string };
	mcpServers?: Record<string, unknown>;
}

interface McpServer {
	name: string;
	active: boolean;
}

function sanitizeName(name: string): string {
	return name.replace(/[^a-zA-Z0-9_]/g, "_");
}

async function readConfig(path: string): Promise<McpConfig> {
	try {
		return JSON.parse(await readFile(path, "utf8")) as McpConfig;
	} catch (error) {
		if ((error as NodeJS.ErrnoException).code === "ENOENT") return {};
		throw error;
	}
}

async function getServers(ctx: ExtensionCommandContext, activeTools: string[]): Promise<McpServer[]> {
	const globalConfig = await readConfig(join(homedir(), ".pi", "agent", "mcp.json"));
	const projectConfig = ctx.isProjectTrusted()
		? await readConfig(join(ctx.cwd, ".pi", "mcp.json"))
		: {};
	const configs = {
		...(globalConfig.mcpServers ?? {}),
		...(projectConfig.mcpServers ?? {}),
	};
	const toolPrefix = projectConfig.settings?.toolPrefix ?? globalConfig.settings?.toolPrefix ?? "mcp";
	const activeToolNames = new Set(activeTools);

	return Object.keys(configs)
		.sort((left, right) => left.localeCompare(right))
		.map((name) => {
			const serverToolPrefix = `${sanitizeName(toolPrefix)}_${sanitizeName(name)}_`;
			return {
				name,
				active: [...activeToolNames].some((toolName) => toolName.startsWith(serverToolPrefix)), 
			};
		});
}

export default function mcpToggleExtension(pi: ExtensionAPI) {
	pi.registerCommand("mcps", {
		description: "Interactively start or stop MCP servers",
		handler: async (_args, ctx) => {
			if (ctx.mode !== "tui") {
				ctx.ui.notify("/mcps requires TUI mode; use /mcp:start or /mcp:stop", "error");
				return;
			}

			let servers: McpServer[];
			try {
				servers = await getServers(ctx, pi.getActiveTools());
			} catch (error) {
				ctx.ui.notify(`Could not read MCP config: ${String(error)}`, "error");
				return;
			}

			if (servers.length === 0) {
				ctx.ui.notify("No MCP servers are configured", "info");
				return;
			}

			const changes = new Map<string, string>();
			await ctx.ui.custom((_tui, theme, keybindings, done) => {
				const items: SettingItem[] = servers.map((server) => ({
					id: server.name,
					label: server.name,
					currentValue: server.active ? "on" : "off",
					values: ["on", "off"],
				}));
				const container = new Container();
				container.addChild(new Text(theme.fg("accent", theme.bold("MCP Servers")), 1, 1));

				let settings: SettingsList;
				settings = new SettingsList(
					items,
					Math.min(items.length + 2, 15),
					getSettingsListTheme(),
					(name, value) => {
						changes.set(name, value);
						settings.updateValue(name, value);
					},
					() => done(undefined),
					{ enableSearch: true },
				);
				container.addChild(settings);
				container.addChild(new Text(theme.fg("dim", "Space toggles • enter applies • esc cancels"), 1, 0));

				return {
					render: (width) => container.render(width),
					invalidate: () => container.invalidate(),
					handleInput: (data) => {
						if (keybindings.matches(data, "tui.select.confirm")) {
							done(undefined);
							return;
						}
						if (keybindings.matches(data, "tui.select.cancel")) {
							changes.clear();
							done(undefined);
							return;
						}
						settings.handleInput?.(data);
					},
				};
			});

			for (const [name, value] of changes) {
				const command = value === "on" ? `/mcp:start ${name}` : `/mcp:stop ${name}`;
				pi.sendUserMessage(command, { expandPromptTemplates: true });
			}
		},
	});
}
