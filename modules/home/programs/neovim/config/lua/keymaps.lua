-- Keymaps for better default experience
-- See `:help vim.keymap.set()`
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "Moves Line Down" })
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "Moves Line Up" })

-- Scrolling
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Scroll Down" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Scroll Up" })

-- Search
vim.keymap.set("n", "n", "nzzzv", { desc = "Next Search Result" })
vim.keymap.set("n", "N", "Nzzzv", { desc = "Previous Search Result" })

-- Remap for dealing with word wrap
vim.keymap.set("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- Screenshot code (experimental, buggy)
-- Currently seems to result in an empty screenshot for non-typescript code
vim.keymap.set("v", "<leader>cs", function()
	-- Get the current buffer's filetype
	local ft = vim.bo.filetype
	-- Execute the shell command using the selection range
	vim.cmd("'<,'>w !silicon --to-clipboard --language " .. ft)
end, { desc = "Take screenshot of visual selection" })

-- These keybindings allow you to copy to system clipboard without `unnamedplus`
vim.keymap.set({ "v", "x", "n" }, "<leader>y", '"+y', { noremap = true, silent = true, desc = "Yank to clipboard" })
vim.keymap.set(
	{ "n", "v", "x" },
	"<leader>Y",
	'"+yy',
	{ noremap = true, silent = true, desc = "Yank line to clipboard" }
)
vim.keymap.set({ "n", "v", "x" }, "<leader>p", '"+p', { noremap = true, silent = true, desc = "Paste from clipboard" })
vim.keymap.set(
	"i",
	"<C-p>",
	"<C-r><C-p>+",
	{ noremap = true, silent = true, desc = "Paste from clipboard from within insert mode" }
)
vim.keymap.set(
	"x",
	"<leader>P",
	'"_dP',
	{ noremap = true, silent = true, desc = "Paste over selection without erasing unnamed register" }
)

-- ── Helix Alignment ──────────────────────────────────────────────────────────

-- Goto mode mappings (Helix: g)
vim.keymap.set({ "n", "x", "o" }, "gh", "0", { desc = "Go to line start" })
vim.keymap.set({ "n", "x", "o" }, "gl", "$", { desc = "Go to line end" })
vim.keymap.set({ "n", "x", "o" }, "gs", "^", { desc = "Go to first non-blank character" })
vim.keymap.set({ "n", "x", "o" }, "ge", "G", { desc = "Go to last line" })
vim.keymap.set({ "n", "x", "o" }, "gt", "H", { desc = "Go to top of window" })
vim.keymap.set({ "n", "x", "o" }, "gb", "L", { desc = "Go to bottom of window" })
vim.keymap.set({ "n", "x", "o" }, "gc", "M", { desc = "Go to center of window" })

-- Match mode (Helix: m)
vim.keymap.set({ "n", "x", "o" }, "mm", "%", { desc = "Match bracket" })

-- Buffer navigation (Helix: gn/gp)
vim.keymap.set("n", "gn", "<cmd>bnext<CR>", { desc = "Next buffer" })
vim.keymap.set("n", "gp", "<cmd>bprev<CR>", { desc = "Previous buffer" })

-- Diagnostic navigation (Helix: ]d / [d)
vim.keymap.set("n", "]d", function()
	vim.diagnostic.goto_next({ float = true })
end, { desc = "Next diagnostic" })
vim.keymap.set("n", "[d", function()
	vim.diagnostic.goto_prev({ float = true })
end, { desc = "Previous diagnostic" })

-- Window management (Helix: <leader>w)
vim.keymap.set("n", "<leader>w", "<C-w>", { desc = "Window management" })
