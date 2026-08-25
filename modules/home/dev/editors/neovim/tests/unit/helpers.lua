-- Shared assertion/fixture helpers for specs/*_spec.lua, run via
-- run_specs.lua. Kept deliberately framework-free (plain error()-based
-- asserts), matching this suite's existing bracket_repeat_spec.lua
-- convention rather than pulling in a busted dependency.
local M = {}

function M.assert_equal(actual, expected, message)
	if actual ~= expected then
		error((message or "assertion") .. ": expected " .. vim.inspect(expected) .. ", got " .. vim.inspect(actual))
	end
end

function M.assert_true(value, message)
	if not value then
		error((message or "assertion") .. ": expected truthy, got " .. vim.inspect(value))
	end
end

function M.assert_nil(value, message)
	if value ~= nil then
		error((message or "assertion") .. ": expected nil, got " .. vim.inspect(value))
	end
end

local EXT_TO_FILETYPE = {
	kt = "kotlin",
	rs = "rust",
	lua = "lua",
	md = "markdown",
}

--- Open `tests/unit/fixtures/<relative_path>` as a real file-backed
--- buffer — the code under test lives in its own importable file rather
--- than an inline string table — with its treesitter parser already
--- parsed.
---@param relative_path string e.g. "kotlin/empty_catch.kt"
---@return integer bufnr
function M.load_fixture(relative_path)
	local source = debug.getinfo(1, "S").source:sub(2)
	local fixtures_dir = vim.fs.dirname(source) .. "/fixtures"
	local path = fixtures_dir .. "/" .. relative_path

	local ext = relative_path:match("%.([%w]+)$")
	local filetype = EXT_TO_FILETYPE[ext] or ext

	local bufnr = vim.fn.bufadd(path)
	vim.fn.bufload(bufnr)
	-- Fixtures live in the Nix store when run via the check, which is
	-- read-only on disk — harmless since specs never :write, but Neovim
	-- warns (W10) the first time an in-memory edit touches a buffer
	-- backed by a read-only file. Silenced since it's expected here.
	vim.bo[bufnr].readonly = false
	vim.bo[bufnr].filetype = filetype
	vim.treesitter.get_parser(bufnr, filetype):parse(true)
	return bufnr
end

return M
