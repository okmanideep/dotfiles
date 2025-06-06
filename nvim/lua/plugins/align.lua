return {
	'junegunn/vim-easy-align',
	keys = {
		{'ga', '<Plug>(EasyAlign)', mode = {'n', 'v'}, desc = "Align"},
	},
	ft = 'markdown',
	config = function()
		local set_cursor_to_nth_bar = function(row, count)
			local line = vim.api.nvim_buf_get_lines(0, row, row + 1, false)[1]
			local cur_bar_count = 0
			---@type integer|nil
			local cur_col = 0 -- will be the col of the cursor + 1 by the end of the loop
			while cur_bar_count < count do
				cur_col = line:find('|', cur_col + 1)
				cur_bar_count = cur_bar_count + 1
			end
			vim.api.nvim_win_set_cursor(0, { row + 1, cur_col })
			vim.cmd [[startinsert!]]
		end

		local is_in_fenced_code_block = function()
			local node = vim.treesitter.get_node()
			if not node then return false end

			-- Traverse up through parent nodes to find a fenced code block
			while node do
				local type = node:type()
				if type == "fenced_code_block" then
					return true
				end
				node = node:parent()
			end

			return false
		end

		local on_bar_inserted = function()
			local pos = vim.api.nvim_win_get_cursor(0)
			local row = pos[1] - 1
			local col = pos[2]
			-- insert the |
			vim.api.nvim_buf_set_text(0, row, col, row, col, { '|' })
			-- move the cursor after the inserted bar
			vim.api.nvim_win_set_cursor(0, { row + 1, col + 1 })

			if not is_in_fenced_code_block() then
				local before_line = vim.api.nvim_get_current_line()
				-- record the number of bars in the line prior to the cursor
				local _, pre_bar_count = before_line:sub(0, col):gsub("|", "|")

				-- Easy Align markdown table
				vim.cmd [[ stopinsert ]]
				vim.cmd [[ normal! vip ]]   -- visually select the paragraph
				vim.api.nvim_feedkeys('ga*|', 'v', false) -- EasyAlign all |s in the paragraph -- ga = keymap for <Plug>(EasyAlign)

				-- place the cursor at the end of the entered | (pre_bar_count + 1)
				-- we need to schedule this since the above nvim_feedkeys need to trigger EasyAlign and it needs to
				-- update text before we try to set the cursor in the right place
				vim.schedule(
					function()
						set_cursor_to_nth_bar(row, pre_bar_count + 1)
					end
				)
			end
		end

		-- set ga as keymap for EasyAlign in normal and visual models
		vim.keymap.set('n', 'ga', '<Plug>(EasyAlign)', { desc = "Align", noremap = false })
		vim.keymap.set('v', 'ga', '<Plug>(EasyAlign)', { desc = "Align", noremap = false })

		local align_group = vim.api.nvim_create_augroup('AlignMDTable', { clear = true })
		vim.api.nvim_create_autocmd('FileType', {
			callback = function()
				vim.keymap.set('i', '<Bar>', on_bar_inserted,
					{ desc = "Align Tables", silent = true, buffer = true })
			end,
			group = align_group,
			pattern = "markdown",
		})
	end
}
