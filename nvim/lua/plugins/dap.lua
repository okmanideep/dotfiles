return {
	"rcarriga/nvim-dap-ui",
	dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" },
	config = function()
		local dap, dapui = require("dap"), require("dapui")
		-- nvim dap mappings
		vim.keymap.set('n', '<F1>', function() dap.continue() end, { desc = "Debugger Continue" })
		vim.keymap.set('n', '<F2>', function() dap.step_over() end, { desc = "Debugger Step Over" })
		vim.keymap.set('n', '<F3>', function() dap.step_into() end, { desc = "Debugger Step Into" })
		vim.keymap.set('n', '<F4>', function() dap.step_out() end, { desc = "Debugger Step Out" })
		vim.keymap.set('n', '<F5>', function() dap.toggle_breakpoint() end, { desc = "Debugger Toggle Breakpoint" })

		dapui.setup()

		-- open Dap UI automatically when debug starts (e.g. after <F5>)
		dap.listeners.before.attach.dapui_config = function()
			dapui.open()
		end
		dap.listeners.before.launch.dapui_config = function()
			dapui.open()
		end
		-- close Dap UI with :DapCloseUI
		vim.api.nvim_create_user_command("DapCloseUI", function()
			require("dapui").close()
		end, {})

		-- use <Alt-e> to eval expressions
		vim.keymap.set({ 'n', 'v' }, '<M-e>', function() require('dapui').eval() end)

		-- makes nvim-dap work w/ .vscode/launch.json files
		require('dap.ext.vscode').load_launchjs(nil, {})

		local sign = vim.fn.sign_define

		sign("DapBreakpoint", { text = "●", texthl = "DapBreakpoint", linehl = "", numhl = "" })
		sign("DapBreakpointCondition", { text = "●", texthl = "DapBreakpointCondition", linehl = "", numhl = "" })
		sign("DapLogPoint", { text = "◆", texthl = "DapLogPoint", linehl = "", numhl = "" })
		sign('DapStopped', { text = '', texthl = 'DapStopped', linehl = 'DapStopped', numhl = 'DapStopped' })


		-- Define your color table
		local C = {
			grey = "#505050", -- Replace with your desired grey color
		}

		-- Set the highlight group
		vim.api.nvim_set_hl(0, 'DapStopped', { bg = C.grey })


		-- configure codelldb adapter
		-- codelldb needs to be installed via VSCodium, and then put in the path, like so:
		-- cd ~/bin && ln -s ~/.vscode-oss/extensions/vadimcn.vscode-lldb-1.10.0-universal/adapter/codelldb codelldb
		dap.adapters.codelldb = {
			type = "server",
			port = "${port}",
			executable = {
				command = "codelldb",
				args = { "--port", "${port}" },
			},
		}

		-- setup a debugger for zig projects
		dap.configurations.zig = {
			{
				name = 'Launch',
				type = 'codelldb',
				request = 'launch',
				program = function()
					return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
				end,
				cwd = '${workspaceFolder}',
				stopOnEntry = false,
				args = {
				},
			},
		}
	end
}
