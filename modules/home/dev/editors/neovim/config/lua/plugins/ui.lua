local utils = require("utils")

return {
	-- https://github.com/nvim-lualine/lualine.nvim
	{
		"lualine.nvim",
		enabled = nixCats("general") or false,
		event = "DeferredUIEnter",
		after = function()
			local navic = require("nvim-navic")
			navic.setup({
				highlight = true,
				lsp = { auto_attach = false },
			})

			local function get_file_accent()
				-- Vaguely OneDark (orange is custom)
				local ft_colors = {
					nix = "#61afef", -- blue
					lua = "#c678dd", -- purple
					python = "#61afef", -- blue
					rust = "#d19a66", -- orange
					javascript = "#e5c07b", -- yellow
					typescript = "#61afef", -- blue
					go = "#56b6c2", -- cyan
					markdown = "#abb2bf", -- gray
					java = "#e06c75", -- red
				}
				return ft_colors[vim.bo.filetype] or nil
			end

			require("lualine").setup({
				options = {
					icons_enabled = true,
					theme = "onedark",
					component_separators = "|",
					section_separators = "",
				},
				sections = {
					lualine_a = { "mode" },
					lualine_b = { "branch", "diff", "diagnostics" },
					lualine_c = {
						{
							"filename",
							path = 0,
							file_status = true,
						},
						{
							function()
								return navic.get_location()
							end,
							cond = function()
								return navic.is_available()
							end,
						},
					},
					lualine_x = {
						{
							function()
								return string.format("󰈙 %d", vim.fn.wordcount().words)
							end,
							cond = function()
								local ft = vim.bo.filetype
								local count_ft = { "markdown", "text", "asciidoc", "vimwiki" }
								for _, v in ipairs(count_ft) do
									if ft == v then
										return true
									end
								end
								return false
							end,
						},
						"selectioncount",
						"searchcount",
						{
							function()
								local line_level = vim.fn.foldlevel(vim.api.nvim_win_get_cursor(0)[1])
								local global_level = vim.opt.foldlevel:get()
								return string.format("󰙅 %d 󰅩 %d", line_level, global_level)
							end,
							cond = function()
								return vim.opt.foldenable:get()
							end,
						},
						{
							function()
								local curr_line = vim.fn.line(".")
								local total_lines = vim.fn.line("$")
								local chunks = { " ", "▂", "▃", "▄", "▅", "▆", "▇", "█" }
								local line_ratio = curr_line / total_lines
								local index = math.ceil(line_ratio * #chunks)
								return chunks[index] .. " " .. math.floor(line_ratio * 100) .. "%%"
							end,
						},
						"encoding",
						{
							"filetype",
							color = function()
								local bg = get_file_accent()
								if bg then
									return { bg = bg, fg = "#282c34", gui = "bold" }
								end
								return nil
							end,
						},
					},
					lualine_y = { "progress" },
					lualine_z = { { "location", use_mode_colors = true } },
				},
				inactive_sections = {
					lualine_b = {
						{
							"filename",
							file_status = true,
							path = 0,
						},
					},
					lualine_x = { "filetype" },
				},
				tabline = {
					lualine_a = { { "buffers", use_mode_colors = true } },
					lualine_b = {
						"copilot",
						{
							function()
								local clients = vim.lsp.get_clients({ bufnr = 0 })
								if next(clients) == nil then
									return ""
								end

								-- Heartbeat animation
								local frame = math.floor(vim.loop.hrtime() / 120000000) % 10
								local spinners =
									{ "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }
								local spinner = ""

								-- Only spin if there's progress
								local progress = false
								for _, client in ipairs(clients) do
									if
										client.progress
										and client.progress.tokens
										and next(client.progress.tokens) ~= nil
									then
										progress = true
										break
									end
								end
								if progress then
									spinner = spinners[frame + 1] .. " "
								end

								local icon_map = {
									lua_ls = "",
									basedpyright = "",
									rust_analyzer = "",
									nixd = "",
									vtsls = "",
									tsserver = "",
									gopls = "",
									bashls = "󱆃",
									jsonls = "",
									yamlls = "",
									taplo = "",
									html = "",
									cssls = "",
								}
								local client_labels = {}
								for _, client in ipairs(clients) do
									table.insert(client_labels, icon_map[client.name] or client.name)
								end
								return spinner .. "LSP " .. table.concat(client_labels, " ")
							end,
						},
						"lsp_progress",
					},
					lualine_z = { { "tabs", use_mode_colors = true } },
				},
			})
		end,
	},
	{
		"lualine-lsp-progress",
		enabled = nixCats("general") or false,
		on_plugin = { "lualine.nvim" },
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
