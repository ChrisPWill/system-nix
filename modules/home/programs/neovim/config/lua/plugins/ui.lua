local utils = require("utils")

return {
	-- https://github.com/nvim-lualine/lualine.nvim
	-- Fast statusline
	{
		"lualine.nvim",
		enabled = nixCats("general") or false,
		event = "DeferredUIEnter",
		load = function(name)
			vim.cmd.packadd(name)
			vim.cmd.packadd("lualine-lsp-progress")
		end,
		after = function()
			require("lualine").setup({
				options = {
					icons_enabled = false,
					theme = "onedark",
					component_separators = "|",
					section_separators = "",
				},
				sections = {
					lualine_c = {
						{
							"filename",
							path = 1,
							status = true,
						},
					},
				},
				inactive_sections = {
					lualine_b = {
						{
							"filename",
							path = 3,
							status = true,
						},
					},
					lualine_x = { "filetype" },
				},
				tabline = {
					lualine_a = { "buffers" },
					lualine_b = { "copilot", "lsp_progress" },
					lualine_z = { "tabs" },
				},
			})
		end,
	},
	{
		"which-key.nvim",
		enabled = nixCats("general") or false,
		event = "DeferredUIEnter",
		after = function()
			require("which-key").setup({})
			require("which-key").add({
				{ "<leader><leader>", group = "Buffer Commands" },
				{ "<leader><leader>_", hidden = true },
				{ "<leader>/", group = "Search / Pick" },
				{ "<leader>/_", hidden = true },
				{ "<leader>A", group = "AI (Avante)" },
				{ "<leader>A_", hidden = true },
				{ "<leader>c", group = "Code" },
				{ "<leader>c_", hidden = true },
				{ "<leader>g", group = "Git" },
				{ "<leader>g_", hidden = true },
				{ "<leader>k", group = "Knowledge / Snippets" },
				{ "<leader>k_", hidden = true },
				{ "<leader>ka", desc = "Snippet: Add" },
				{ "<leader>kc", desc = "Knowledge: Cheat-sheet" },
				{ "<leader>km", desc = "Knowledge: Keymaps Guide" },
				{ "<leader>kr", desc = "Knowledge: Neovim Quickref" },
				{ "<leader>ks", desc = "Snippet: Search / Edit" },
				{ "<leader>r", group = "Refactor / Replace" },
				{ "<leader>r_", hidden = true },
				{ "<leader>rn", desc = "Refactor: Rename Symbol" },
				{ "<leader>t", group = "Toggles" },
				{ "<leader>t_", hidden = true },
				{ "<leader>w", group = "Window Management" },
				{ "<leader>w_", hidden = true },
				{ "<leader>W", group = "Workspace" },
				{ "<leader>W_", hidden = true },
				{ "g", group = "Goto" },
				{ "m", group = "Match / Surround" },
				{ "ms", desc = "Add surround (Visual: selection, Normal: motion)" },
				{ "md", desc = "Delete surround" },
				{ "mr", desc = "Replace surround" },
				{ "mf", desc = "Find surround" },
				{ "mh", desc = "Highlight surround" },
				{ "mn", desc = "Update n lines for surround" },
				{ "mm", desc = "Match bracket" },
			})
		end,
	},
	{
		"noice.nvim",
		enabled = nixCats("general") or false,
		event = "DeferredUIEnter",
		keys = {
			{ "<leader>un", function() require("noice").cmd("dismiss") end, desc = "Dismiss all Notifications" },
		},
		after = function()
			require("notify").setup({
				background_colour = "#000000",
			})
			require("noice").setup({
				lsp = {
					-- override markdown rendering so that **cmp** and other plugins use **Treesitter**
					override = {
						["vim.lsp.util.convert_input_to_markdown_lines"] = true,
						["vim.lsp.util.set_dot_indent"] = true,
						["nvim.lsp.util.stylize_markdown"] = true,
					},
				},
				-- you can enable a preset for easier configuration
				presets = {
					bottom_search = true, -- use a classic bottom cmdline for search
					command_palette = true, -- position the cmdline and popupmenu together
					long_message_to_split = true, -- long messages will be sent to a split
					inc_rename = true, -- enables an input dialog for inc-rename.nvim
					lsp_doc_border = false, -- add a border to hover docs and signature help
				},
			})
		end,
	},
	{
		"trouble.nvim",
		enabled = nixCats("general") or false,
		cmd = "Trouble",
		keys = {
			{ "<leader>tx", "<cmd>Trouble diagnostics toggle<cr>", desc = "Toggle: Trouble [X] (Diagnostics)" },
			{ "<leader>tX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Toggle: Trouble [X] (Buffer)" },
			{ "<leader>ts", "<cmd>Trouble symbols toggle focus=false<cr>", desc = "Toggle: Trouble [S]ymbols" },
			{ "<leader>tl", "<cmd>Trouble lsp toggle focus=false win.position=right<cr>", desc = "Toggle: Trouble [L]SP" },
			{ "<leader>tq", "<cmd>Trouble qflist toggle<cr>", desc = "Toggle: Trouble [Q]uickfix" },
			{ "<leader>tL", "<cmd>Trouble loclist toggle<cr>", desc = "Toggle: Trouble [L]oclist" },
		},
		after = function()
			require("trouble").setup({})
		end,
	},
	{
		"mini.nvim",
		enabled = nixCats("general") or false,
		event = "DeferredUIEnter",
		after = function()
			require("mini.pairs").setup()
			require("mini.icons").setup()
			require("mini.ai").setup()
			require("mini.surround").setup({
				mappings = {
					add = "ms", -- Match surround
					delete = "md", -- Match delete
					find = "mf", -- Match find
					highlight = "mh", -- Match highlight
					replace = "mr", -- Match replace
					update_n_lines = "mn", -- Match n lines
				},
			})
			require("mini.align").setup({
				mappings = {
					start = "&",
					start_with_preview = "g&",
				},
			})
		end,
	},
	{
		"markview.nvim",
		enabled = nixCats("general") or false,
		ft = "markdown",
		after = function()
			utils.nmap("<leader>tm", "<cmd>Markview toggle<cr>", "Toggle: [M]arkview")
		end,
	},
	{
		"vim-startuptime",
		enabled = nixCats("general") or false,
		cmd = { "StartupTime" },
		before = function(_)
			vim.g.startuptime_event_width = 0
			vim.g.startuptime_tries = 10
			vim.g.startuptime_exe_path = nixCats.packageBinPath
		end,
	},
}
