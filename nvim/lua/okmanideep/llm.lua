local api_key = os.getenv("OPEN_AI_API_KEY")

vim.api.nvim_create_user_command('AskLLM', function(opts)
	if api_key == nil then
		print "NO API KEY FOUND"
	end

	local start_line = opts.line1
	local end_line = opts.line2

	if start_line == end_line then
		print("Invoked in Normal Mode")
	else
		local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)
		local combined = table.concat(lines, "\n");
		local filetype = vim.api.nvim_buf_get_option(0, "filetype")
		local code_block = "```" .. filetype .. "\n" .. combined .. "\n```"

		vim.ui.input({ prompt = "AskLLM: " }, function(prompt)
			vim.system({
				"curl", "-s", "-X", "POST", "https://api.openai.com/v1/chat/completions",
				"-H", "Content-Type: application/json",
				"-H", "Authorization: Bearer " .. api_key,
				"-d", vim.fn.json_encode({
				model = "gpt-4.1",
				messages = {
					{ role = "developer", content = "The following message will be the block of code that the user is attempting to modify. Followed by the user's prompt about their intent. Respond with the diff of changes" },
					{ role = "user",      content = code_block },
					{ role = "user",      content = prompt },
				}
			}),
			}, {}, function(obj)
				if obj.code == 0 then
					print("OpenAI Response:")
					print(obj.stdout)
				else
					print("Error:")
					print(obj.stderr)
				end
			end)
		end)
	end
end, { range = true })
