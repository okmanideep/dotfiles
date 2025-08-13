local methods = vim.lsp.protocol.Methods

-- Diagnostic keymaps
vim.keymap.set('n', '[d', function() vim.diagnostic.jump { count = -1 } end, { desc = 'LSP: ([)Prev [D]iagnostic' })
vim.keymap.set('n', ']d', function() vim.diagnostic.jump { count = 1 } end, { desc = 'LSP: (])Next [D]iagnostic' })
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'LSP: [E]ntire Diagnostic in float' })

vim.diagnostic.config({
	virtual_lines = { current_line = true },
})

local on_attach = function(client, bufnr)
	if client.name == "yamlls" then
		client.server_capabilities.documentFormattingProvider = true
	end

	local nmap = function(keys, func, desc)
		if desc then
			desc = 'LSP: ' .. desc
		end

		vim.keymap.set('n', keys, func, { buffer = bufnr, desc = desc })
	end

	nmap('gd', vim.lsp.buf.definition, '[G]oto [D]efinition')
	nmap('<leader>D', vim.lsp.buf.type_definition, 'Type [D]efinition')

	-- See `:help K` for why this keymap
	nmap('K', vim.lsp.buf.hover, 'Hover Documentation')

	-- Lesser used LSP functionality
	nmap('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
end

local servers = { 'pyright', 'gopls', 'ts_ls', 'lua_ls', 'solargraph', 'powershell_es', 'kotlin_lsp' }

-- Setup neovim lua configuration
require('neodev').setup()

-- Setup mason so it can manage external tooling
require('mason').setup()

-- Ensure the servers above are installed
local mason_lspconfig = require 'mason-lspconfig'

mason_lspconfig.setup {
	ensure_installed = servers,
	automatic_installation = true,
}

-- for each of the value in servers call vim.lsp.enable
for _, server in ipairs(servers) do
	vim.lsp.enable(server)
end

-- Update mappings when registering dynamic capabilities.
local register_capability = vim.lsp.handlers[methods.client_registerCapability]
vim.lsp.handlers[methods.client_registerCapability] = function(err, res, ctx)
	local client = vim.lsp.get_client_by_id(ctx.client_id)
	if not client then
		return
	end

	on_attach(client, vim.api.nvim_get_current_buf())

	return register_capability(err, res, ctx)
end

vim.api.nvim_create_autocmd('LspAttach', {
	desc = 'Configure LSP keymaps',
	callback = function(args)
		local client = vim.lsp.get_client_by_id(args.data.client_id)

		-- I don't think this can happen but it's a wild world out there.
		if not client then
			return
		end

		on_attach(client, args.buf)
	end,
})

-- Setep flutter-tools
require('flutter-tools').setup {
	fvm = true,
	lsp = {
		on_attach = on_attach,
	},
}

-- Turn on lsp status information
require('fidget').setup({})
