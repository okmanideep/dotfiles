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
	filetype = {
		dart = {
			dartformat
		},
		typescript = {
			require('formatter.filetypes.typescript').prettier,
		},
		json = {
			require('formatter.filetypes.json').jq,
		}
	}
}

vim.cmd [[
	augroup FormatAutogroup
	  autocmd!
	  autocmd BufWritePost *.dart,*.lua,*.ts Format
	augroup END
]]
