local open_pad = function ()
	local filename = vim.fn.expand('%:p')
	vim.fn.system({
		"pad",
		"open",
		filename,
	})
end

vim.keymap.set('n', 'gp', open_pad, { desc = "Scratchpad Open" })
