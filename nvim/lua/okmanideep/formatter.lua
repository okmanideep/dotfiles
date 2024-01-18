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

require('formatter').setup {
	filetypes = {
		dart = {
			dartformat
		},
		typescript = {
			require('formatter.filetypes.typescript').prettier,
		}
	}
}

vim.cmd [[
	augroup FormatAutogroup
	  autocmd!
	  autocmd BufWritePre *.dart,*.lua,*.ts Format
	augroup END
]]
