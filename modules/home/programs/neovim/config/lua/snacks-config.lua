require("snacks").setup({
	explorer = {},
	picker = {},
	bigfile = {},
	image = {},
	lazygit = {},
	terminal = {},
	win = {},
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

-- Git blame in tig
vim.keymap.set("n", "<leader>ggb", function()
	Snacks.terminal.open("tig blame " .. vim.fn.expand("%"))
end, { desc = "Tig Git Blame" })

-- Terminal LazyJJ "<leader>j"
vim.keymap.set("n", "<leader>j", function()
	Snacks.terminal.open("lazyjj")
end, { desc = "Snacks Terminal LazyJJ" })

-- Smart File Finder "<leader>sf"
vim.keymap.set("n", "<leader>sf", function()
	Snacks.picker.smart()
end, { desc = "Smart Find Files" })

-- Buffer Search "<leader>b"
vim.keymap.set("n", "<leader>b", function()
	Snacks.picker.buffers()
end, { desc = "Search Buffers" })

-- ── Find ──────────────────────────────────────────────────────────────────────

-- Find Files "<leader>f"
vim.keymap.set("n", "<leader>f", function()
	Snacks.picker.files()
end, { desc = "Find Files" })

-- Find Git Files "<leader>fg"
vim.keymap.set("n", "<leader>gf", function()
	Snacks.picker.git_files()
end, { desc = "Find Git Files" })

-- ── Grep ──────────────────────────────────────────────────────────────────────

-- Buffer Lines "<leader>/b"
vim.keymap.set("n", "<leader>/b", function()
	Snacks.picker.lines()
end, { desc = "Buffer Lines" })

-- Grep Open Buffers "<leader>/B"
vim.keymap.set("n", "<leader>/B", function()
	Snacks.picker.grep_buffers()
end, { desc = "Grep Open Buffers" })

-- Grep All "<leader>//"
vim.keymap.set("n", "<leader>//", function()
	Snacks.picker.grep()
end, { desc = "Search All (Grep)" })

-- Grep Visual / Word "<leader>/w"
vim.keymap.set({ "n", "x" }, "<leader>/w", function()
	Snacks.picker.grep_word()
end, { desc = "Visual Selection or Word" })

-- ── Search Group ─────────────────────────────────────────────────────────────

-- Buffer Lines "<leader>/b"
vim.keymap.set("n", "<leader>/b", function()
	Snacks.picker.lines()
end, { desc = "Buffer Lines" })

-- Diagnostics (All) "<leader>D"
vim.keymap.set("n", "<leader>D", function()
	Snacks.picker.diagnostics()
end, { desc = "Workspace Diagnostics" })

-- Buffer Diagnostics "<leader>d"
vim.keymap.set("n", "<leader>d", function()
	Snacks.picker.diagnostics_buffer()
end, { desc = "Buffer Diagnostics" })

-- Help Pages "<leader>/h"
vim.keymap.set("n", "<leader>/h", function()
	Snacks.picker.help()
end, { desc = "Help Pages" })

-- Jumps "<leader>/j"
vim.keymap.set("n", "<leader>/j", function()
	Snacks.picker.jumps()
end, { desc = "Jumps" })

-- Knowledge Base "<leader>kk"
vim.keymap.set("n", "<leader>kk", function()
	Snacks.picker.files({ cwd = (nixCats.configDir or "") .. "/docs" })
end, { desc = "Search Personal Knowledge Base" })

-- Cheat-sheet "<leader>kc"
vim.keymap.set("n", "<leader>kc", function()
	Snacks.win({
		file = (nixCats.configDir or "") .. "/docs/cheatsheet.md",
		width = 0.8,
		height = 0.8,
		position = "float",
		backdrop = 60,
		zindex = 50,
		wo = {
			spell = false,
			wrap = true,
			signcolumn = "no",
			statuscolumn = "",
			conceallevel = 2,
		},
	})
end, { desc = "Open Neovim Cheat-sheet" })

-- Keymaps "<leader>/k"
vim.keymap.set("n", "<leader>/k", function()
	Snacks.picker.keymaps()
end, { desc = "Keymaps" })

-- Location List "<leader>/l"
vim.keymap.set("n", "<leader>/l", function()
	Snacks.picker.loclist()
end, { desc = "Location List" })

-- Marks "<leader>/m"
vim.keymap.set("n", "<leader>/m", function()
	Snacks.picker.marks()
end, { desc = "Marks" })

-- Man Pages "<leader>/M"
vim.keymap.set("n", "<leader>/M", function()
	Snacks.picker.man()
end, { desc = "Man Pages" })

-- Quickfix List "<leader>/q"
vim.keymap.set("n", "<leader>/q", function()
	Snacks.picker.qflist()
end, { desc = "Quickfix List" })

-- Resume "<leader>/R"
vim.keymap.set("n", "<leader>/R", function()
	Snacks.picker.resume()
end, { desc = "Resume Picker" })

-- Undo History "<leader>/u"
vim.keymap.set("n", "<leader>/u", function()
	Snacks.picker.undo()
end, { desc = "Undo History" })

vim.keymap.set("n", "<leader>ggg", function()
	Snacks.gitbrowse.open({
		what = "permalink",
	})
end, { desc = "Open in Browser (permalink current branch)" })

vim.keymap.set("n", "<leader>ggm", function()
	Snacks.gitbrowse.open({
		what = "file",
		branch = "master",
	})
end, { desc = "Open in Browser (permalink master)" })
