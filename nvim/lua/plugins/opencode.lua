return {
	"sudo-tee/opencode.nvim",
	config = function()
		require("opencode").setup({
			keymap_prefix = '<leader>a',
		})
	end,
	dependencies = {
		"nvim-lua/plenary.nvim",
		{
			"MeanderingProgrammer/render-markdown.nvim",
			opts = {
				anti_conceal = { enabled = false },
				file_types = { 'markdown', 'opencode_output' },
			},
			ft = { 'markdown', 'copilot-chat', 'opencode_output' },
		},
	}
}
