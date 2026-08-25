local source = debug.getinfo(1, "S").source:sub(2)
local specs_dir = vim.fs.dirname(source)
local unit_dir = vim.fs.dirname(specs_dir)
local config_root = vim.fs.dirname(vim.fs.dirname(unit_dir)) .. "/config/lua"
package.path = unit_dir .. "/?.lua;" .. config_root .. "/?.lua;" .. config_root .. "/?/init.lua;" .. package.path

local h = require("helpers")
local mutations = require("utils.treesitter.mutations")

-- Regression: mutation search must reach into a class-level `var` even
-- though the mutation itself lives inside a method — the identifier's
-- own enclosing "function" (a stricter check than substring-matching
-- "function") used to resolve to nothing usable when starting from a
-- class-level property, and mutations inside the method got skipped
-- because the walk didn't descend into function-like nodes at all.
local bufnr = h.load_fixture("kotlin/class_property_mutation.kt")
vim.api.nvim_set_current_buf(bufnr)
vim.api.nvim_win_set_cursor(0, { 2, 8 }) -- the `var x = 5` declaration

local ident, sites = mutations.find_mutation_sites(bufnr)
h.assert_true(ident ~= nil, "should resolve the identifier at the declaration")
h.assert_equal(#sites, 2, "should find both mutations inside bar(), even though the declaration is at class level")

-- Scoping: a same-named local in an unrelated sibling function must not
-- cross-contaminate the search.
local scoped_bufnr = h.load_fixture("kotlin/scoped_locals.kt")
vim.api.nvim_set_current_buf(scoped_bufnr)
vim.api.nvim_win_set_cursor(0, { 3, 12 })
local _, bar_sites = mutations.find_mutation_sites(scoped_bufnr)
h.assert_equal(#bar_sites, 1, "bar()'s result should only see its own mutation, not baz()'s")

print("mutations_spec: all assertions passed")
