-- nvim terminal escape
vim.keymap.set('t', '<Esc>', '<C-\\><C-n>', {
	desc = 'Escape to normal mode in terminal mode'
})

-- Faster Top Down movements
vim.keymap.set('n', 'T', '<C-u>')
vim.keymap.set('v', 'T', '<C-u>')
vim.keymap.set('n', 'B', '<C-d>')
vim.keymap.set('v', 'B', '<C-d>')
-- z<cr> - moves the current line to the top of the screen
-- z.    - moves the current line to the center of the screen
-- z-    - moves the current line to the bottom of the screen

-- Switch splits faster
vim.keymap.set('n', '<C-h>', '<C-w>h')
vim.keymap.set('n', '<C-j>', '<C-w>j')
vim.keymap.set('n', '<C-k>', '<C-w>k')
vim.keymap.set('n', '<C-l>', '<C-w>l')
vim.keymap.set('t', '<C-h>', '<C-w>h')
vim.keymap.set('t', '<C-j>', '<C-w>j')
vim.keymap.set('t', '<C-k>', '<C-w>k')
vim.keymap.set('t', '<C-l>', '<C-w>l')

-- go to cmd mode more easily
vim.keymap.set('n', ';', ':')
vim.keymap.set('v', ';', ':')

-- alternative to ';' since 👆
vim.keymap.set('n', '\\', ';')

vim.g['netrw_banner'] = 0
vim.g['netrw_winsize'] = 25
vim.g['netrw_sort_by'] = 'time'
vim.g['netrw_sort_direction'] = 'reverse'

-- copy to clipboard and paste from clipboard
vim.keymap.set('n', '<leader>y', '"+y', { desc = "Copy to clipboard" })
vim.keymap.set('n', '<leader>p', '"+p', { desc = "Paste from clipboard" })
vim.keymap.set('v', '<leader>y', '"+y', { desc = "Copy to clipboard" })
vim.keymap.set('v', '<leader>p', '"+p', { desc = "Paste from clipboard" })

-- reload current file
vim.keymap.set('n', '<leader>rl', ':w<CR>:e!<CR>', { silent = true, desc = "reload current file" })

-- Git Blame
vim.keymap.set('n', 'gb', ':Gitsigns blame_line<CR>', { desc = '[G]it [B]lame' })

local switch_to_terminal = function()
	local buffers = vim.fn.getbufinfo({ loaded = 1 })
	for _, buffer in ipairs(buffers) do
		if vim.api.nvim_buf_get_option(buffer.bufnr, 'buftype') == 'terminal' then
			vim.cmd('buffer ' .. buffer.bufnr)
			return
		end
	end
	-- if there is no terminal buffer
	vim.cmd('terminal pwsh')
end

vim.keymap.set('n', '<leader>t', switch_to_terminal, { silent = true, desc = "switch to terminal" })

vim.keymap.set('n', '<C-q>', ':cclose<CR>', { desc = "close quickfix" })

-- make Option+Shift+4 output rupee symbol only if mac
local is_mac = vim.fn.has("macunix") == 1 or vim.fn.has("mac") == 1
if is_mac then
	vim.keymap.set('i', '<M-$>', '₹', { noremap = true })
end
