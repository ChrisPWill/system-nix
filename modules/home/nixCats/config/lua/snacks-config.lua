require("snacks").setup({
	explorer = {},
	picker = {},
	bigfile = {},
	image = {},
	lazygit = {},
	terminal = {},
	rename = {},
	notifier = {},
	indent = {},
	gitbrowse = {},
	scope = {},
})

-- Explorer "-"
vim.keymap.set("n", "-", function()
	Snacks.explorer.open()
end, { desc = "Snacks Explorer" })

-- Terminal "Ctrl-\\"
vim.keymap.set("n", "<c-\\>", function()
	Snacks.terminal.open()
end, { desc = "Snacks Terminal" })

-- LazyGit "<leader>_"
vim.keymap.set("n", "<leader>_", function()
	Snacks.lazygit.open()
end, { desc = "Snacks LazyGit" })

-- Terminal LazyJJ "<leader>j"
vim.keymap.set("n", "<leader>j", function()
	Snacks.terminal.open("lazyjj")
end, { desc = "Snacks Terminal LazyJJ" })

-- Smart File Finder "<leader>sf"
vim.keymap.set("n", "<leader>sf", function()
	Snacks.picker.smart()
end, { desc = "Smart Find Files" })

-- Buffer Search "<leader>Space-s"
vim.keymap.set("n", "<leader><leader>s", function()
	Snacks.picker.buffers()
end, { desc = "Search Buffers" })

-- ── Find ──────────────────────────────────────────────────────────────────────

-- Find Files "<leader>ff"
vim.keymap.set("n", "<leader>ff", function()
	Snacks.picker.files()
end, { desc = "Find Files" })

-- Find Git Files "<leader>fg"
vim.keymap.set("n", "<leader>fg", function()
	Snacks.picker.git_files()
end, { desc = "Find Git Files" })

-- ── Grep ──────────────────────────────────────────────────────────────────────

-- Buffer Lines "<leader>sb"
vim.keymap.set("n", "<leader>sb", function()
	Snacks.picker.lines()
end, { desc = "Buffer Lines" })

-- Grep Open Buffers "<leader>sB"
vim.keymap.set("n", "<leader>sB", function()
	Snacks.picker.grep_buffers()
end, { desc = "Grep Open Buffers" })

-- Grep All "<leader>sg"
vim.keymap.set("n", "<leader>sg", function()
	Snacks.picker.grep()
end, { desc = "Grep" })

-- Grep Visual / Word "<leader>sw"
vim.keymap.set({ "n", "x" }, "<leader>sw", function()
	Snacks.picker.grep_word()
end, { desc = "Visual Selection or Word" })

-- ── Search ────────────────────────────────────────────────────────────────────

-- Buffer Lines "<leader>sb"
vim.keymap.set("n", "<leader>sb", function()
	Snacks.picker.lines()
end, { desc = "Buffer Lines" })

-- Diagnostics "<leader>sd"
vim.keymap.set("n", "<leader>sd", function()
	Snacks.picker.diagnostics()
end, { desc = "Diagnostics" })

-- Buffer Diagnostics "<leader>sD"
vim.keymap.set("n", "<leader>sD", function()
	Snacks.picker.diagnostics_buffer()
end, { desc = "Buffer Diagnostics" })

-- Help Pages "<leader>sh"
vim.keymap.set("n", "<leader>sh", function()
	Snacks.picker.help()
end, { desc = "Help Pages" })

-- Jumps "<leader>sj"
vim.keymap.set("n", "<leader>sj", function()
	Snacks.picker.jumps()
end, { desc = "Jumps" })

-- Keymaps "<leader>sk"
vim.keymap.set("n", "<leader>sk", function()
	Snacks.picker.keymaps()
end, { desc = "Keymaps" })

-- Location List "<leader>sl"
vim.keymap.set("n", "<leader>sl", function()
	Snacks.picker.loclist()
end, { desc = "Location List" })

-- Marks "<leader>sm"
vim.keymap.set("n", "<leader>sm", function()
	Snacks.picker.marks()
end, { desc = "Marks" })

-- Man Pages "<leader>sM"
vim.keymap.set("n", "<leader>sM", function()
	Snacks.picker.man()
end, { desc = "Man Pages" })

-- Quickfix List "<leader>sq"
vim.keymap.set("n", "<leader>sq", function()
	Snacks.picker.qflist()
end, { desc = "Quickfix List" })

-- Resume "<leader>sR"
vim.keymap.set("n", "<leader>sR", function()
	Snacks.picker.resume()
end, { desc = "Resume" })

-- Undo History "<leader>su"
vim.keymap.set("n", "<leader>su", function()
	Snacks.picker.undo()
end, { desc = "Undo History" })

