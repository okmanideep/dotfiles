local set_cursor_to_nth_bar = function (row, count)
	local line = vim.api.nvim_buf_get_lines(0, row, row + 1, false)[1]
	local cur_bar_count = 0
	local cur_col = 0 -- will be the col of the cursor + 1 by the end of the loop
	while cur_bar_count < count do
		cur_col = line:find('|', cur_col + 1)
		cur_bar_count = cur_bar_count + 1
	end
	vim.api.nvim_win_set_cursor(0, {row + 1, cur_col})
	vim.cmd [[startinsert!]]
end

local on_bar_inserted = function ()
	local pos = vim.api.nvim_win_get_cursor(0)
	local row = pos[1] - 1
	local col = pos[2]
	local before_line = vim.api.nvim_get_current_line()
	-- record the number of bars in the line prior to the cursor
	local _, pre_bar_count = before_line:sub(0, col):gsub("|", "|")

	-- insert the |
	vim.api.nvim_buf_set_text(0, row, col, row, col, { '|' })

	-- Easy Align markdown table
	vim.cmd [[ stopinsert ]]
	vim.cmd [[ normal! vip<Plug>(EasyAlign)*| ]] -- visually select the paragraph, EasyAlign all | -- () around EasyAlign are important

	-- place the cursor at the end of the entered | (pre_bar_count + 1)
	-- we need to schedule this since the above nvim_feedkeys need to trigger EasyAlign and it needs to
	-- update text before we try to set the cursor in the right place
	vim.schedule(
		function ()
			set_cursor_to_nth_bar(row, pre_bar_count + 1)
		end
	)
end

local align_group = vim.api.nvim_create_augroup('AlignMDTable', { clear = true })
vim.api.nvim_create_autocmd('FileType', {
	callback = function()
		vim.keymap.set('i', '<Bar>', on_bar_inserted, { desc = "Align Tables", silent = true })
	end,
	group = align_group,
	pattern = "markdown",
})
