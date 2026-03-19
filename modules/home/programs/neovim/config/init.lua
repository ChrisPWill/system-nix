-- NOTE: These 2 need to be set up before any plugins are loaded.
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- [[ Setting options ]]
require("global-options")

-- [[ Basic Keymaps ]]
require("keymaps")

local utils = require("utils")

require("onedark").setup({})
vim.cmd.colorscheme("onedark")

require("snacks-config")

-- Load modularized plugins
require("plugins")

if nixCats("leet") then
	require("leetcode").setup({
		arg = "start",
		lang = "python3",
	})
	utils.nmap("<leader>lM", "<cmd>Leet menu<CR>", "Leet main menu")
	utils.nmap("<leader>lii", "<cmd>Leet info<CR>", "Leet question info")
	utils.nmap("<leader>liI", "<cmd>Leet inject<CR>", "Leet re-inject editor code")
	utils.nmap("<leader>ll", "<cmd>Leet list<CR>", "Leet question list")
	utils.nmap("<leader>lL", "<cmd>Leet lang<CR>", "Leet lang picker")
	utils.nmap("<leader>lf", "<cmd>Leet fold<CR>", "Leet fold imports section")
	utils.nmap("<leader>ldd", "<cmd>Leet description<CR>", "Leet toggle description")
	utils.nmap("<leader>lds", "<cmd>Leet description stats<CR>", "Leet toggle description stats")
	utils.nmap("<leader>lD", "<cmd>Leet daily<CR>", "Leet daily question")
	utils.nmap("<leader>lt", "<cmd>Leet test<CR>", "Leet test")
	utils.nmap("<leader>lss", "<cmd>Leet submit<CR>", "Leet submit")
	utils.nmap("<leader>lsl", "<cmd>Leet last_submit<CR>", "Leet restore last submitted code")
	utils.nmap("<leader>lR", "<cmd>Leet restore<CR>", "Leet restore to original code")
end

require("autocmds")

local lsp_utils = require("plugins.lsp")
vim.g.rustaceanvim = {
	server = {
		on_attach = lsp_utils.on_attach,
	},
}

-- Search forward for visually selected text
-- 'x' mode covers visual mode but not select mode
vim.keymap.set("x", "*", [[y/\V<C-R>=substitute(escape(@@, "/\\"), "\n", "\\\\n", "ge")<CR><CR>]], {
	desc = "Search forward for visually selected text",
})

-- Search backward for visually selected text
vim.keymap.set("x", "#", [[y?\V<C-R>=substitute(escape(@@, "?\\"), "\n", "\\\\n", "ge")<CR><CR>]], {
	desc = "Search backward for visually selected text",
})
