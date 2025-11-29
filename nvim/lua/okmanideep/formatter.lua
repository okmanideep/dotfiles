local dartformat = function(t)
	t = t or {}

	local args = { "--output show" }
	if t.line_length ~= nil then
		table.insert(args, "--line-length " .. t.line_length)
	end

	return {
		exe = "dart format",
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

local has_lsp_format = function()
	for _, client in ipairs(vim.lsp.get_clients({ bufnr = 0 })) do
		if client:supports_method('textDocument/formatting') then
			return true
		end
		local caps = client.server_capabilities
		if caps and caps.documentFormattingProvider then
			return true
		end
	end
	return false
end

local format = function(write)
	write = write or false
	if settings[vim.bo.filetype] ~= nil then
		if write then
			vim.cmd([[FormatWrite]])
		else
			vim.cmd([[Format]])
		end
		return
	end
	if has_lsp_format() then
		vim.lsp.buf.format()
		if write then
			vim.cmd([[write]])
		end
		return
	end
	-- Fallback: reindent the whole buffer (respects .editorconfig via buffer options)
	vim.cmd([[normal! gg=G]])
	if write then
		vim.cmd([[write]])
	end
end

local format_group = vim.api.nvim_create_augroup("FormatOnSave", { clear = true })
vim.api.nvim_create_autocmd("BufWritePre", {
	pattern = { "*.dart", "*.go", "*.webc" },
	callback = function(args)
		local buftype = vim.api.nvim_get_option_value("buftype", { buf = args.buf })
		if buftype ~= "" then return end -- skip non-normal buffers

		-- optionally skip specific filetypes like 'oil'
		local ft = vim.api.nvim_get_option_value("filetype", { buf = args.buf })
		if ft == "oil" then return end

		format(true)
	end,
	group = format_group,
})

vim.keymap.set('n', 'gf', format, { noremap = true, silent = true, desc = "[F]ormat File" })
