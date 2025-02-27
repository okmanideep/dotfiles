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
		require('formatter.filetypes.typescript').prettier,
	},
	json = {
		require('formatter.filetypes.json').jq,
	},
}

require('formatter').setup {
	filetype = settings
}

local format = function()
	if settings[vim.bo.filetype] ~= nil then
		vim.cmd([[Format]])
	else
		vim.lsp.buf.format()
	end
end

vim.api.nvim_create_autocmd("BufWritePost", {
	pattern = { "*.*" },
	callback = format,
	group = vim.api.nvim_create_augroup("FormatOnSave", { clear = true })
})
