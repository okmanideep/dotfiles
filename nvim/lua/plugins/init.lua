return {
	{
		'numToStr/Comment.nvim', -- "gc" to comment visual regions/lines
		config = function ()
			require('Comment').setup()
		end
	},

	{
		'lukas-reineke/indent-blankline.nvim', -- Add indentation guides even on blank lines
		config = function ()
			require('indent_blankline').setup {
				show_trailing_blankline_indent = false
			}
		end
	},

	{
		'junegunn/vim-easy-align',
		config = function ()
			vim.keymap.set('n', 'ga', '<Plug>(EasyAlign)', { desc = "Align", noremap = false })
			vim.keymap.set('x', 'ga', '<Plug>(EasyAlign)', { desc = "Align", noremap = false })
		end
	},
	'tpope/vim-surround', -- Add () with csaw(
	'tpope/vim-sleuth', -- automatically set shiftwidth, expandtab based on the file that is opened

	{
		'lewis6991/gitsigns.nvim',
		config = function ()
			require('gitsigns').setup()
		end
	}
}