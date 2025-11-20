return {
	settings = {
		Lua = {
			runtime = {
				version = "Lua 5.1", -- Neovim embeds LuaJIT (Lua 5.1)
			},
			workspace = { checkThirdParty = false },
			telemetry = { enable = false },
			diagnostics = { globals = { 'vim' } },
		},
	}
}
