vim.keymap.set("v", "<C-M-j>", ":m '>+1<CR>gv=gv", { desc = "Move Down" })
vim.keymap.set("v", "<C-M-k>", ":m '<-2<CR>gv=gv", { desc = "Move Up" })

-- Search & Select (Restoring native gn/gN functionality on Alt-n/N)
vim.keymap.set({ "n", "x" }, "<M-n>", "gn", { desc = "Search forward and select" })
vim.keymap.set({ "n", "x" }, "<M-N>", "gN", { desc = "Search backward and select" })

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
vim.keymap.set("v", "<leader>cs", function()
	local ft = vim.bo.filetype
	vim.cmd("'<,'>w !silicon --to-clipboard --language " .. ft)
end, { desc = "Take screenshot of selection" })

-- Clipboard
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
	{ noremap = true, silent = true, desc = "Paste from clipboard" }
)
vim.keymap.set(
	"x",
	"<leader>P",
	'"_dP',
	{ noremap = true, silent = true, desc = "Paste (Over selection)" }
)

-- ── Helix Alignment ──────────────────────────────────────────────────────────

-- Goto mode mappings
vim.keymap.set({ "n", "x", "o" }, "gh", "0", { desc = "Line start" })
vim.keymap.set({ "n", "x", "o" }, "gl", "$", { desc = "Line end" })
vim.keymap.set({ "n", "x", "o" }, "gs", "^", { desc = "First non-blank" })
vim.keymap.set({ "n", "x", "o" }, "ge", "G", { desc = "Last line" })
vim.keymap.set({ "n", "x", "o" }, "gt", "H", { desc = "Top of window" })
vim.keymap.set({ "n", "x", "o" }, "gb", "L", { desc = "Bottom of window" })
vim.keymap.set({ "n", "x", "o" }, "gc", "M", { desc = "Center of window" })
vim.keymap.set({ "n", "x", "o" }, "ga", "<C-^>", { desc = "Last accessed file" })
vim.keymap.set({ "n", "x", "o" }, "gf", "gf", { desc = "File under cursor" })
vim.keymap.set({ "n", "x", "o" }, "gm", function()
	require("snacks").picker.recent()
end, { desc = "Recent Files" })

-- Match mode
vim.keymap.set({ "n", "x", "o" }, "mm", "%", { desc = "Match bracket" })

-- Buffer navigation
vim.keymap.set("n", "gn", "<cmd>bnext<CR>", { desc = "Next buffer" })
vim.keymap.set("n", "gp", "<cmd>bprev<CR>", { desc = "Previous buffer" })

-- Tab navigation
vim.keymap.set("n", "<leader>]t", "<cmd>tabnext<CR>", { desc = "Next tab" })
vim.keymap.set("n", "<leader>[t", "<cmd>tabprev<CR>", { desc = "Previous tab" })

-- Diagnostic navigation
vim.keymap.set("n", "]d", function()
	vim.diagnostic.goto_next({ float = true })
end, { desc = "Next diagnostic" })
vim.keymap.set("n", "[d", function()
	vim.diagnostic.goto_prev({ float = true })
end, { desc = "Previous diagnostic" })

-- Window management
vim.keymap.set("n", "<leader>w", "<C-w>", { desc = "Window management" })
