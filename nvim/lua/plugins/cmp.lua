-- Auto-completion:
return {
	{
		'saghen/blink.cmp',
		dependencies = 'L3MON4D3/LuaSnip',
		version = '1.*',
		event = { "InsertEnter", "CmdlineEnter" },
		opts = {
			keymap = {
				['<CR>'] = { 'accept', 'fallback' },
				['<C-\\>'] = { 'hide', 'fallback' },
				['<C-n>'] = { 'select_next', 'show' },
				['<Tab>'] = { 'select_next', 'snippet_forward', 'fallback' },
				['<C-p>'] = { 'select_prev' },
				['<C-b>'] = { 'scroll_documentation_up', 'fallback' },
				['<C-f>'] = { 'scroll_documentation_down', 'fallback' },
			},
			completion = {
				list = {
					-- Insert items while navigating the completion list.
					selection = { preselect = false, auto_insert = true },
					max_items = 10,
				},
				documentation = { auto_show = true },
			},
			snippets = { preset = 'luasnip' },
			cmdline = {
				completion = { menu = { auto_show = true } },
			},
			sources = {
				default = { 'lsp', 'path', 'snippets', 'buffer' },
			},
		},
		config = function(_, opts)
			require('blink.cmp').setup(opts)
		end,
	},
}
