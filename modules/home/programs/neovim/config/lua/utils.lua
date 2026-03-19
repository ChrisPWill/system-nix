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

return M
