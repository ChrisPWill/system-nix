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

			local function get_program_path(default_path)
				local root = vim.fn.getcwd()
				-- Try .debug.json first (custom simple format)
				local debug_json = root .. "/.debug.json"
				if vim.fn.filereadable(debug_json) == 1 then
					local ok, data = pcall(function()
						return vim.json.decode(table.concat(vim.fn.readfile(debug_json), "\n"))
					end)
					if ok and data and data.program then
						return data.program:gsub("${workspaceFolder}", root)
					end
				end

				-- Try .vscode/launch.json (best effort parsing for just the program path)
				local launch_json = root .. "/.vscode/launch.json"
				if vim.fn.filereadable(launch_json) == 1 then
					local ok, data = pcall(function()
						-- Note: vim.json.decode doesn't support comments, which launch.json often has.
						-- But some projects use clean JSON.
						return vim.json.decode(table.concat(vim.fn.readfile(launch_json), "\n"))
					end)
					if ok and data and data.configurations then
						for _, cfg in ipairs(data.configurations) do
							if
								cfg.program and (cfg.type == "lldb" or cfg.type == "cppdbg" or cfg.type == "lldb-dap")
							then
								return cfg.program:gsub("${workspaceFolder}", root)
							end
						end
					end
				end

				return vim.fn.input("Path to executable: ", default_path or (root .. "/"), "file")
			end

			utils.nmap("<F5>", dap.continue, "Debug (Start/Continue)")
			utils.nmap("<F1>", dap.step_into, "Debug (Step Into)")
			utils.nmap("<F2>", dap.step_over, "Debug (Step Over)")
			utils.nmap("<F3>", dap.step_out, "Debug (Step Out)")
			utils.nmap("<leader>cb", dap.toggle_breakpoint, "Breakpoint (Toggle)")
			utils.nmap("<leader>cB", function()
				dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
			end, "Breakpoint (Condition)")

			utils.nmap("<F7>", dapui.toggle, "Debug (Last Result)")

			local help_win = nil
			dap.listeners.after.event_initialized["dapui_config"] = function()
				dapui.open()
				help_win = utils.createHelpFloat("F1: In | F2: Over | F3: Out | F5: Cont")
			end
			dap.listeners.before.event_terminated["dapui_config"] = function()
				if help_win then
					help_win:close()
					help_win = nil
				end
				dapui.close()
			end
			dap.listeners.before.event_exited["dapui_config"] = function()
				if help_win then
					help_win:close()
					help_win = nil
				end
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
							return get_program_path(vim.fn.getcwd() .. "/target/debug/")
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
							return get_program_path(vim.fn.getcwd() .. "/build/")
						end,
						cwd = "${workspaceFolder}",
						stopOnEntry = false,
						args = {},
					},
				}
				dap.configurations.c = dap.configurations.cpp
			end

			-- Support .vscode/launch.json properly
			require("dap.ext.vscode").load_launchjs(nil, { lldb = { "rust", "cpp", "c" } })
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
