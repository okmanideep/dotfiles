return {
	'hrsh7th/nvim-cmp',
	version = false,
	event = { "InsertEnter", "CmdlineEnter" },
	dependencies = {
		'onsails/lspkind.nvim',
		'hrsh7th/cmp-nvim-lsp',
		'hrsh7th/cmp-path',
		'hrsh7th/cmp-cmdline',
		'L3MON4D3/LuaSnip',
		'saadparwaiz1/cmp_luasnip',
	},
	config = function()
		local cmp = require'cmp'
		local lspkind = require'lspkind'

		cmp.setup({
			snippet = {
				expand = function(args)
					require('luasnip').lsp_expand(args.body)
					vim.cmd [[ :Format ]]
				end,
			},
			mapping = cmp.mapping.preset.insert({
				['<C-b>'] = cmp.mapping.scroll_docs(-4),
				['<C-f>'] = cmp.mapping.scroll_docs(4),
				['<C-Space>'] = cmp.mapping.complete(),
				['<C-e>'] = cmp.mapping.abort(),
				-- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
				['<CR>'] = cmp.mapping.confirm({ select = true }),
			}),
			sources = cmp.config.sources({
				{ name = 'nvim_lsp'},
				{ name = 'path'},
				{ name = 'luasnip'},
				{ name = 'buffer', keyword_length = 4 },
			}),
			formatting = {
				expandable_indicator = false,
				fields = { 'kind', 'abbr', 'menu' },
				format = lspkind.cmp_format({
					mode = 'symbol_text',
					menu = {
						buffer = "[buf]",
						nvim_lsp = "[LSP]",
						path = "[path]",
						luasnip = "[snip]",
					}
				})
			},
			experimental = {
				native_menu = false,
				ghost_text = true,
			}
		})

		cmp.setup.filetype('gitcommit', {
			sources = cmp.config.sources({
				{ name = 'buffer'}
			})
		})

		cmp.setup.cmdline('/', {
			mapping = cmp.mapping.preset.cmdline(),
			sources = {
				{ name = 'buffer' }
			}
		})

		cmp.setup.cmdline(':', {
			mapping = cmp.mapping.preset.cmdline(),
			sources = cmp.config.sources({
				{ name = 'path' }
			}, {
				{ name = 'cmdline' }
			})
		})

		local ls = require "luasnip"

		ls.config.set_config {
			-- This tells LuaSnip to remember to keep around the last snippet.
			-- You can jump back into it even if you move outside of the selection.
			history = true,

			-- This one is cool cause if you have dynamic snippets, it updates as you type!
			updateevents = "TextChanged,TextChangedI",

			-- Autosnippets
			enable_autosnippets = true,
		}

		local next = function()
			if ls.expand_or_jumpable() then
				ls.expand_or_jump()
			end
		end

		local prev = function ()
			if ls.jumpable(-1) then
				ls.jump(-1)
			end
		end

		vim.keymap.set({ "i", "s" }, "<c-j>", next, { silent = true })
		vim.keymap.set({ "i", "s" }, "<c-k>", prev, { silent = true })
	end
}
