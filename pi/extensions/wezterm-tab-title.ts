import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

export default function weztermTabTitleExtension(pi: ExtensionAPI) {
	pi.registerCommand("title", {
		description: "Set the current WezTerm tab title",
		handler: async (args, ctx) => {
			const title = args.trim();
			const result = await pi.exec("wezterm", ["cli", "set-tab-title", title], { timeout: 5000 });

			if (result.code !== 0) {
				const error = result.stderr.trim() || "WezTerm CLI failed";
				ctx.ui.notify(error, "error");
				return;
			}

			ctx.ui.notify(title ? `Tab title: ${title}` : "Tab title cleared", "info");
		},
	});
}
