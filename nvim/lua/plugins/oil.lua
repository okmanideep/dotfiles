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
		require('nvim-web-devicons').setup {
			override_by_extension = {
				["webc"] = {
					icon = "",
					color = "#8EB31F",
					name = "Webc"
				}
			}
		}

		vim.keymap.set('n', '-', '<cmd>Oil<cr>', { desc = "Open parent directory" })
		vim.keymap.set('n', '<leader>d', require('oil').toggle_float,
			{ desc = "Open parent deirectory in a floating window" })
		vim.keymap.set('n', 'gm', function() require('oil').set_sort({ { "mtime", "desc" } }) end,
			{ desc = "Sort by modified time in descending order" })
	end
}
