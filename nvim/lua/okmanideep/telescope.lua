local telescope = require("telescope")
local telescopeConfig = require("telescope.config")

-- Clone the default Telescope configuration
local vimgrep_arguments = { unpack(telescopeConfig.values.vimgrep_arguments) }

-- I want to search in hidden/dot files.
table.insert(vimgrep_arguments, "--hidden")
-- I don't want to search in the `.git` directory.
table.insert(vimgrep_arguments, "--glob")
table.insert(vimgrep_arguments, "!**/.git/*")
-- telescope
telescope.setup {
	defaults = {
		layout_strategy = 'flex',
		sorting_strategy = 'ascending',
		layout_config = {
			prompt_position = "top",
		},
		use_less = true,
		vimgrep_arguments = vimgrep_arguments,
	},
	pickers = {
		find_files = {
			hidden = true,
		}
	},
	extensions = {
		["ui-select"] = require('telescope.themes').get_dropdown {}
	}
}

telescope.load_extension("ui-select")

vim.keymap.set("n", "<leader>o", "<cmd>Telescope find_files<cr>")
vim.keymap.set("n", "<leader>h", "<cmd>Telescope help_tags<cr>")
vim.keymap.set("n", "<leader>f", "<cmd>Telescope current_buffer_fuzzy_find<cr>")
vim.keymap.set("n", "<leader>F", "<cmd>Telescope live_grep<cr>")
vim.keymap.set("n", "<leader>k", "<cmd>Telescope keymaps<cr>")
vim.keymap.set("n", "<leader>O", "<cmd>Telescope oldfiles<cr>")
vim.keymap.set("n", "<leader>b", "<cmd>Telescope buffers<cr>")
