local cmp = require'cmp'
local lspkind = require'lspkind'

cmp.setup({
    snippet = {
        expand = function(args)
            require('luasnip').lsp_expand(args.body)
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
        { name = 'jira'},
        { name = 'nvim_lua'},
        { name = 'nvim_lsp'},
        { name = 'path'},
        { name = 'luasnip'},
        { name = 'buffer', keyword_length = 4 },
    }),
    formatting = {
        format = lspkind.cmp_format({
            mode = 'symbol_text',
            menu = {
                buffer = "[buf]",
                nvim_lsp = "[LSP]",
                nvim_lua = "[NVIM]",
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
