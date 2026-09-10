import { execFile } from "node:child_process"
import { promisify } from "node:util"

const exec = promisify(execFile)
const WEZTERM_PROCESS_NAMES = new Set(["WezTerm", "wezterm-gui"])
const SOUND_PATH = "/System/Library/Sounds/Glass.aiff"

const playSound = async () => {
	try {
		const { stdout } = await exec("osascript", [
			"-e",
			'tell application "System Events" to get name of first application process whose frontmost is true',
		])

		if (!WEZTERM_PROCESS_NAMES.has(stdout.trim())) {
			await exec("afplay", [SOUND_PATH])
		}
	} catch {
		// Notifications must not affect OpenCode if macOS automation or audio fails.
	}
}

export default {
	id: "idle-sound",
	async setup(context) {
		const waiting = new Set()
		const registration = await context.session.hook("context", (event) => {
			if (waiting.has(event.sessionID)) {
				return
			}

			waiting.add(event.sessionID)
			void context.session
				.wait({ sessionID: event.sessionID })
				.then(playSound)
				.catch(() => {})
				.finally(() => waiting.delete(event.sessionID))
		})

		return () => registration.dispose()
	},
	async server() {
		return {
			event: async ({ event }) => {
				if (event.type === "session.status" && event.properties.status.type === "idle") {
					await playSound()
				}
			},
		}
	},
}
