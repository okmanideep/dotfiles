return {
	'stevearc/oil.nvim',
	-- Optional dependencies
	dependencies = { "nvim-tree/nvim-web-devicons" },
	config = function()
		require('oil').setup {
			columns = { "icon" },
			keymaps = {
				["<C-h"] = false,
			},
			view_options = {
				show_hidden = true,
			}
		}

		vim.keymap.set('n', '-', '<cmd>Oil<cr>', { desc = "Open parent directory" })
		vim.keymap.set('n', '<leader>-', require('oil').toggle_float,
			{ desc = "Open parent deirectory in a floating window" })
	end
}
