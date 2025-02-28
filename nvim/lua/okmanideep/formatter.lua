local dartformat = function(t)
	t = t or {}

	local args = { "--output show" }
	if t.line_length ~= nil then
		table.insert(args, "--line-length " .. t.line_length)
	end

	return {
		exe = "fvm dart format",
		args = args,
		stdin = true,
	}
end

local settings = {
	dart = {
		dartformat
	},
	typescript = {
		require('formatter.filetypes.typescript').prettier
	},
	json = {
		require('formatter.filetypes.json').jq
	},
}

require('formatter').setup {
	filetype = settings
}

local format = function(write)
	write = write or false
	if settings[vim.bo.filetype] ~= nil then
		if write then
			vim.cmd([[FormatWrite]])
		else
			vim.cmd([[Format]])
		end
	else
		vim.lsp.buf.format()
		if write then
			vim.cmd([[write]])
		end
	end
end

vim.api.nvim_create_autocmd("BufWritePre", {
	pattern = { "*.dart", "*.go", "*.webc" },
	callback = function() format(true) end,
	group = vim.api.nvim_create_augroup("FormatOnSave", { clear = true })
})

vim.keymap.set('n', '<leader>f', format, { noremap = true, silent = true })
