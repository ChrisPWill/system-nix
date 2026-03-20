local utils = require("utils")

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

vim.keymap.set("n", "-", function()
	Snacks.explorer.open()
end, { desc = "Explorer" })

vim.keymap.set("n", "<c-\\>", function()
	Snacks.terminal.open()
end, { desc = "Terminal" })

-- ── Git Group (<leader>g) ───────────────────────────────────────────────────

vim.keymap.set("n", "<leader>gg", function()
	Snacks.lazygit.open()
end, { desc = "LazyGit" })

vim.keymap.set("n", "<leader>gj", function()
	Snacks.terminal.open("lazyjj")
end, { desc = "Jujutsu (LazyJJ)" })

vim.keymap.set("n", "<leader>gb", function()
	Snacks.terminal.open("tig blame " .. vim.fn.expand("%"))
end, { desc = "Blame (Tig)" })

vim.keymap.set("n", "<leader>go", function()
	Snacks.gitbrowse.open({
		what = "permalink",
	})
end, { desc = "Open in Browser (Permalink)" })

vim.keymap.set("n", "<leader>gO", function()
	Snacks.gitbrowse.open({
		what = "file",
		branch = "master",
	})
end, { desc = "Open in Browser (Master)" })

vim.keymap.set("n", "<leader>sf", function()
	Snacks.picker.smart()
end, { desc = "Smart Find" })

vim.keymap.set("n", "<leader>b", function()
	Snacks.picker.buffers()
end, { desc = "Search Buffers" })

-- ── Find ──────────────────────────────────────────────────────────────────────

vim.keymap.set("n", "<leader>f", function()
	Snacks.picker.files()
end, { desc = "Files" })

vim.keymap.set("n", "<leader>gf", function()
	Snacks.picker.git_files()
end, { desc = "Git Files" })

-- ── Grep ──────────────────────────────────────────────────────────────────────

vim.keymap.set("n", "<leader>/b", function()
	Snacks.picker.lines()
end, { desc = "Buffer Lines" })

vim.keymap.set("n", "<leader>/B", function()
	Snacks.picker.grep_buffers()
end, { desc = "Grep (Buffers)" })

vim.keymap.set("n", "<leader>//", function()
	Snacks.picker.grep()
end, { desc = "Grep (All)" })

vim.keymap.set({ "n", "x" }, "<leader>/w", function()
	Snacks.picker.grep_word()
end, { desc = "Grep (Word/Selection)" })

-- ── Search Group ─────────────────────────────────────────────────────────────

vim.keymap.set("n", "<leader>D", function()
	Snacks.picker.diagnostics()
end, { desc = "Workspace Diagnostics" })

vim.keymap.set("n", "<leader>d", function()
	Snacks.picker.diagnostics_buffer()
end, { desc = "Buffer Diagnostics" })

vim.keymap.set("n", "<leader>/h", function()
	Snacks.picker.help()
end, { desc = "Help" })

vim.keymap.set("n", "<leader>/j", function()
	Snacks.picker.jumps()
end, { desc = "Jumps" })

vim.keymap.set("n", "<leader>/k", function()
	Snacks.picker.files({
		cwd = nixCats.extra("docsPath"),
		confirm = function(picker, item)
			picker:close()
			if item then
				utils.viewDocFile(item.cwd .. "/" .. item.file)
			end
		end,
	})
end, { desc = "Knowledge Base" })

vim.keymap.set("n", "<leader>/K", function()
	Snacks.picker.grep({
		cwd = nixCats.extra("docsPath"),
		confirm = function(picker, item)
			picker:close()
			if item then
				utils.viewDocFile(item.cwd .. "/" .. item.file)
			end
		end,
	})
end, { desc = "Knowledge Base (Grep)" })

vim.keymap.set("n", "<leader>kc", function()
	utils.viewDocFile((nixCats.extra("docsPath") or "") .. "/cheatsheet.md")
end, { desc = "Cheat-sheet" })

vim.keymap.set("n", "<leader>km", function()
	utils.viewDocFile((nixCats.extra("docsPath") or "") .. "/KEYMAPS.md")
end, { desc = "Keymaps Guide" })

vim.keymap.set("n", "<leader>kr", function()
	utils.viewDocFile(vim.api.nvim_get_runtime_file("doc/quickref.txt", false)[1])
end, { desc = "Neovim Quickref" })

vim.keymap.set("n", "<leader>/m", function()
	Snacks.picker.keymaps()
end, { desc = "Keymaps" })

vim.keymap.set("n", "<leader>/l", function()
	Snacks.picker.loclist()
end, { desc = "Location List" })

vim.keymap.set("n", "<leader>/;", function()
	Snacks.picker.marks()
end, { desc = "Marks" })

vim.keymap.set("n", "<leader>/M", function()
	Snacks.picker.man()
end, { desc = "Man Pages" })

vim.keymap.set("n", "<leader>/q", function()
	Snacks.picker.qflist()
end, { desc = "Quickfix List" })

vim.keymap.set("n", "<leader>/R", function()
	Snacks.picker.resume()
end, { desc = "Resume" })

vim.keymap.set("n", "<leader>/u", function()
	Snacks.picker.undo()
end, { desc = "Undo" })
