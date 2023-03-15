local open_mote = function ()
	local filename = vim.fn.expand('%:p')
	vim.fn.system({
		"mote",
		"open",
		filename,
	})
end

vim.keymap.set('n', 'gn', open_mote, { desc = "Mote Open" })
