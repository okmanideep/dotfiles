-- telescope
require('telescope').setup {
    vimgrep_arguments = {
        "rg",
        "--color=never",
        "--with-filename",
        "--line-number",
        "--column",
        "--smart-case",
        "--hidden",
        "--glob='!.git/*'"
    },
    defaults = {
        layout_strategy = 'flex',
        sorting_strategy = 'ascending',
        layout_config = {
            prompt_position = "top",
        },
        use_less = true,
    },
    pickers = {
        find_files = {
            hidden = true,
        }
    },
}

vim.keymap.set("n", "<leader>o", "<cmd>Telescope find_files<cr>")
vim.keymap.set("n", "<leader>h", "<cmd>Telescope help_tags<cr>")
vim.keymap.set("n", "<leader>f", "<cmd>Telescope current_buffer_fuzzy_find<cr>")
vim.keymap.set("n", "<leader>F", "<cmd>Telescope live_grep<cr>")
