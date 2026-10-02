return {
	"pablopunk/pi.nvim",
	keys = {
		{ "<leader>pi", "<cmd>PiAsk<CR>", mode = "n", desc = "Ask Pi about buffer" },
		{ "<leader>pi", "<cmd>PiAskSelection<CR>", mode = "v", desc = "Ask Pi about selection" },
	},
	config = function()
		require("pi").setup()
	end,
}
