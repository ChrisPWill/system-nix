local utils = require("utils")

return {
	-- Autocompletions https://github.com/saghen/blink.cmp
	{
		"blink.compat",
		on_require = { "blink.compat", "blink.compat.source" },
	},
	{
		"blink.cmp",
		enabled = nixCats("general") or false,
		event = "DeferredUIEnter",
		on_require = { "blink", "blink.cmp" },
		after = function()
			vim.cmd.packadd("luasnip")
			local defaultSources = { "snippets", "lsp", "path", "buffer" }
			if nixCats("copilot") then
				table.insert(defaultSources, 2, "copilot")
			end
			if nixCats("local-llm") or nixCats("gemini") then
				table.insert(defaultSources, 2, "minuet")
			end
			if nixCats("gemini") then
				table.insert(defaultSources, 3, "avante_commands")
				table.insert(defaultSources, 4, "avante_mentions")
				table.insert(defaultSources, 5, "avante_shortcuts")
				table.insert(defaultSources, 6, "avante_files")
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
							score_offset = 5,
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
							enabled = nixCats("local-llm") or nixCats("gemini"),
							module = "minuet.blink",
							score_offset = 100, -- Forces LLM suggestions to the top of the menu
							async = true,
						},
						avante_commands = {
							name = "avante_commands",
							module = "blink.compat.source",
							score_offset = 90, -- show at a higher priority than lsp
							opts = {},
						},
						avante_files = {
							name = "avante_files",
							module = "blink.compat.source",
							score_offset = 100, -- show at a higher priority than lsp
							opts = {},
						},
						avante_mentions = {
							name = "avante_mentions",
							module = "blink.compat.source",
							score_offset = 1000, -- show at a higher priority than lsp
							opts = {},
						},
						avante_shortcuts = {
							name = "avante_shortcuts",
							module = "blink.compat.source",
							score_offset = 1000, -- show at a higher priority than lsp
							opts = {},
						},
					},
				},
			})
		end,
	},
	{
		"blink-copilot",
		enabled = nixCats("copilot") or false,
		on_require = { "blink-copilot" },
	},
	{
		"luasnip",
		enabled = nixCats("general") or false,
		event = "DeferredUIEnter",
		after = function()
			vim.cmd.packadd("friendly-snippets")
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

			-- Help float for snippet navigation
			local help_win = nil
			local function update_snippet_help()
				local in_snippet = ls.in_snippet()
				local mode = vim.api.nvim_get_mode().mode
				-- Mode 'i' is insert, 's' is select
				local in_edit_mode = (mode == "i" or mode == "s")

				if in_snippet and in_edit_mode and not help_win then
					help_win = utils.createHelpFloat("Snippet: Ctrl-L -> | Ctrl-J <-")
				elseif (not in_snippet or not in_edit_mode) and help_win then
					help_win:close()
					help_win = nil
				end
			end

			vim.api.nvim_create_autocmd({ "User", "InsertEnter", "InsertLeave" }, {
				pattern = { "LuasnipInsertNodeEnter", "LuasnipInsertNodeLeave", "*" },
				callback = function()
					vim.schedule(update_snippet_help)
				end,
			})

			vim.api.nvim_create_user_command("LuaSnipReload", function()
				require("luasnip").cleanup()
				loadSnippets()
			end, {})

			-- Snippet Search (Global: includes friendly-snippets)
			vim.keymap.set("n", "<leader>ks", function()
				local ls = require("luasnip")
				local ft = vim.bo.filetype
				local items = {}

				local function add_to_items(snip_list, group)
					for _, snip in ipairs(snip_list) do
						local description = snip.description and snip.description[1] or ""
						table.insert(items, {
							-- Searchable text includes trigger, description, and group
							text = string.format("%s %s %s", snip.trigger, description, group),
							trigger = snip.trigger,
							desc = description,
							group = group,
							snippet = snip,
						})
					end
				end

				add_to_items(ls.get_snippets(ft), ft)
				add_to_items(ls.get_snippets("all"), "global")

				require("snacks").picker.pick({
					items = items,
					title = "Snippets (" .. ft .. ")",
					format = function(item)
						return {
							{ item.trigger, "SnacksPickerLabel" },
							{ " " },
							{ item.desc, "SnacksPickerComment" },
							{ " [" .. item.group .. "]", "SnacksPickerDir" },
						}
					end,
					confirm = function(picker, item)
						picker:close()
						if item then
							ls.snip_expand(item.snippet)
						end
					end,
				})
			end, { desc = "Snippet: Search / All" })
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

			vim.keymap.set("n", "<leader>ke", function()
				require("scissors").editSnippet()
			end, { desc = "Snippet: Edit (Custom)" })

			-- when used in visual mode, prefills the selection as snippet body
			vim.keymap.set({ "n", "x" }, "<leader>ka", function()
				require("scissors").addNewSnippet()
			end, { desc = "Snippet: Add" })
		end,
	},
}
