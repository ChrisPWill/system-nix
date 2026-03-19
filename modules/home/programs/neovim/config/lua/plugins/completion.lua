local utils = require("utils")

return {
	-- Autocompletions https://github.com/saghen/blink.cmp
	{
		"blink.cmp",
		enabled = nixCats("general") or false,
		event = "DeferredUIEnter",
		on_require = "blink",
		load = function(name)
			vim.cmd.packadd(name)
			if nixCats("copilot") then
				vim.cmd.packadd("blink-copilot")
			end
			if nixCats("local-llm") then
				vim.cmd.packadd("minuet-ai.nvim")
			end
			vim.cmd.packadd("luasnip")
		end,
		after = function()
			local defaultSources = { "snippets", "lsp", "path", "buffer" }
			if nixCats("copilot") then
				table.insert(defaultSources, 2, "copilot")
			end
			if nixCats("local-llm") then
				table.insert(defaultSources, 2, "minuet")
			end
			require("blink.cmp").setup({
				-- 'default' (recommended) for mappings similar to built-in completions (C-y to accept)
				-- See :h blink-cmp-config-keymap for configuring keymaps
				keymap = {
					preset = "default",

					["<C-e>"] = { "select_and_accept", "fallback" },
				},
				snippets = { preset = "luasnip" },
				appearance = {
					nerd_font_variant = "mono",
				},
				signature = { enabled = true },
				sources = {
					-- Need to find a better solution to the issue where `enabled` doesn't work as I'd hope
					default = defaultSources,
					providers = {
						snippets = {
							min_keyword_length = 2,
							score_offset = 10,
							opts = {
								-- TODO: Fix this, unexpected path - deprecation?
								-- search_paths = {
								-- 	(nixCats.configDir or "") .. "/snippets",
								-- },
							},
						},
						copilot = nixCats("copilot") and {
							name = "copilot",
							enabled = true,
							module = "blink-copilot",
							score_offset = 100,
							async = true,
						} or nil,
						minuet = {
							name = "minuet",
							enabled = nixCats("local-llm"),
							module = "minuet.blink",
							score_offset = 100, -- Forces LLM suggestions to the top of the menu
							async = true,
						},
					},
				},
			})
		end,
	},
	{
		"luasnip",
		enabled = nixCats("general") or false,
		event = "DeferredUIEnter",
		load = function(name)
			vim.cmd.packadd(name)
			vim.cmd.packadd("friendly-snippets")
		end,
		after = function()
			local function loadSnippets()
				require("luasnip.loaders.from_vscode").lazy_load()
				require("luasnip.loaders.from_vscode").lazy_load({ paths = (nixCats.configDir or "") .. "/snippets" })
				require("luasnip.loaders.from_lua").lazy_load({ paths = (nixCats.configDir or "") .. "/snippets" })
			end
			loadSnippets()
			local ls = require("luasnip")
			vim.keymap.set({ "i", "s" }, "<C-L>", function()
				ls.jump(1)
			end, { silent = true, desc = "Luasnip: Jump forward" })
			vim.keymap.set({ "i", "s" }, "<C-J>", function()
				ls.jump(-1)
			end, { silent = true, desc = "Luasnip: Jump backward" })

			vim.api.nvim_create_user_command("LuaSnipReload", function()
				require("luasnip").cleanup()
				loadSnippets()
			end, {})
		end,
	},
	{
		"nvim-scissors",
		enabled = nixCats("general") or false,
		event = "DeferredUIEnter",
		after = function()
			require("scissors").setup({
				snippetDir = (nixCats.configDir or "") .. "/snippets",
			})

			vim.keymap.set("n", "<leader>xe", function()
				require("scissors").editSnippet()
			end, { desc = "Snippet: Edit" })

			-- when used in visual mode, prefills the selection as snippet body
			vim.keymap.set({ "n", "x" }, "<leader>xa", function()
				require("scissors").addNewSnippet()
			end, { desc = "Snippet: Add" })
		end,
	},
}
