return {
	{
		"arrow.nvim",
		enabled = nixCats("general") or false,
		keys = {
			{ "<leader>;", desc = "Arrow - files" },
			{ ";", desc = "Arrow - line numbers" },
		},
		after = function()
			require("arrow").setup({
				show_icons = true,
				leader_key = "<leader>;",
				buffer_leader_key = ";",
			})
		end,
	},
	{
		"leap.nvim",
		enabled = nixCats("general") or false,
		keys = {
			{ [[\]], desc = "Leap" },
			{ [[<leader>\s]], desc = "Leap select with Treesitter" },
		},
		after = function()
			vim.keymap.set({ "n", "x", "o" }, [[\]], "<Plug>(leap)", { desc = "Leap" })
			-- Treesitter
			vim.keymap.set({ "n", "x", "o" }, [[<leader>\s]], function()
				require("leap.treesitter").select({
					opts = require("leap.user").with_traversal_keys("R", "r"),
				})
			end, { desc = "Leap select with Treesitter" })
		end,
	},
	-- Note: Treewalker is configured in plugins.treesitter for closer integration with TS grammar settings
}
