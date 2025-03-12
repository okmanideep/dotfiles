return {
	"zbirenbaum/copilot.lua",
	cmd = "Copilot",
	event = "InsertEnter",
	config = function ()
		require("copilot").setup({
			suggestion = {
				auto_trigger = false,
				keymap = {
					accept = "<Tab>",
					next = "<C-h>",
					accept_line = "<C-l>",
				}
			}
		})
	end,
}
