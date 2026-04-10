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
				sh = nixCats("general") and { "shellcheck" } or nil,
				bash = nixCats("general") and { "shellcheck" } or nil,
				zsh = nixCats("general") and { "shellcheck" } or nil,
				cpp = nixCats("cpp") and { "cppcheck" } or nil,
				c = nixCats("cpp") and { "cppcheck" } or nil,
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

			local function get_formatters(list)
				if utils.isTreefmt() then
					return { "treefmt" }
				end
				return list
			end

			local jslint = { "prettierd" }
			if utils.isDeno() then
				jslint = { "deno_fmt" }
			end
			if utils.isEslint() then
				jslint = { "eslint_d" }
			end

			conform.setup({
				formatters_by_ft = {
					["*"] = function()
						if utils.isTreefmt() then
							return { "treefmt" }
						end
						return {}
					end,
					lua = nixCats("lua") and get_formatters({ "stylua" }) or nil,
					go = nixCats("go") and get_formatters({ "gofmt", "golint", stop_after_first = true }) or nil,
					javascript = nixCats("node") and get_formatters(jslint) or nil,
					typescript = nixCats("node") and get_formatters(jslint) or nil,
					nix = nixCats("nix") and get_formatters({ "alejandra" }) or nil,
					rust = nixCats("rust") and get_formatters({ "rustfmt" }) or nil,
					toml = nixCats("general") and get_formatters({ "tombi" }) or nil,
					python = nixCats("python") and { "ruff_organize_imports", lsp_format = "last" } or nil,
					java = nixCats("java") and { "google-java-format" } or nil,
					kotlin = nixCats("kotlin") and { "ktlint" } or nil,
					html = nixCats("web") and get_formatters({ "prettierd" }) or nil,
					css = nixCats("web") and get_formatters({ "prettierd" }) or nil,
					graphql = nixCats("node") and get_formatters({ "prettierd" }) or nil,
					markdown = nixCats("general") and get_formatters({ "prettierd" }) or nil,
					json = nixCats("general") and get_formatters({ "prettierd" }) or nil,
					yaml = nixCats("general") and get_formatters({ "prettierd" }) or nil,
					sh = nixCats("general") and { "shfmt" } or nil,
					bash = nixCats("general") and { "shfmt" } or nil,
					zsh = nixCats("general") and { "shfmt" } or nil,
					fish = nixCats("general") and { "fish_indent" } or nil,
					cpp = nixCats("cpp") and get_formatters({ "clang-format" }) or nil,
					c = nixCats("cpp") and get_formatters({ "clang-format" }) or nil,
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
						cwd = require("conform.util").root_file({ "treefmt.toml", ".treefmt.toml" }),
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

			vim.api.nvim_create_user_command("FormatDisable", function(args)
				if args.bang then
					-- FormatDisable! will disable formatting just for this buffer
					vim.b.disable_autoformat = true
				else
					vim.g.disable_autoformat = true
				end
			end, {
				desc = "Disable autoformat-on-save",
				bang = true,
			})
			vim.api.nvim_create_user_command("FormatEnable", function()
				vim.b.disable_autoformat = false
				vim.g.disable_autoformat = false
			end, {
				desc = "Re-enable autoformat-on-save",
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
