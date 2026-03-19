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
				{ "<leader>t", group = "Toggles" },
				{ "<leader>t_", hidden = true },
				{ "<leader>w", group = "Window Management" },
				{ "<leader>w_", hidden = true },
				{ "<leader>W", group = "Workspace" },
				{ "<leader>W_", hidden = true },
			})
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

