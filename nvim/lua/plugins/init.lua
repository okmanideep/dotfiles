return {
	{
		'numToStr/Comment.nvim', -- "gc" to comment visual regions/lines
		config = function()
			require('Comment').setup()
		end
	},

	{
		'lukas-reineke/indent-blankline.nvim', -- Add indentation guides even on blank lines
		main = "ibl",
		opts = { scope = { enabled = false } },
	},

	'junegunn/vim-easy-align',
	'tpope/vim-surround',      -- Add () with csaw(
	'nvim-treesitter/playground', -- Treesitter playground :TSHighlightCapturesUnderCursor

	{
		'lewis6991/gitsigns.nvim',
		config = function()
			require('gitsigns').setup()
		end
	},
	{
		'folke/trouble.nvim',
		config = function()
			require('trouble').setup()

			vim.keymap.set('n', '<leader>x', '<cmd>Trouble diagnostics toggle<cr>', { desc = 'LSP: Toggle Diagnostics' })
			vim.keymap.set('n', 'gx', '<cmd>Trouble diagnostics toggle filter.buf=0<cr>',
				{ desc = 'LSP: Toggle Diagnostics' })
		end
	},

	'github/copilot.vim'
}
