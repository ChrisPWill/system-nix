local utils = require("utils")

return {
	{
		"nvim-lint",
		enabled = nixCats("general") or false,
		event = { "BufWritePost", "BufReadPost", "InsertLeave" },
		after = function()
			local function available(commands)
				return vim.tbl_filter(utils.hasExecutable, commands)
			end

			local jslint = available({ "eslint_d" })
			if utils.isDeno() and utils.hasExecutable("deno") then
				jslint = { "deno" }
			end
			require("lint").linters.clippy.ignore_exitcode = true
			require("lint").linters_by_ft = {
				javascript = jslint,
				typescript = jslint,
				go = available({ "golangci-lint" }),
				nix = available({ "statix", "deadnix" }),
				rust = utils.hasExecutable("cargo-clippy") and { "clippy" } or {},
				toml = available({ "tombi" }),
				sh = available({ "shellcheck" }),
				bash = available({ "shellcheck" }),
				zsh = available({ "shellcheck" }),
				cpp = available({ "cppcheck" }),
				c = available({ "cppcheck" }),
			}

			-- Note - general compiler warnings should cover the majority of these
			if utils.hasExecutable("cppcheck") then
				table.insert(require("lint").linters.cppcheck.args, "--suppress=unusedStructMember")
			end

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
				-- Previously was adding treefmt here. Keeping for now incase another general formatter needs to be added.
				return list
			end

			local function formatter(command, spec)
				return utils.hasExecutable(command) and spec or nil
			end

			local jslint = formatter("prettierd", { "prettierd" })
			if utils.isDeno() and utils.hasExecutable("deno") then
				jslint = { "deno_fmt" }
			elseif utils.isEslint() and utils.hasExecutable("eslint_d") then
				jslint = { "eslint_d" }
			end

			conform.setup({
				formatters_by_ft = {
					lua = formatter("stylua", get_formatters({ "stylua" })),
					go = formatter("gofmt", get_formatters({ "gofmt" })),
					javascript = jslint and get_formatters(jslint) or nil,
					typescript = jslint and get_formatters(jslint) or nil,
					nix = formatter("alejandra", get_formatters({ "alejandra" })),
					rust = formatter("rustfmt", get_formatters({ "rustfmt" })),
					toml = formatter("tombi", get_formatters({ "tombi" })),
					python = formatter("ruff", { "ruff_organize_imports", lsp_format = "last" }),
					java = formatter("google-java-format", { "google-java-format" }),
					kotlin = formatter("kotlin-lsp", { lsp_format = "only" }),
					html = formatter("prettierd", get_formatters({ "prettierd" })),
					css = formatter("prettierd", get_formatters({ "prettierd" })),
					graphql = formatter("prettierd", get_formatters({ "prettierd" })),
					markdown = formatter("prettierd", get_formatters({ "prettierd" })),
					json = formatter("prettierd", get_formatters({ "prettierd" })),
					yaml = formatter("prettierd", get_formatters({ "prettierd" })),
					sh = formatter("shfmt", { "shfmt" }),
					bash = formatter("shfmt", { "shfmt" }),
					zsh = formatter("shfmt", { "shfmt" }),
					fish = formatter("fish_indent", { "fish_indent" }),
					cpp = formatter("clang-format", get_formatters({ "clang-format" })),
					c = formatter("clang-format", get_formatters({ "clang-format" })),
					nu = formatter("nu", { lsp_format = "last" }),
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
						async = true,
						timeout_ms = 8000,
						undojoin = true,
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
