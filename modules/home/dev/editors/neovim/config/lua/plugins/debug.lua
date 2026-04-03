local utils = require("utils")

return {
	{
		"nvim-dap",
		enabled = nixCats("general") or false,
		keys = {
			{ "<F5>", desc = "Debug (Start/Continue)" },
			{ "<F1>", desc = "Debug (Step Into)" },
			{ "<F2>", desc = "Debug (Step Over)" },
			{ "<F3>", desc = "Debug (Step Out)" },
			{ "<leader>cb", desc = "Breakpoint (Toggle)" },
			{ "<leader>cB", desc = "Breakpoint (Condition)" },
			{ "<F7>", desc = "Debug (Last Result)" },
		},
		after = function()
			local dap = require("dap")
			local dapui = require("dapui")

			utils.nmap("<F5>", dap.continue, "Debug (Start/Continue)")
			utils.nmap("<F1>", dap.step_into, "Debug (Step Into)")
			utils.nmap("<F2>", dap.step_over, "Debug (Step Over)")
			utils.nmap("<F3>", dap.step_out, "Debug (Step Out)")
			utils.nmap("<leader>cb", dap.toggle_breakpoint, "Breakpoint (Toggle)")
			utils.nmap("<leader>cB", function()
				dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
			end, "Breakpoint (Condition)")

			utils.nmap("<F7>", dapui.toggle, "Debug (Last Result)")

			dap.listeners.after.event_initialized["dapui_config"] = function()
				dapui.open()
			end
			dap.listeners.before.event_terminated["dapui_config"] = function()
				dapui.close()
			end
			dap.listeners.before.event_exited["dapui_config"] = function()
				dapui.close()
			end

			dapui.setup({
				icons = { expanded = "▾", collapsed = "▸", current_frame = "*" },
				controls = {
					icons = {
						pause = "⏸",
						play = "▶",
						step_into = "⏎",
						step_over = "⏭",
						step_out = "⏮",
						step_back = "b",
						run_last = "▶▶",
						terminate = "⏹",
						disconnect = "⏏",
					},
				},
			})

			require("nvim-dap-virtual-text").setup({
				enabled = true,
				enabled_commands = true,
				highlight_changed_variables = true,
				highlight_new_as_changed = false,
				show_stop_reason = true,
				commented = false,
				only_first_definition = true,
				all_references = false,
				clear_on_continue = false,
				display_callback = function(variable, _, _, _, options)
					if options.virt_text_pos == "inline" then
						return " = " .. variable.value
					else
						return variable.name .. " = " .. variable.value
					end
				end,
				virt_text_pos = vim.fn.has("nvim-0.10") == 1 and "inline" or "eol",
				all_frames = false,
				virt_lines = false,
				virt_text_win_col = nil,
			})

			if nixCats("python") then
				require("dap-python").setup("python")
			end

			if nixCats("rust") or nixCats("cpp") then
				dap.adapters.lldb = {
					type = "executable",
					command = "lldb-dap",
					name = "lldb",
				}
			end

			if nixCats("rust") then
				dap.configurations.rust = {
					{
						name = "Launch",
						type = "lldb",
						request = "launch",
						program = function()
							return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/target/debug/", "file")
						end,
						cwd = "${workspaceFolder}",
						stopOnEntry = false,
						args = {},
					},
				}
			end

			if nixCats("cpp") then
				dap.configurations.cpp = {
					{
						name = "Launch",
						type = "lldb",
						request = "launch",
						program = function()
							return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/build/", "file")
						end,
						cwd = "${workspaceFolder}",
						stopOnEntry = false,
						args = {},
					},
				}
				dap.configurations.c = dap.configurations.cpp
			end
		end,
	},
	{
		"nvim-dap-python",
		enabled = nixCats("python") or false,
		on_require = { "dap-python" },
	},
	{
		"nvim-dap-ui",
		enabled = nixCats("general") or false,
		on_require = { "dapui" },
	},
	{
		"nvim-dap-virtual-text",
		enabled = nixCats("general") or false,
		on_require = { "nvim-dap-virtual-text" },
	},
	{
		"nvim-dap-go",
		enabled = nixCats("go") or false,
		on_plugin = { "nvim-dap" },
		after = function()
			require("dap-go").setup()
		end,
	},
	{
		"nvim-dap-vscode-js",
		enabled = nixCats("node") or false,
		on_plugin = { "nvim-dap" },
		after = function()
			require("dap-vscode-js").setup({
				adapters = { "pwa-node", "pwa-chrome", "pwa-msedge", "node-terminal", "pwa-extensionHost" },
			})
		end,
	},
}
