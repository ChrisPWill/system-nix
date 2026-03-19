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

function M.isDeno()
	return M.rootHasFiles({ "deno.json" })
end

function M.isTreefmt()
	return M.rootHasFiles({ "treefmt.toml", ".treefmt.toml" })
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

return M
