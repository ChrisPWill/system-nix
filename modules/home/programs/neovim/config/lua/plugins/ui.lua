local utils = require("utils")

return {
	-- https://github.com/nvim-lualine/lualine.nvim
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
				{ "<leader>A", group = "AI" },
				{ "<leader>A_", hidden = true },
				{ "<leader>c", group = "Code" },
				{ "<leader>c_", hidden = true },
				{ "<leader>g", group = "Git" },
				{ "<leader>g_", hidden = true },
				{ "<leader>k", group = "Knowledge / Snippets" },
				{ "<leader>k_", hidden = true },
				{ "<leader>ka", desc = "Snippet (Add)" },
				{ "<leader>kc", desc = "Cheat-sheet" },
				{ "<leader>km", desc = "Keymaps Guide" },
				{ "<leader>kr", desc = "Neovim Quickref" },
				{ "<leader>ks", desc = "Snippet (Search/Edit)" },
				{ "<leader>r", group = "Refactor / Replace" },
				{ "<leader>r_", hidden = true },
				{ "<leader>rn", desc = "Rename" },
				{ "<leader>t", group = "Toggles" },
				{ "<leader>t_", hidden = true },
				{ "<leader>w", group = "Window Management" },
				{ "<leader>w_", hidden = true },
				{ "<leader>W", group = "Workspace" },
				{ "<leader>W_", hidden = true },
				{ "g", group = "Goto" },
				{ "m", group = "Match / Surround / Align" },
				{ "ms", desc = "Add Surround" },
				{ "md", desc = "Delete Surround" },
				{ "mr", desc = "Replace Surround" },
				{ "mf", desc = "Find Surround" },
				{ "mh", desc = "Highlight Surround" },
				{ "mn", desc = "Surround (Update n lines)" },
				{ "mm", desc = "Match bracket" },
				{ "ma", desc = "Align (Regex)" },
				{ "mA", desc = "Align (Interactive)" },
				{ "<leader>[", group = "Prev" },
				{ "<leader>[t", desc = "Prev Tab" },
				{ "<leader>]", group = "Next" },
				{ "<leader>]t", desc = "Next Tab" },
			})
		end,
	},
	{
		"noice.nvim",
		enabled = nixCats("general") or false,
		event = "DeferredUIEnter",
		keys = {
			{
				"<leader>un",
				function()
					require("noice").cmd("dismiss")
				end,
				desc = "Dismiss Notifications",
			},
		},
		after = function()
			require("notify").setup({
				background_colour = "#000000",
			})
			require("noice").setup({
				lsp = {
					override = {
						["vim.lsp.util.convert_input_to_markdown_lines"] = true,
						["vim.lsp.util.set_dot_indent"] = true,
						["nvim.lsp.util.stylize_markdown"] = true,
					},
				},
				presets = {
					bottom_search = true,
					command_palette = true,
					long_message_to_split = true,
					inc_rename = true,
					lsp_doc_border = false,
				},
			})
		end,
	},
	{
		"trouble.nvim",
		enabled = nixCats("general") or false,
		cmd = "Trouble",
		keys = {
			{ "<leader>tx", "<cmd>Trouble diagnostics toggle<cr>", desc = "Diagnostics (Workspace)" },
			{ "<leader>tX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Diagnostics (Buffer)" },
			{ "<leader>ts", "<cmd>Trouble symbols toggle focus=false<cr>", desc = "Symbols" },
			{
				"<leader>tl",
				"<cmd>Trouble lsp toggle focus=false win.position=right<cr>",
				desc = "LSP Definitions/References",
			},
			{ "<leader>tq", "<cmd>Trouble qflist toggle<cr>", desc = "Quickfix" },
			{ "<leader>tL", "<cmd>Trouble loclist toggle<cr>", desc = "Location List" },
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
			require("mini.comment").setup({
				mappings = {
					comment_line = "<C-c>",
					comment_visual = "<C-c>",
				},
			})
			require("mini.pairs").setup()
			require("mini.icons").setup()
			require("mini.ai").setup()
			require("mini.surround").setup({
				mappings = {
					add = "ms",
					delete = "md",
					find = "mf",
					highlight = "mh",
					replace = "mr",
					update_n_lines = "mn",
				},
			})
			require("mini.align").setup({
				mappings = {
					start = "ma",
					start_with_preview = "mA",
				},
			})
		end,
	},
	{
		"markview.nvim",
		enabled = nixCats("general") or false,
		ft = "markdown",
		after = function()
			utils.nmap("<leader>tm", "<cmd>Markview toggle<cr>", "Markview")
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
	{
		"nvim-highlight-colors",
		enabled = nixCats("general") or false,
		event = "DeferredUIEnter",
		after = function()
			require("nvim-highlight-colors").setup({
				enable_tailwind = true,
			})
			utils.nmap("<leader>th", "<cmd>HighlightColors toggle<cr>", "Highlight Colors")
		end,
	},
}
