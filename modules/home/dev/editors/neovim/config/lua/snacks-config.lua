local utils = require("utils")

local function is_openable_file(item)
	if not item.file then
		return false
	end

	local path = vim.fs.joinpath(item.cwd or vim.uv.cwd(), item.file)
	return vim.uv.fs_stat(path) ~= nil
end

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

-- HACK: Fix for snacks.nvim workspace symbols crash when range is missing
-- Some LSP servers (like nixd or gopls) might return symbols without a range.
local snacks_lsp = require("snacks.picker.source.lsp")
local original_add_loc = snacks_lsp.add_loc
snacks_lsp.add_loc = function(item, result, client)
	local uri = result.uri or result.targetUri
	local range = result.range or result.targetSelectionRange
	if not range then
		if uri then
			item.loc = {
				uri = uri,
				range = {
					start = { line = 0, character = 0 },
					["end"] = { line = 0, character = 0 },
				},
				encoding = client.offset_encoding,
			}
			item.pos = { 1, 0 }
			item.end_pos = { 1, 0 }
			item.file = vim.uri_to_fname(uri)
			return item
		end
	end
	return original_add_loc(item, result, client)
end

vim.keymap.set("n", "-", function()
	Snacks.explorer.open()
end, { desc = "Explorer" })

vim.keymap.set({ "n", "t" }, "<c-\\>", function()
	Snacks.terminal.toggle()
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

vim.keymap.set("n", "<leader>F", function()
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
	if utils.isJujutsu() then
		local root = utils.getProjectRoot({ ".jj" })
		require("snacks").picker.pick({
			finder = "proc",
			cwd = root,
			cmd = "jj",
			args = { "file", "list" },
			transform = function(item)
				item.file = item.text
			end,
			title = "Jujutsu Files",
		})
	else
		Snacks.picker.git_files()
	end
end, { desc = "Git / JJ Files" })

vim.keymap.set("n", "<leader>gc", function()
	if utils.isJujutsu() then
		local root = utils.getProjectRoot({ ".jj" })
		require("snacks").picker.pick({
			finder = "proc",
			cwd = root,
			cmd = "jj",
			args = { "--no-pager", "--color=never", "diff", "--name-only", "-r", "@" },
			transform = function(item)
				item.cwd = root
				item.file = item.text
			end,
			filter = { filter = is_openable_file },
			title = "Changed Files (Jujutsu)",
		})
	else
		Snacks.picker.git_status({
			filter = { filter = is_openable_file },
			title = "Changed Files (Git)",
		})
	end
end, { desc = "Changed Files" })

local function changed_files(callback)
	local root
	local command
	local args

	if utils.isJujutsu() then
		root = utils.getProjectRoot({ ".jj" })
		command = "jj"
		args = { "--no-pager", "--color=never", "diff", "--name-only", "-r", "@" }
	else
		root = utils.getProjectRoot({ ".git" })
		command = "git"
		args = { "status", "--short", "--untracked-files=all" }
	end

	if not root then
		vim.notify("Not in a Jujutsu or Git repository", vim.log.levels.WARN)
		return
	end

	vim.system({ command, unpack(args) }, { cwd = root, text = true }, function(result)
		if result.code ~= 0 then
			vim.schedule(function()
				vim.notify(result.stderr ~= "" and result.stderr or "Could not read changed files", vim.log.levels.ERROR)
			end)
			return
		end

		local files = {}
		local seen = {}
		for line in result.stdout:gmatch("[^\r\n]+") do
			local file = line
			if command == "git" then
				file = line:sub(4)
				-- Porcelain status represents renames as "old -> new".
				file = file:match("^.* %-> (.*)$") or file
			end
			local path = vim.fs.joinpath(root, file)
			if file ~= "" and vim.uv.fs_stat(path) and not seen[file] then
				seen[file] = true
				table.insert(files, file)
			end
		end

		vim.schedule(function()
			callback(root, files)
		end)
	end)
end

local function navigate_changed_file(direction)
	changed_files(function(root, files)
		if #files == 0 then
			vim.notify("No changed files", vim.log.levels.INFO)
			return
		end

		local current = vim.fs.normalize(vim.api.nvim_buf_get_name(0))
		local current_index
		for index, file in ipairs(files) do
			if vim.fs.normalize(vim.fs.joinpath(root, file)) == current then
				current_index = index
				break
			end
		end

		local next_index
		if current_index then
			next_index = ((current_index - 1 + direction) % #files) + 1
		elseif direction > 0 then
			next_index = 1
		else
			next_index = #files
		end

		vim.cmd.edit(vim.fn.fnameescape(vim.fs.joinpath(root, files[next_index])))
	end)
end

require("utils.bracket-repeat").map_pair(
	{ "n" },
	"<leader>]f",
	"<leader>[f",
	function()
		navigate_changed_file(1)
	end,
	function()
		navigate_changed_file(-1)
	end,
	{ next_desc = "Next changed file", previous_desc = "Previous changed file" }
)

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

vim.keymap.set("n", "<leader>/t", function()
	local allowed_kinds = {
		Class = true,
		Interface = true,
		Enum = true,
		Struct = true,
		TypeAlias = true,
		Object = true, -- Kotlin
		Trait = true, -- Rust
		Module = true, -- Lua / Python
	}
	Snacks.picker.lsp_workspace_symbols({
		transform = function(item)
			if not allowed_kinds[item.kind] then
				return false
			end
		end,
		-- Still provide symbols to the LSP for server-side optimization if supported
		symbols = {
			"Class",
			"Interface",
			"Enum",
			"Struct",
			"TypeAlias",
			"Object",
			"Trait",
			"Module",
		},
	})
end, { desc = "Find Class / Type" })

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
