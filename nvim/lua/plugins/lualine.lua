return {
	'nvim-lualine/lualine.nvim',
	dependencies = {
		'nvim-tree/nvim-web-devicons',
	},
	config = function()
		require('lualine').setup {
			options = {
				icons_enabled = true,
				theme = 'onedark',
				component_separators = '|',
				section_separators = '',
			},
			inactive_sections = {
				lualine_y = { 'progress' },
			}
		}
	end
}
