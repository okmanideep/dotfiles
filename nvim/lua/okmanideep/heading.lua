function add_heading()
	-- inserts markdown heading based on filename

	-- get filename without extension
	local filename = vim.fn.expand("%:t:r")
	-- convert from kabab case to title case
	local title = filename:gsub("-", " "):gsub("(%l)(%w*)", function(a, b) return string.upper(a) .. b end)

	-- insert heading
	vim.api.nvim_put({ "# " .. title }, "c", true, true)
end

-- key binding to add heading
vim.keymap.set("n", "<leader>ah", add_heading, { noremap = true, silent = true })
