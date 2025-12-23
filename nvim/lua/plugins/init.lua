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

	'tpope/vim-surround',      -- Add () with csaw(

	{
		'lewis6991/gitsigns.nvim',
		config = function()
			require('gitsigns').setup()
		end
	},
	{
		'folke/trouble.nvim',
		keys = {
			{ '<leader>x', '<cmd>Trouble diagnostics toggle<cr>',              desc = 'LSP: Toggle Diagnostics' },
			{ 'gx',        '<cmd>Trouble diagnostics toggle filter.buf=0<cr>', desc = 'LSP: Toggle Buffer Diagnostics' },
		},
		config = function()
			require('trouble').setup()
		end,
	}
}
