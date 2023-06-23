local run_build_runner = function()
	local path = vim.fn.expand('%:h')
	local filename = vim.fn.expand('%:t') --with extension
	local filename_without_extension = vim.fn.expand('%:t:r') --without extension
	local extension = vim.fn.expand('%:e')
	if (extension ~= 'dart') then
		print("Not a dart file")
		return
	end

	local file_relative_path = vim.fn.expand('%')
	-- remove the generated file
	local generated_file = file_relative_path .. filename_without_extension .. '.g.dart'
	vim.fn.delete(generated_file)

	print("Running flutter build runner for " .. filename)
	vim.fn.system({ 'fvm', 'flutter', 'pub', 'run', 'build_runner', 'build', '--build-filter=' .. generated_file })
	print("Done running flutter build runner for " .. path)
end

vim.keymap.set('n', '<leader>br', run_build_runner, {
	noremap = true,
	silent = true,
	desc = "Run flutter build runner"
})
