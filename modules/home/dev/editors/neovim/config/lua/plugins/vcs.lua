return {
	{
		"gitsigns.nvim",
		enabled = nixCats("general") or false,
		event = "DeferredUIEnter",
		after = function()
			local utils = require("utils")
			require("gitsigns").setup({
				signs = {
					add = { text = "+" },
					change = { text = "~" },
					delete = { text = "_" },
					topdelete = { text = "‾" },
					changedelete = { text = "~" },
				},
				on_attach = function(bufnr)
					local gs = package.loaded.gitsigns

					local function map(mode, l, r, opts)
						opts = opts or {}
						opts.buffer = bufnr
						vim.keymap.set(mode, l, r, opts)
					end

					-- Navigation
					map({ "n", "v" }, "]g", function()
						if vim.wo.diff then
							return "]g"
						end
						vim.schedule(function()
							gs.next_hunk()
						end)
						return "<Ignore>"
					end, { expr = true, desc = "Next hunk" })

					map({ "n", "v" }, "[g", function()
						if vim.wo.diff then
							return "[g"
						end
						vim.schedule(function()
							gs.prev_hunk()
						end)
						return "<Ignore>"
					end, { expr = true, desc = "Previous hunk" })

					-- Actions
					map("v", "<leader>gs", function()
						gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
					end, { desc = "Stage hunk" })
					map("v", "<leader>gr", function()
						gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
					end, { desc = "Reset hunk" })

					map("n", "<leader>gs", gs.stage_hunk, { desc = "Stage hunk" })
					map("n", "<leader>gr", gs.reset_hunk, { desc = "Reset hunk" })
					map("n", "<leader>gS", gs.stage_buffer, { desc = "Stage buffer" })
					map("n", "<leader>gu", gs.undo_stage_hunk, { desc = "Undo stage" })
					map("n", "<leader>gR", gs.reset_buffer, { desc = "Reset buffer" })
					map("n", "<leader>gp", gs.preview_hunk, { desc = "Preview hunk" })
					map("n", "<leader>gl", function()
						gs.blame_line({ full = false })
					end, { desc = "Blame (Inline)" })
					map("n", "<leader>gd", gs.diffthis, { desc = "Diff (Index)" })
					map("n", "<leader>gD", function()
						gs.diffthis("~")
					end, { desc = "Diff (Last commit)" })

					-- Toggles
					map("n", "<leader>gtb", gs.toggle_current_line_blame, { desc = "Toggle: Blame line" })
					map("n", "<leader>gtd", gs.toggle_deleted, { desc = "Toggle: Deleted" })

					-- Text object
					map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", { desc = "Select hunk" })

					if not vim.b[bufnr].gitsigns_which_key_registered then
						local registered = utils.registerWhichKey({
							{ "]g", desc = "Next hunk", mode = { "n", "v" } },
							{ "[g", desc = "Previous hunk", mode = { "n", "v" } },
							{ "<leader>gs", desc = "Stage hunk", mode = { "n", "v" } },
							{ "<leader>gr", desc = "Reset hunk", mode = { "n", "v" } },
							{ "<leader>gS", desc = "Stage buffer" },
							{ "<leader>gu", desc = "Undo stage" },
							{ "<leader>gR", desc = "Reset buffer" },
							{ "<leader>gp", desc = "Preview hunk" },
							{ "<leader>gl", desc = "Blame (Inline)" },
							{ "<leader>gd", desc = "Diff (Index)" },
							{ "<leader>gD", desc = "Diff (Last commit)" },
							{ "<leader>gtb", desc = "Toggle: Blame line" },
							{ "<leader>gtd", desc = "Toggle: Deleted" },
							{ "ih", desc = "Select hunk", mode = { "o", "x" } },
						}, bufnr)
						vim.b[bufnr].gitsigns_which_key_registered = registered
					end
				end,
			})
			vim.cmd([[hi GitSignsAdd guifg=#04de21]])
			vim.cmd([[hi GitSignsChange guifg=#83fce6]])
			vim.cmd([[hi GitSignsDelete guifg=#fa2525]])
		end,
	},
}
