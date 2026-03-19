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
}
