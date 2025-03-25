return {
	"zbirenbaum/copilot.lua",
	cmd = "Copilot",
	event = "InsertEnter",
	config = function()
		require("copilot").setup({
			suggestion = {
				auto_trigger = false,
				keymap = {
					accept = false,
					next = "<C-h>",
					accept_line = "<C-l>",
				}
			}
		})

		local suggestion = require('copilot.suggestion')
		vim.keymap.set('i', '<Tab>', function()
			if (suggestion.is_visible()) then
				suggestion.accept()
			else
				local expandtab = vim.bo.expandtab
				local shiftwidth = vim.bo.shiftwidth
				local indent_str

				if expandtab then
					indent_str = string.rep(" ", shiftwidth)
				else
					indent_str = "\t"
				end

				vim.api.nvim_put({ indent_str }, 'c', false, true)
			end
		end, { noremap = true, expr = false })
	end,
}
