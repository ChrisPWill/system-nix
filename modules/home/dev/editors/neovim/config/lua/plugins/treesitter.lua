local utils = require("utils")

return {
	{
		"nvim-treesitter",
		enabled = nixCats("general") or false,
		event = "DeferredUIEnter",
		dep_of = { "neotest" },
		after = function()
			-- [[ Configure Treesitter ]]
			-- See `:help nvim-treesitter`
			local languages = {}
			utils.insertIfTrue(languages, nixCats("python"), "python")
			utils.insertIfTrue(languages, nixCats("rust"), "rust")
			utils.insertIfTrue(languages, nixCats("lua"), "lua")
			utils.insertIfTrue(languages, nixCats("nix"), "nix")
			utils.insertIfTrue(languages, nixCats("node"), "typescript")
			utils.insertIfTrue(languages, nixCats("node"), "javascript")
			utils.insertIfTrue(languages, nixCats("node"), "tsx")
			utils.insertIfTrue(languages, nixCats("node"), "graphql")
			utils.insertIfTrue(languages, nixCats("go"), "go")
			utils.insertIfTrue(languages, nixCats("java"), "java")
			utils.insertIfTrue(languages, nixCats("kotlin"), "kotlin")
			utils.insertIfTrue(languages, nixCats("web"), "html")
			utils.insertIfTrue(languages, nixCats("web"), "css")
			utils.insertIfTrue(languages, nixCats("general"), "json")
			utils.insertIfTrue(languages, nixCats("general"), "yaml")
			utils.insertIfTrue(languages, nixCats("general"), "bash")
			utils.insertIfTrue(languages, nixCats("general"), "fish")
			utils.insertIfTrue(languages, nixCats("general"), "kdl")
			utils.insertIfTrue(languages, nixCats("general"), "dockerfile")
			utils.insertIfTrue(languages, nixCats("general"), "just")
			utils.insertIfTrue(languages, nixCats("general"), "markdown")
			utils.insertIfTrue(languages, nixCats("general"), "markdown_inline")
			utils.insertIfTrue(languages, nixCats("general"), "sql")
			utils.insertIfTrue(languages, nixCats("general"), "toml")
			require("nvim-treesitter").install(languages)
			require("nvim-treesitter-textobjects").setup({
				select = {
					lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
				},
				move = {
					set_jumps = true, -- whether to set jumps in the jumplist
				},
			})

			-- select keymaps (Helix-like)
			vim.keymap.set({ "x", "o" }, "af", function()
				require("nvim-treesitter-textobjects.select").select_textobject("@function.outer", "textobjects")
			end, { desc = "Select outer function" })
			vim.keymap.set({ "x", "o" }, "if", function()
				require("nvim-treesitter-textobjects.select").select_textobject("@function.inner", "textobjects")
			end, { desc = "Select inner function" })
			vim.keymap.set({ "x", "o" }, "ac", function()
				require("nvim-treesitter-textobjects.select").select_textobject("@class.outer", "textobjects")
			end, { desc = "Select outer class" })
			vim.keymap.set({ "x", "o" }, "ic", function()
				require("nvim-treesitter-textobjects.select").select_textobject("@class.inner", "textobjects")
			end, { desc = "Select inner class" })
			vim.keymap.set({ "x", "o" }, "aa", function()
				require("nvim-treesitter-textobjects.select").select_textobject("@parameter.outer", "textobjects")
			end, { desc = "Select outer argument" })
			vim.keymap.set({ "x", "o" }, "ia", function()
				require("nvim-treesitter-textobjects.select").select_textobject("@parameter.inner", "textobjects")
			end, { desc = "Select inner argument" })

			-- swap keymaps (Ergonomic: Shift version of navigation)
			vim.keymap.set("n", "]A", function()
				require("nvim-treesitter-textobjects.swap").swap_next("@parameter.inner")
			end, { desc = "Swap next argument" })
			vim.keymap.set("n", "[A", function()
				require("nvim-treesitter-textobjects.swap").swap_previous("@parameter.inner")
			end, { desc = "Swap previous argument" })

			local bracket_repeat = require("utils.bracket-repeat")
			local structural_moves = {
				{ key = "f", query = "@function.outer", edge = "start", label = "function" },
				{ key = "c", query = "@class.outer", edge = "start", label = "class" },
				{ key = "a", query = "@parameter.inner", edge = "start", label = "argument" },
				{ key = "l", query = "@loop.outer", edge = "start", label = "loop" },
				{ key = "i", query = "@conditional.outer", edge = "start", label = "conditional" },
				{ key = "F", query = "@function.outer", edge = "end", label = "function" },
				{ key = "C", query = "@class.outer", edge = "end", label = "class" },
			}

			for _, move in ipairs(structural_moves) do
				local next_method = move.edge == "start" and "goto_next_start" or "goto_next_end"
				local previous_method = move.edge == "start" and "goto_previous_start" or "goto_previous_end"
				bracket_repeat.map_pair(
					{ "n", "x", "o" },
					"]" .. move.key,
					"[" .. move.key,
					function()
						require("nvim-treesitter-textobjects.move")[next_method](move.query, "textobjects")
					end,
					function()
						require("nvim-treesitter-textobjects.move")[previous_method](move.query, "textobjects")
					end,
					{
						next_desc = "Next " .. move.label .. " " .. move.edge,
						previous_desc = "Previous " .. move.label .. " " .. move.edge,
					}
				)
			end

			-- Native incremental selection (Neovim 0.12+)
			-- Mimicing helix
			-- Expand selection
			vim.keymap.set("x", "<A-o>", "an", { remap = true, desc = "Incremental Selection (Expand)" })
			vim.keymap.set("n", "<A-o>", "van", { remap = true, desc = "Incremental Selection (Expand)" })
			-- Shrink selection
			vim.keymap.set("x", "<A-i>", "in", { remap = true, desc = "Incremental Selection (Shrink)" })
			vim.keymap.set("n", "<A-i>", "vin", { remap = true, desc = "Incremental Selection (Shrink)" })

			require("treesitter-context").setup({})
			vim.api.nvim_create_autocmd("FileType", {
				pattern = "*",
				callback = function()
					-- Skip treesitter indentation for Kotlin as it is currently buggy
					-- and often results in newlines starting at the left margin.
					if vim.bo.buftype ~= "" or vim.bo.filetype == "kotlin" then
						return
					end
					local ok, _ = pcall(vim.treesitter.get_parser, 0)
					if ok then
						vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
					end
				end,
			})
			-- Folding options live in global-options so every window gets them;
			-- windows opened before this point only hold fold levels from before
			-- treesitter was available, so re-evaluate them all once it is.
			vim.schedule(function()
				for _, win in ipairs(vim.api.nvim_list_wins()) do
					pcall(vim.api.nvim_win_call, win, function()
						vim.cmd("normal! zx")
					end)
				end
			end)
		end,
	},
	{
		"nvim-treesitter-textobjects",
		enabled = nixCats("general") or false,
		on_require = { "nvim-treesitter-textobjects" },
	},
	{
		"nvim-treesitter-context",
		enabled = nixCats("general") or false,
		on_require = { "treesitter-context" },
	},
	{
		"treewalker.nvim",
		enabled = nixCats("general") or false,
		event = "DeferredUIEnter",
		after = function()
			require("treewalker").setup({})

			-- Movement
			vim.keymap.set(
				{ "n", "v" },
				"<A-h>",
				"<cmd>Treewalker Left<cr>",
				{ desc = "Treewalker: Go Left", silent = true }
			)
			vim.keymap.set(
				{ "n", "v" },
				"<A-j>",
				"<cmd>Treewalker Down<cr>",
				{ desc = "Treewalker: Go Down", silent = true }
			)
			vim.keymap.set(
				{ "n", "v" },
				"<A-k>",
				"<cmd>Treewalker Up<cr>",
				{ desc = "Treewalker: Go Up", silent = true }
			)
			vim.keymap.set(
				{ "n", "v" },
				"<A-l>",
				"<cmd>Treewalker Right<cr>",
				{ desc = "Treewalker: Go Right", silent = true }
			)

			-- Swapping
			vim.keymap.set(
				{ "n", "v" },
				"<A-S-h>",
				"<cmd>Treewalker SwapLeft<cr>",
				{ desc = "Treewalker: Swap Left", silent = true }
			)
			vim.keymap.set(
				{ "n", "v" },
				"<A-S-j>",
				"<cmd>Treewalker SwapDown<cr>",
				{ desc = "Treewalker: Swap Down", silent = true }
			)
			vim.keymap.set(
				{ "n", "v" },
				"<A-S-k>",
				"<cmd>Treewalker SwapUp<cr>",
				{ desc = "Treewalker: Swap Up", silent = true }
			)
			vim.keymap.set(
				{ "n", "v" },
				"<A-S-l>",
				"<cmd>Treewalker SwapRight<cr>",
				{ desc = "Treewalker: Swap Right", silent = true }
			)
		end,
	},
}
