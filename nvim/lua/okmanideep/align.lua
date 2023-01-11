local align_group = vim.api.nvim_create_augroup('AlignMDTable', { clear = true })
vim.api.nvim_create_autocmd('FileType', {
	callback = function()
		vim.keymap.set('i', '<Bar>', '<Bar><Esc><Plug>(EasyAlign)ip*<Bar><CR>a', { desc = "Align Tables", silent = true })
	end,
	group = align_group,
	pattern = "md",
})
