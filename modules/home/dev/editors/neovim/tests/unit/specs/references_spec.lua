local source = debug.getinfo(1, "S").source:sub(2)
local specs_dir = vim.fs.dirname(source)
local unit_dir = vim.fs.dirname(specs_dir)
local config_root = vim.fs.dirname(vim.fs.dirname(unit_dir)) .. "/config/lua"
package.path = unit_dir .. "/?.lua;" .. config_root .. "/?.lua;" .. config_root .. "/?/init.lua;" .. package.path

local h = require("helpers")
local references = require("utils.treesitter.references")

-- Scoping: a same-named local in an unrelated sibling function must not
-- cross-contaminate, same underlying scope-detection as mutations.lua.
local bufnr = h.load_fixture("kotlin/scoped_locals.kt")
vim.api.nvim_set_current_buf(bufnr)
vim.api.nvim_win_set_cursor(0, { 3, 14 }) -- `result` in bar()

local current, others = references.find_references(bufnr)
h.assert_true(current ~= nil, "should resolve the identifier under the cursor")
h.assert_equal(vim.treesitter.get_node_text(current, bufnr), "result", "should resolve to 'result'")
h.assert_equal(#others, 3, "bar() has 3 other occurrences of result (2 in the reassignment, 1 in the return)")

for _, node in ipairs(others) do
	local row = node:range()
	h.assert_true(row >= 1 and row <= 4, "every occurrence must be within bar(), not baz()")
end

print("references_spec: all assertions passed")
