vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
vim.o.tabstop = 4
vim.o.shiftwidth = 4
vim.o.expandtab = false
vim.o.smartindent = true
vim.o.fileformats = 'unix,dos'
vim.o.hidden = true --Moving out of the file hides it and doesn't close
vim.o.number = false
vim.o.wrap = false
vim.o.colorcolumn = '+1'
vim.wo.signcolumn = 'yes'
vim.o.hlsearch = false -- don't highlight search results after searching
vim.o.incsearch = true -- highlight search results while typing
vim.o.magic = true     -- \d = number in cmd line regex etc
vim.o.listchars = 'tab:| ,trail:·'
vim.o.list = true
vim.o.title = true
vim.o.titlestring = '%{expand("%:p:~")}'
vim.o.scrolloff = 3
vim.o.updatetime = 500
vim.o.completeopt = 'menu,menuone,noselect'
vim.o.autowriteall = true
vim.o.termguicolors = true
vim.go.showmode = false

local autosave_group = vim.api.nvim_create_augroup('AutoSave', { clear = true })
vim.api.nvim_create_autocmd({ 'FocusLost', 'BufLeave' }, {
	callback = function()
		if vim.bo.filetype == 'oil' or vim.bo.filetype == 'oil_preview' or vim.bo.filetype == 'buffer' then
			return
		end

		vim.cmd [[ :wa! ]]
	end,
	pattern = "*",
	group = autosave_group,
})

-- PLUGINS! by lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"git@github.com:folke/lazy.nvim.git",
		"--branch=stable", -- latest stable release
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

require('lazy').setup('plugins', {
	rocks = { enabled = false },
	change_detection = { notify = false },
})

vim.cmd [[colorscheme onedark]]
vim.cmd [[
highlight @keyword cterm=italic gui=italic
highlight @keyword.function cterm=italic gui=italic
highlight @include cterm=italic gui=italic
highlight link @type.qualifier @keyword
]]

require('okmanideep')
