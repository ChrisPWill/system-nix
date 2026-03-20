local utils = require("utils")
local lsp_utils = require("plugins.lsp")

return {
	{
		"nvim-lspconfig",
		enabled = nixCats("general") or false,
		-- the on require handler will be needed here if you want to use the
		-- fallback method of getting filetypes if you don't provide any
		on_require = { "lspconfig" },
		dep_of = { "typescript-tools.nvim" },
		-- define a function to run over all type(plugin.lsp) == table
		-- when their filetype trigger loads them
		lsp = function(plugin)
			vim.lsp.config(plugin.name, plugin.lsp or {})
			vim.lsp.enable(plugin.name)
		end,
		before = function(_)
			vim.lsp.config("*", {
				on_attach = lsp_utils.on_attach,
			})
		end,
	},
	{
		"tombi",
		enabled = nixCats("general") or false,
		lsp = {
			cmd = { "tombi", "lsp" },
			fileTypes = { "toml" },
			root_markers = { "tombi.toml", "pyproject.toml", ".git" },
		},
	},
	{
		"basedpyright",
		enabled = nixCats("python") or false,
		lsp = {
			fileTypes = { "python" },
		},
	},
	{
		"nushell",
		enabled = nixCats("general") or false,
		lsp = {
			fileTypes = { "nu" },
		},
	},
	{
		"ruff",
		enabled = nixCats("python") or false,
		lsp = {
			fileTypes = { "python" },
		},
	},
	{
		-- name of the lsp
		"lua_ls",
		enabled = nixCats("lua") or false,
		-- provide a table containing filetypes,
		-- and then whatever your functions defined in the function type specs expect.
		-- in our case, it just expects the normal lspconfig setup options.
		lsp = {
			-- if you provide the filetypes it doesn't ask lspconfig for the filetypes
			filetypes = { "lua" },
			settings = {
				Lua = {
					runtime = { version = "LuaJIT" },
					formatters = {
						ignoreComments = true,
					},
					signatureHelp = { enabled = true },
					diagnostics = {
						globals = { "nixCats", "vim" },
						disable = { "missing-fields" },
					},
					telemetry = { enabled = false },
				},
			},
		},
		-- also these are regular specs and you can use before and after and all the other normal fields
	},
	{
		"typescript-tools.nvim",
		enabled = function()
			return nixCats("node") and not utils.isDeno()
		end,
		ft = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
		on_require = { "typescript-tools" },
		after = function()
			require("typescript-tools").setup({
				on_attach = function(client, bufnr)
					-- Provided by prettierd and conform
					client.server_capabilities.documentFormattingProvider = false
					client.server_capabilities.documentRangeFormattingProvider = false

					lsp_utils.on_attach(client, bufnr)

					-- Custom TypeScript keymaps
					utils.nmap("<leader>cio", "<cmd>TSToolsOrganizeImports<CR>", "[C]ode [I]mport [O]rganise")
					utils.nmap("<leader>cis", "<cmd>TSToolsSortImports<CR>", "[C]ode [I]mport [S]ort")
					utils.nmap("<leader>cim", "<cmd>TSToolsAddMissingImports<CR>", "[C]ode [I]mport [M]issing")
					utils.nmap("<leader>cxa", "<cmd>TSToolsFixAll<CR>", "[C]ode Fi[x] [A]ll")
					utils.nmap("<leader>cFe", "<cmd>TSToolsRenameFile<CR>", "[C]ode [F]ILE r[E]name")
					utils.nmap("<leader>cFr", "<cmd>TSToolsFileReferences<CR>", "[C]ode [F]ILE [R]eferences")
				end,
				settings = {
					-- possible values: ("off"|"all"|"implementations_only"|"references_only")
					code_lens = "implementations_only",
				},
			})
		end,
	},
	{
		"denols",
		enabled = function()
			return nixCats("node") and utils.isDeno()
		end,
		lsp = {
			filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
			root_markers = { "deno.json", "deno.jsonc" },
		},
	},
	{
		"gopls",
		enabled = nixCats("go") or false,
		-- if you don't provide the filetypes it asks lspconfig for them using the function we set above
		lsp = {
			-- filetypes = { "go", "gomod", "gowork", "gotmpl" },
		},
	},
	{
		"nixd",
		enabled = nixCats("nix") or false,
		lsp = {
			filetypes = { "nix" },
			settings = {
				nixd = {
					-- nixd requires some configuration.
					-- luckily, the nixCats plugin is here to pass whatever we need!
					-- we passed this in via the `extra` table in our packageDefinitions
					-- for additional configuration options, refer to:
					-- https://github.com/nix-community/nixd/blob/main/nixd/docs/configuration.md
					nixpkgs = {
						-- in the extras set of your package definition:
						-- nixdExtras.nixpkgs = ''import ${pkgs.path} {}''
						expr = nixCats.extra("nixdExtras.nixpkgs") or [[import <nixpkgs> {}]],
					},
					options = {
						nixos = {
							-- nixdExtras.nixos_options = ''(builtins.getFlake "path:${builtins.toString inputs.self.outPath}").nixosConfigurations.configname.options''
							expr = nixCats.extra("nixdExtras.nixos_options"),
						},
						["home-manager"] = {
							-- nixdExtras.home_manager_options = ''(builtins.getFlake "path:${builtins.toString inputs.self.outPath}").homeConfigurations.configname.options''
							expr = nixCats.extra("nixdExtras.home_manager_options"),
						},
					},
					formatting = {
						command = { "alejandra" },
					},
					diagnostic = {
						suppress = {
							"sema-escaping-with",
						},
					},
				},
			},
		},
	},
	{
		"html",
		enabled = nixCats("web") or false,
		lsp = {
			filetypes = { "html", "templ" },
		},
	},
	{
		"cssls",
		enabled = nixCats("web") or false,
		lsp = {
			filetypes = { "css", "scss", "less" },
		},
	},
	{
		"graphql",
		enabled = nixCats("node") or false,
		lsp = {
			filetypes = { "graphql", "typescriptreact", "javascriptreact" },
		},
	},
	{
		"marksman",
		enabled = nixCats("general") or false,
		lsp = {
			filetypes = { "markdown", "markdown.mdx" },
		},
	},
	{
		"kotlin_language_server",
		enabled = nixCats("kotlin") or false,
		lsp = {
			filetypes = { "kotlin" },
		},
	},
	{
		"jsonls",
		enabled = nixCats("general") or false,
		lsp = {
			filetypes = { "json", "jsonc" },
		},
	},
	{
		"yamlls",
		enabled = nixCats("general") or false,
		lsp = {
			filetypes = { "yaml", "yaml.dockerfile", "yaml.gitlab" },
			settings = {
				yaml = {
					schemaStore = {
						enable = true,
						url = "https://www.schemastore.org/api/json/catalog.json",
					},
					schemas = {
						["https://json.schemastore.org/github-workflow.json"] = "/.github/workflows/*",
						["https://json.schemastore.org/github-action.json"] = "/.github/actions/*",
					},
				},
			},
		},
	},
	{
		"tailwindcss",
		enabled = nixCats("web") or false,
		lsp = {
			filetypes = { "html", "javascript", "typescript", "javascriptreact", "typescriptreact", "css", "scss", "less" },
		},
	},
	{
		"bashls",
		enabled = nixCats("general") or false,
		lsp = {
			filetypes = { "sh", "bash", "zsh" },
		},
	},
	{
		"fish_lsp",
		enabled = nixCats("general") or false,
		lsp = {
			filetypes = { "fish" },
		},
	},
}
