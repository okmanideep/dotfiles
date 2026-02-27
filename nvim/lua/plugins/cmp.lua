-- Auto-completion:
return {
	{
		'saghen/blink.cmp',
		dependencies = {
			'L3MON4D3/LuaSnip',
			'moyiz/blink-emoji.nvim',
		},
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
				per_filetype = {
					markdown = { 'path', 'emoji' },
				},
				providers = {
					emoji = {
						module = 'blink-emoji',
						name = 'Emoji',
						opts = {
							insert = true,
							trigger = function()
								return { ':' }
							end,
						},
						transform_items = function(_, items)
							local line = vim.api.nvim_get_current_line()
							local cursor = vim.api.nvim_win_get_cursor(0)
							local before = line:sub(1, cursor[2] + 1)
							local keyword = before:match(':[%w_+%-]*$')
							if not keyword or #keyword <= 1 then
								return items
							end

							local aliases = {
								tada = '🎉',
							}

							local alias_items = {}
							for name, emoji in pairs(aliases) do
								local alias_label = ':' .. name .. ':'
								if alias_label:sub(1, #keyword) == keyword then
									alias_items[#alias_items + 1] = {
										label = alias_label,
										filterText = alias_label,
										insertText = emoji,
									}
								end
							end

							return vim.list_extend(alias_items, items)
						end,
					},
				},
			},
		},
		config = function(_, opts)
			require('blink.cmp').setup(opts)
		end,
	},
}
