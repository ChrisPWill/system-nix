local M = {}

-- Helper function for normal mode keymaps
function M.nmap(keys, func, desc, opts)
	opts = opts or {}
	opts.desc = desc
	vim.keymap.set("n", keys, func, opts)
end

-- Helper function for finding project types
function M.rootHasFiles(files)
	return #vim.fs.find(files, { upward = true, stop = vim.env.HOME }) > 0
end

function M.getProjectRoot(files)
	local res = vim.fs.find(files, { upward = true, stop = vim.env.HOME })
	if #res > 0 then
		return vim.fs.dirname(res[1])
	end
	return nil
end

function M.isDeno()
	return M.rootHasFiles({ "deno.json" })
end

function M.isEslint()
	return M.rootHasFiles({ "eslint.config.*", ".eslintrc*" })
end

function M.isTreefmt()
	return M.rootHasFiles({ "treefmt.toml", ".treefmt.toml" })
end

function M.isJujutsu()
	return M.rootHasFiles({ ".jj" })
end

function M.insertIfTrue(t, exp, value)
	if exp then
		table.insert(t, value)
	end
end

-- Open a doc file in a floating window (optimized for documentation)
function M.viewDocFile(file_path)
	require("snacks").win({
		file = file_path,
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
end

-- Create a small transient help float at the bottom right
function M.createHelpFloat(text)
	local snacks = require("snacks")
	local win = snacks.win({
		text = text,
		width = #text + 2,
		height = 1,
		position = "float",
		backdrop = false, -- Disable background fade
		row = -2, -- Bottom
		col = -2, -- Right
		border = "rounded",
		zindex = 100,
		focusable = false,
		wo = {
			winhighlight = "Normal:DiagnosticInfo,FloatBorder:DiagnosticInfo",
			cursorline = false,
		},
	})
	return win
end

return M
