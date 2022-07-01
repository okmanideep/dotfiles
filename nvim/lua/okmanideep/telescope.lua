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
        layout_strategy = 'horizontal',
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
