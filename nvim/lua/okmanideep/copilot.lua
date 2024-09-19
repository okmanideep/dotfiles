-- disable by default
vim.g.copilot_filetypes = {
	["*"] = false,
}

-- explicitly request for copilot suggestions on Ctrl-Enter
vim.keymap.set('i', '<C-CR>', '<Plug>(copilot-suggest)')
