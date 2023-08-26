return {
	'LhKipp/nvim-nu',
	dependencies = {
		'nvim-treesitter/nvim-treesitter',
	},
	build = function()
		vim.cmd [[:TSInstall nu]]
	end,
	init = function()
		require('nu').setup {
			use_lsp_features = false,
		}
	end
}
