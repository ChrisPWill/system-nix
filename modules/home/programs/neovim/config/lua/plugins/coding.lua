local utils = require("utils")

return {
	{
		"nvim-lint",
		enabled = nixCats("general") or false,
		event = { "BufWritePost", "BufReadPost", "InsertLeave" },
		after = function()
			local jslint = { "eslint_d" }
			if utils.isDeno() then
				jslint = { "deno" }
			end
			require("lint").linters.clippy.ignore_exitcode = true
			require("lint").linters_by_ft = {
				-- NOTE: download some linters in lspsAndRuntimeDeps
				-- and configure them here
				-- markdown = {'vale',},
				javascript = nixCats("node") and jslint or nil,
				typescript = nixCats("node") and jslint or nil,
				go = nixCats("go") and { "golangcilint" } or nil,
				rust = nixCats("rust") and { "clippy" } or nil,
				toml = nixCats("rust") and { "tombi" } or nil,
			}

			vim.api.nvim_create_autocmd({ "CursorHold", "BufWritePost", "InsertLeave" }, {
				callback = function()
					require("lint").try_lint()
				end,
			})
		end,
	},
	{
		"conform.nvim",
		enabled = nixCats("general") or false,
		event = { "BufReadPost", "BufWritePre" },
		cmd = { "ConformInfo", "FormatDisable", "FormatEnable" },
		keys = {
			{
				"<leader>cf",
				function()
					require("conform").format({
						lsp_fallback = true,
						async = false,
						timeout_ms = 5000,
					})
				end,
				mode = { "n", "v" },
				desc = "[C]ode [F]ormat",
			},
			{
				"<leader>tf",
				function()
					if vim.g.disable_autoformat or vim.b.disable_autoformat then
						vim.cmd("FormatEnable")
						vim.notify("Autoformat enabled")
					else
						vim.cmd("FormatDisable")
						vim.notify("Autoformat disabled")
					end
				end,
				desc = "Toggle: [F]ormatting",
			},
		},
		after = function()
			local conform = require("conform")

			local jslint = { "treefmt", "eslint_d", "prettierd", stop_after_first = true }
			if utils.isDeno() then
				jslint = { "treefmt", "deno_fmt", stop_after_first = true }
			end
			conform.setup({
				formatters_by_ft = {
					["*"] = function()
						if utils.isTreefmt() then
							return { "treefmt" }
						end
						return {}
					end,
					-- NOTE: download some formatters in lspsAndRuntimeDeps
					-- and configure them here
					lua = nixCats("lua") and { "treefmt", "stylua", stop_after_first = true } or nil,
					go = nixCats("go") and { "treefmt", "gofmt", "golint", stop_after_first = true } or nil,
					-- Use a sub-list to run only the first available formatter
					javascript = nixCats("node") and jslint or nil,
					typescript = nixCats("node") and jslint or nil,
					nix = nixCats("nix") and { "treefmt", "alejandra", stop_after_first = true } or nil,
					rust = nixCats("rust") and { "treefmt", "rustfmt", stop_after_first = true } or nil,
					toml = nixCats("rust") and { "treefmt", "tombi", stop_after_first = true } or nil,
					python = nixCats("python") and { "ruff_organize_imports", lsp_format = "last" } or nil,
					nu = { lsp_format = "last" },
				},
				formatters = {
					tombi = {
						command = "tombi",
						args = { "format", "-" },
						stdin = true,
					},
					deno_fmt = {
						command = "deno",
						args = { "fmt", "-" },
						stdin = true,
					},
					treefmt = {
						command = "treefmt",
						args = { "--stdin", "$FILENAME" },
						stdin = true,
					},
				},
			})

			vim.api.nvim_create_autocmd("BufWritePre", {
				pattern = "*",
				callback = function(args)
					-- Disable with a global or buffer-local variable
					if vim.g.disable_autoformat or vim.b[args.buf].disable_autoformat then
						return
					end
					require("conform").format({
						lsp_fallback = true,
						bufnr = args.buf,
						async = false,
						timeout_ms = 5000,
					})
				end,
			})

			vim.keymap.set("n", "<leader>td", function()
				vim.diagnostic.enable(not vim.diagnostic.is_enabled())
				vim.notify("Diagnostics " .. (vim.diagnostic.is_enabled() and "enabled" or "disabled"))
			end, { desc = "Toggle: [D]iagnostics" })
		end,
	},
	{
		"grug-far.nvim",
		enabled = nixCats("general") or false,
		cmd = { "GrugFar" },
		keys = {
			{
				"<leader>rr",
				function()
					require("grug-far").open({
						transient = true,
					})
				end,
				mode = "n",
				desc = "[R]eplace (Standard)",
			},
			{
				"<leader>rw",
				function()
					require("grug-far").open({
						transient = true,
						prefills = {
							search = vim.fn.expand("<cword>"),
						},
					})
				end,
				mode = "n",
				desc = "[R]eplace [W]ord",
			},
			{
				"<leader>rf",
				function()
					require("grug-far").open({
						transient = true,
						prefills = {
							paths = vim.fn.expand("%"),
						},
					})
				end,
				mode = "n",
				desc = "[R]eplace in [F]ile",
			},
			{
				"<leader>ra",
				function()
					require("grug-far").open({
						transient = true,
						engine = "astgrep",
					})
				end,
				mode = "n",
				desc = "[R]eplace [A]st-grep",
			},
			{
				"<leader>rs",
				function()
					local search = vim.fn.getreg("/")
					-- surround with \b if "word" search (such as when pressing `*`)
					if search and vim.startswith(search, "\\<") and vim.endswith(search, "\\>") then
						search = "\\b" .. search:sub(3, -3) .. "\\b"
					elseif search and vim.startswith(search, "\\V") then
						search = search:sub(3)
					end
					require("grug-far").open({
						transient = true,
						prefills = {
							search = search,
						},
					})
				end,
				mode = "n",
				desc = "[R]eplace from [/] Register",
			},
			{
				"<leader>rv",
				function()
					require("grug-far").with_visual_selection({
						transient = true,
					})
				end,
				mode = "x",
				desc = "[R]eplace [V]isual Selection",
			},
		},
		after = function()
			require("grug-far").setup({
				headerMaxWidth = 80,
				transient = true,
				icons = {
					enabled = true,
				},
			})
		end,
	},
	{
		"inc-rename.nvim",
		enabled = nixCats("general") or false,
		event = "DeferredUIEnter",
		cmd = { "IncRename" },
		after = function()
			require("inc_rename").setup({})
		end,
	},
	{
		"actions-preview.nvim",
		enabled = nixCats("general") or false,
		event = "DeferredUIEnter",
		after = function()
			require("actions-preview").setup({
				-- options for vim.diff(): https://neovim.io/doc/user/lua.html#vim.diff()
				diff = {
					ctxlen = 3,
				},

				-- priority list of external command to highlight diff
				-- disabled by defalt, must be set by yourself
				highlight_command = {
					-- require("actions-preview.highlight").delta(),
					-- require("actions-preview.highlight").diff_so_fancy(),
					-- require("actions-preview.highlight").diff_highlight(),
				},

				-- priority list of preferred backend
				backend = { "snacks", "nui", "minipick" },

				-- options for nui.nvim components
				nui = {
					-- component direction. "col" or "row"
					dir = "col",
					-- keymap for selection component: https://github.com/MunifTanjim/nui.nvim/tree/main/lua/nui/menu#keymap
					keymap = nil,
					-- options for nui Layout component: https://github.com/MunifTanjim/nui.nvim/tree/main/lua/nui/layout
					layout = {
						position = "50%",
						size = {
							width = "60%",
							height = "90%",
						},
						min_width = 40,
						min_height = 10,
						relative = "editor",
					},
					-- options for preview area: https://github.com/MunifTanjim/nui.nvim/tree/main/lua/nui/popup
					preview = {
						size = "60%",
						border = {
							style = "rounded",
							padding = { 0, 1 },
						},
					},
					-- options for selection area: https://github.com/MunifTanjim/nui.nvim/tree/main/lua/nui/menu
					select = {
						size = "40%",
						border = {
							style = "rounded",
							padding = { 0, 1 },
						},
					},
				},

				--- options for snacks picker
				---@type snacks.picker.Config
				snacks = {
					layout = { preset = "default" },
				},
			})
		end,
	},
}
