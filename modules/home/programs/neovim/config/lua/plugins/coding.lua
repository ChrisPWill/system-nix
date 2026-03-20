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
				desc = "Format",
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
				desc = "Autoformat",
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
					lua = nixCats("lua") and { "treefmt", "stylua", stop_after_first = true } or nil,
					go = nixCats("go") and { "treefmt", "gofmt", "golint", stop_after_first = true } or nil,
					javascript = nixCats("node") and jslint or nil,
					typescript = nixCats("node") and jslint or nil,
					nix = nixCats("nix") and { "treefmt", "alejandra", stop_after_first = true } or nil,
					rust = nixCats("rust") and { "treefmt", "rustfmt", stop_after_first = true } or nil,
					toml = nixCats("rust") and { "treefmt", "tombi", stop_after_first = true } or nil,
					python = nixCats("python") and { "ruff_organize_imports", lsp_format = "last" } or nil,
					java = nixCats("java") and { "google-java-format" } or nil,
					kotlin = nixCats("kotlin") and { "ktlint" } or nil,
					html = nixCats("web") and { "treefmt", "prettierd", stop_after_first = true } or nil,
					css = nixCats("web") and { "treefmt", "prettierd", stop_after_first = true } or nil,
					graphql = nixCats("node") and { "treefmt", "prettierd", stop_after_first = true } or nil,
					markdown = nixCats("general") and { "treefmt", "prettierd", stop_after_first = true } or nil,
					json = nixCats("general") and { "treefmt", "prettierd", stop_after_first = true } or nil,
					yaml = nixCats("general") and { "treefmt", "prettierd", stop_after_first = true } or nil,
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
			end, { desc = "Diagnostics" })
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
				desc = "Search & Replace",
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
				desc = "Replace Word",
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
				desc = "Replace in File",
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
				desc = "Replace (AST-grep)",
			},
			{
				"<leader>rs",
				function()
					local search = vim.fn.getreg("/")
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
				desc = "Replace (Search Register)",
			},
			{
				"<leader>rv",
				function()
					require("grug-far").with_visual_selection({
						transient = true,
					})
				end,
				mode = "x",
				desc = "Replace Selection",
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
				diff = {
					ctxlen = 3,
				},
				backend = { "snacks", "nui", "minipick" },
				nui = {
					dir = "col",
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
					preview = {
						size = "60%",
						border = {
							style = "rounded",
							padding = { 0, 1 },
						},
					},
					select = {
						size = "40%",
						border = {
							style = "rounded",
							padding = { 0, 1 },
						},
					},
				},
				snacks = {
					layout = { preset = "default" },
				},
			})
		end,
	},
}
