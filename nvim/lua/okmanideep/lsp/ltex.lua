local function curbuf_uri()
	return vim.uri_from_bufnr(vim.api.nvim_get_current_buf())
end

local wrap_command_handler = function(handler)
	return function(cmd, ctx)
		local args = cmd.arguments[1]
		local client = vim.lsp.get_client_by_id(ctx.client_id)
		if client == nil then error("Could not find client for id: " .. ctx.client_id) end

		local checkDocument = handler(client, args)

		if checkDocument then
			client.request("workspace/executeCommand",
				{ command = "_ltex.checkDocument", arguments = { { uri = args.uri or curbuf_uri() } } })
		end
	end
end

local create_config

local addToDictionary = function(_, args)
	local words = args.words["en-US"] -- { "word1", "word2" ...}

	-- append to "spell/en.utf-8.add"
	local spellfile = vim.api.nvim_get_runtime_file("spell/en.utf-8.add", true)[1]
	if spellfile == nil then
		error("Could not find spellfile 'spell/en.utf-8.add' in runtime path")
	end
	local f = io.open(spellfile, "a")
	if f == nil then
		error("Could not open spellfile '" .. spellfile .. "' for appending")
	end
	for _, word in ipairs(words) do
		f:write(word .. "\n")
	end
	f:close()

	-- restart ltex lsp server
	vim.lsp.enable('ltex', false)
	vim.lsp.config('ltex', create_config())
	vim.lsp.enable('ltex', true)

	return false
end

create_config = function()
	return {
		filetypes = { "latex", "tex", "bib" },
		commands = {
			["_ltex.addToDictionary"] = wrap_command_handler(addToDictionary),
		},
		settings = {
			ltex = {
				enabled = { "latex", "tex", "bib" },
				language = "en-US",
				diagnosticSeverity = "information",
				sentenceCacheSize = 2000,
				additionalRules = {
					enablePickyRules = false,
				},
				dictionary = (function()
					local spellfile = vim.api.nvim_get_runtime_file("spell/en.utf-8.add", true)[1]
					-- read the file and create a table words with each line in the file as an entry in the table
					local words = {}
					if spellfile ~= nil then
						for line in io.lines(spellfile) do
							table.insert(words, line)
						end
						return { ["en-US"] = words }
					else
						return { ["en-US"] = {} }
					end
				end)(),
			},
		},
	}
end

return create_config()
