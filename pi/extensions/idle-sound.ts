import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { execFile } from "node:child_process";
import { promisify } from "node:util";

const exec = promisify(execFile);
const WEZTERM_PROCESS_NAMES = new Set(["WezTerm", "wezterm-gui"]);
const SOUND_PATH = "/System/Library/Sounds/Glass.aiff";

export default function (pi: ExtensionAPI) {
	pi.on("agent_settled", async (_event, ctx) => {
		if (ctx.mode !== "tui") return;

		try {
			const { stdout } = await exec("osascript", [
				"-e",
				'tell application "System Events" to get name of first application process whose frontmost is true',
			]);

			if (!WEZTERM_PROCESS_NAMES.has(stdout.trim())) {
				await exec("afplay", [SOUND_PATH]);
			}
		} catch {
			// Notifications must not affect the agent if macOS automation or audio fails.
		}
	});
}
