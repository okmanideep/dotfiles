return {
	'ziontee113/icon-picker.nvim',
	dependencies = { 'stevearc/dressing.nvim' },
	keys = {
		{ '<leader>i', '<cmd>IconPickerNormal nerd_font<cr>', desc = "Nerd Font Icon Picker" },
	},
	config = function()
		require("icon-picker").setup {
			disable_legacy_commands = true,
		}
	end
}
