local utils = require("utils")
local lsp_utils = require("plugins.lsp")

vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(ev)
		local client = vim.lsp.get_client_by_id(ev.data.client_id)
		lsp_utils.on_attach(client, ev.buf)
	end,
})

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
	},
	{
		"tombi",
		enabled = function()
			return utils.hasExecutable("tombi")
		end,
		lsp = {
			cmd = { "tombi", "lsp" },
			fileTypes = { "toml" },
			root_markers = { "tombi.toml", "pyproject.toml", ".git" },
		},
	},
	{
		"basedpyright",
		enabled = function()
			return utils.hasExecutable("basedpyright-langserver")
		end,
		lsp = {
			fileTypes = { "python" },
		},
	},
	{
		"nushell",
		enabled = function()
			return utils.hasExecutable("nu")
		end,
		lsp = {
			fileTypes = { "nu" },
		},
	},
	{
		"ruff",
		enabled = function()
			return utils.hasExecutable("ruff")
		end,
		lsp = {
			fileTypes = { "python" },
		},
	},
	{
		-- name of the lsp
		"lua_ls",
		enabled = function()
			return utils.hasExecutable("lua-language-server")
		end,
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
			return utils.hasExecutable("tsserver") and not utils.isDeno()
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
					local keymaps = {
						{
							"<leader>cio",
							"<cmd>TSToolsOrganizeImports<CR>",
							"[C]ode [I]mport [O]rganise",
						},
						{ "<leader>cis", "<cmd>TSToolsSortImports<CR>", "[C]ode [I]mport [S]ort" },
						{
							"<leader>cim",
							"<cmd>TSToolsAddMissingImports<CR>",
							"[C]ode [I]mport [M]issing",
						},
						{ "<leader>cxa", "<cmd>TSToolsFixAll<CR>", "[C]ode Fi[x] [A]ll" },
						{ "<leader>cFe", "<cmd>TSToolsRenameFile<CR>", "[C]ode [F]ILE r[E]name" },
						{
							"<leader>cFr",
							"<cmd>TSToolsFileReferences<CR>",
							"[C]ode [F]ILE [R]eferences",
						},
					}
					local which_key_specs = {}
					for _, keymap in ipairs(keymaps) do
						utils.nmap(keymap[1], keymap[2], keymap[3], { buffer = bufnr })
						table.insert(which_key_specs, { keymap[1], desc = keymap[3] })
					end

					if not vim.b[bufnr].typescript_which_key_registered then
						local registered = utils.registerWhichKey(which_key_specs, bufnr)
						vim.b[bufnr].typescript_which_key_registered = registered
					end
				end,
				settings = {
					-- possible values: ("off"|"all"|"implementations_only"|"references_only")
					-- Disabled because it caused cursor to jump around
					code_lens = "off",
				},
			})
		end,
	},
	{
		"denols",
		enabled = function()
			return utils.hasExecutable("deno") and utils.isDeno()
		end,
		lsp = {
			filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
			root_markers = { "deno.json", "deno.jsonc" },
		},
	},
	{
		"gopls",
		enabled = function()
			return utils.hasExecutable("gopls")
		end,
		-- if you don't provide the filetypes it asks lspconfig for them using the function we set above
		lsp = {
			-- filetypes = { "go", "gomod", "gowork", "gotmpl" },
		},
	},
	{
		"nixd",
		enabled = function()
			return utils.hasExecutable("nixd")
		end,
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
		enabled = function()
			return utils.hasExecutable("vscode-html-language-server")
		end,
		lsp = {
			filetypes = { "html", "templ" },
		},
	},
	{
		"cssls",
		enabled = function()
			return utils.hasExecutable("vscode-css-language-server")
		end,
		lsp = {
			filetypes = { "css", "scss", "less" },
		},
	},
	{
		"graphql",
		enabled = function()
			return utils.hasExecutable("graphql-lsp")
		end,
		lsp = {
			filetypes = { "graphql", "typescriptreact", "javascriptreact" },
		},
	},
	{
		"marksman",
		enabled = function()
			return utils.hasExecutable("marksman")
		end,
		lsp = {
			filetypes = { "markdown", "markdown.mdx" },
		},
	},
	{
		"kotlin_lsp",
		enabled = function()
			return utils.hasExecutable("kotlin-lsp")
		end,
		lsp = {
			cmd = { "kotlin-lsp", "--stdio" },
			filetypes = { "kotlin" },
			root_markers = {
				"settings.gradle",
				"settings.gradle.kts",
				"build.gradle",
				"build.gradle.kts",
				"pom.xml",
				".git",
			},
			workspace_required = true,
		},
	},
	{
		"jdtls",
		enabled = function()
			return utils.hasExecutable("jdtls")
		end,
		lsp = {
			filetypes = { "java" },
			root_markers = {
				"settings.gradle",
				"settings.gradle.kts",
				"build.gradle",
				"build.gradle.kts",
				"pom.xml",
				".git",
			},
		},
	},
	{
		"jsonls",
		enabled = function()
			return utils.hasExecutable("vscode-json-language-server")
		end,
		lsp = {
			filetypes = { "json", "jsonc" },
		},
	},
	{
		"yamlls",
		enabled = function()
			return utils.hasExecutable("yaml-language-server")
		end,
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
		enabled = function()
			return utils.hasExecutable("tailwindcss-language-server")
		end,
		lsp = {
			filetypes = {
				"html",
				"javascript",
				"typescript",
				"javascriptreact",
				"typescriptreact",
				"css",
				"scss",
				"less",
			},
		},
	},
	{
		"bashls",
		enabled = function()
			return utils.hasExecutable("bash-language-server")
		end,
		lsp = {
			filetypes = { "sh", "bash", "zsh" },
		},
	},
	{
		"fish_lsp",
		enabled = function()
			return utils.hasExecutable("fish-lsp")
		end,
		lsp = {
			filetypes = { "fish" },
		},
	},
	{
		"clangd",
		enabled = function()
			return utils.hasExecutable("clangd")
		end,
		lsp = {
			filetypes = { "c", "cpp", "h", "hpp", "objc", "objcpp", "cuda", "proto" },
		},
	},
}
