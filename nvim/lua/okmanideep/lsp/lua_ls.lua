return {
	settings = {
		Lua = {
			runtime = {
				version = "Lua 5.1", -- Neovim embeds LuaJIT (Lua 5.1)
			},
			workspace = { checkThirdParty = false, library = vim.api.nvim_get_runtime_file('', true) },
			telemetry = { enable = false },
			diagnostics = { globals = { 'vim' } },
		},
	}
}
