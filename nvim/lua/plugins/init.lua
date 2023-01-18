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

	'junegunn/vim-easy-align',
	'tpope/vim-surround', -- Add () with csaw(
	'editorconfig/editorconfig-vim',

	{
		'lewis6991/gitsigns.nvim',
		config = function ()
			require('gitsigns').setup()
		end
	}
}
