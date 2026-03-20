local utils = require("utils")

return {
	{
		"nvim-treesitter",
		enabled = nixCats("general") or false,
		event = "DeferredUIEnter",
		dep_of = { "neotest" },
		load = function(name)
			vim.cmd.packadd(name)
			vim.cmd.packadd("nvim-treesitter-textobjects")
			vim.cmd.packadd("nvim-treesitter-context")
		end,
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

			local ts_repeat_move = require("nvim-treesitter-textobjects.repeatable_move")

			-- Repeat movement with } and {
			-- ensure } goes forward and { goes backward regardless of the last direction
			vim.keymap.set({ "n", "x", "o" }, "}", ts_repeat_move.repeat_last_move_next, { desc = "Repeat next move" })
			vim.keymap.set({ "n", "x", "o" }, "{", ts_repeat_move.repeat_last_move_previous, { desc = "Repeat previous move" })

			-- Optionally, make builtin f, F, t, T also repeatable with } and {
			vim.keymap.set({ "n", "x", "o" }, "f", ts_repeat_move.builtin_f_expr, { expr = true })
			vim.keymap.set({ "n", "x", "o" }, "F", ts_repeat_move.builtin_F_expr, { expr = true })
			vim.keymap.set({ "n", "x", "o" }, "t", ts_repeat_move.builtin_t_expr, { expr = true })
			vim.keymap.set({ "n", "x", "o" }, "T", ts_repeat_move.builtin_T_expr, { expr = true })

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

			-- move keymaps (Helix-like)
			vim.keymap.set({ "n", "x", "o" }, "]f", function()
				require("nvim-treesitter-textobjects.move").goto_next_start("@function.outer", "textobjects")
			end, { desc = "Next function start" })
			vim.keymap.set({ "n", "x", "o" }, "[f", function()
				require("nvim-treesitter-textobjects.move").goto_previous_start("@function.outer", "textobjects")
			end, { desc = "Previous function start" })
			vim.keymap.set({ "n", "x", "o" }, "]c", function()
				require("nvim-treesitter-textobjects.move").goto_next_start("@class.outer", "textobjects")
			end, { desc = "Next class start" })
			vim.keymap.set({ "n", "x", "o" }, "[c", function()
				require("nvim-treesitter-textobjects.move").goto_previous_start("@class.outer", "textobjects")
			end, { desc = "Previous class start" })
			vim.keymap.set({ "n", "x", "o" }, "]a", function()
				require("nvim-treesitter-textobjects.move").goto_next_start("@parameter.inner", "textobjects")
			end, { desc = "Next argument start" })
			vim.keymap.set({ "n", "x", "o" }, "[a", function()
				require("nvim-treesitter-textobjects.move").goto_previous_start("@parameter.inner", "textobjects")
			end, { desc = "Previous argument start" })

			-- Additional navigation
			vim.keymap.set({ "n", "x", "o" }, "]l", function()
				require("nvim-treesitter-textobjects.move").goto_next_start("@loop.outer", "textobjects")
			end, { desc = "Next loop start" })
			vim.keymap.set({ "n", "x", "o" }, "[l", function()
				require("nvim-treesitter-textobjects.move").goto_previous_start("@loop.outer", "textobjects")
			end, { desc = "Previous loop start" })
			vim.keymap.set({ "n", "x", "o" }, "]i", function()
				require("nvim-treesitter-textobjects.move").goto_next_start("@conditional.outer", "textobjects")
			end, { desc = "Next conditional start" })
			vim.keymap.set({ "n", "x", "o" }, "[i", function()
				require("nvim-treesitter-textobjects.move").goto_previous_start("@conditional.outer", "textobjects")
			end, { desc = "Previous conditional start" })

			-- End of object moves
			vim.keymap.set({ "n", "x", "o" }, "]F", function()
				require("nvim-treesitter-textobjects.move").goto_next_end("@function.outer", "textobjects")
			end, { desc = "Next function end" })
			vim.keymap.set({ "n", "x", "o" }, "[F", function()
				require("nvim-treesitter-textobjects.move").goto_previous_end("@function.outer", "textobjects")
			end, { desc = "Previous function end" })
			vim.keymap.set({ "n", "x", "o" }, "]C", function()
				require("nvim-treesitter-textobjects.move").goto_next_end("@class.outer", "textobjects")
			end, { desc = "Next class end" })
			vim.keymap.set({ "n", "x", "o" }, "[C", function()
				require("nvim-treesitter-textobjects.move").goto_previous_end("@class.outer", "textobjects")
			end, { desc = "Previous class end" })

			require("treesitter-context").setup({})
			-- Folding
			vim.o.foldmethod = "expr"
			vim.o.foldexpr = "v:lua.vim.treesitter.foldexpr()"
			vim.opt.foldenable = false
		end,
	},
	{
		"treewalker.nvim",
		enabled = nixCats("general") or false,
		event = "DeferredUIEnter",
		after = function()
			require("treewalker").setup({})

			-- Movement
			utils.nmap("<A-h>", "<cmd>Treewalker Left<cr>", "Treewalker: Go Left", { silent = true })
			utils.nmap("<A-j>", "<cmd>Treewalker Down<cr>", "Treewalker: Go Down", { silent = true })
			utils.nmap("<A-k>", "<cmd>Treewalker Up<cr>", "Treewalker: Go Up", { silent = true })
			utils.nmap("<A-l>", "<cmd>Treewalker Right<cr>", "Treewalker: Go Right", { silent = true })

			-- Swapping
			utils.nmap("<A-S-h>", "<cmd>Treewalker SwapLeft<cr>", "Treewalker: Swap Left", { silent = true })
			utils.nmap("<A-S-j>", "<cmd>Treewalker SwapDown<cr>", "Treewalker: Swap Down", { silent = true })
			utils.nmap("<A-S-k>", "<cmd>Treewalker SwapUp<cr>", "Treewalker: Swap Up", { silent = true })
			utils.nmap("<A-S-l>", "<cmd>Treewalker SwapRight<cr>", "Treewalker: Swap Right", { silent = true })
		end,
	},
}
