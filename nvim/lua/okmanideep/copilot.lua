-- disable by default
vim.g.copilot_filetypes = {
	["*"] = false,
}

-- explicitly request for copilot suggestions on Ctrl-H
vim.keymap.set('i', '<C-h>', '<Plug>(copilot-suggest)', { noremap = true, desc = 'Trigger copilot suggestions' })

-- accept line using Ctrl-L
vim.keymap.set('i', '<C-l>', '<Plug>(copilot-accept-line)', { noremap = true, desc = 'Accept single line in copilot suggestion' })
