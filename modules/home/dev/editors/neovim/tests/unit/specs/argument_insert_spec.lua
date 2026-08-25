local source = debug.getinfo(1, "S").source:sub(2)
local specs_dir = vim.fs.dirname(source)
local unit_dir = vim.fs.dirname(specs_dir)
local config_root = vim.fs.dirname(vim.fs.dirname(unit_dir)) .. "/config/lua"
package.path = unit_dir .. "/?.lua;" .. config_root .. "/?.lua;" .. config_root .. "/?/init.lua;" .. package.path

local h = require("helpers")
local argument_insert = require("utils.treesitter.argument_insert")

local function line(bufnr, row)
	return vim.api.nvim_buf_get_lines(bufnr, row - 1, row, false)[1]
end

-- Simple single-line call: insert after the last argument.
local call_bufnr = h.load_fixture("kotlin/simple_call.kt")
vim.api.nvim_set_current_buf(call_bufnr)
vim.api.nvim_win_set_cursor(0, { 2, 8 }) -- on `a`
argument_insert.insert_argument(call_bufnr)
vim.cmd("stopinsert")
h.assert_equal(line(call_bufnr, 2), "    foo(a, b, )", "should insert ', ' after the last argument")

-- Regression: Kotlin's primary constructor (`class Foo(val a: Int)`)
-- holds its parameters directly with no separate "parameters"-named
-- wrapper — a plain substring match on "parameter" would miss it
-- entirely (or, if too loose, match the wrong container).
local ctor_bufnr = h.load_fixture("kotlin/primary_constructor.kt")
vim.api.nvim_set_current_buf(ctor_bufnr)
vim.api.nvim_win_set_cursor(0, { 1, 12 }) -- inside the constructor param list
argument_insert.insert_argument(ctor_bufnr)
vim.cmd("stopinsert")
h.assert_equal(line(ctor_bufnr, 1), "class Foo(val a: Int, val b: Int, ) {", "should target the primary constructor's own param list")

-- Regression: invoking this from inside a function's *body* (not its
-- signature) should still target that function's own signature — the
-- param list is a sibling of the body, not an ancestor of anything
-- inside it, so a plain ancestor-climb alone would find nothing.
local body_bufnr = h.load_fixture("kotlin/body_fallback.kt")
vim.api.nvim_set_current_buf(body_bufnr)
vim.api.nvim_win_set_cursor(0, { 3, 15 }) -- inside bar()'s body, on `return x + a`
argument_insert.insert_argument(body_bufnr)
vim.cmd("stopinsert")
h.assert_equal(line(body_bufnr, 2), "    fun bar(x: Int, ): Int {", "should fall back to bar()'s own signature")

-- Rust edge case: rustfmt's multi-line trailing-comma style. Inserting
-- must land *after* the existing comma, not duplicate it.
local rust_bufnr = h.load_fixture("rust/trailing_comma_params.rs")
vim.api.nvim_set_current_buf(rust_bufnr)
vim.api.nvim_win_set_cursor(0, { 3, 4 }) -- on `b`
argument_insert.insert_argument(rust_bufnr)
vim.cmd("stopinsert")
h.assert_equal(line(rust_bufnr, 3), "    b: i32,", "should not duplicate the existing trailing comma")
local cursor = vim.api.nvim_win_get_cursor(0)
h.assert_equal(cursor[1], 3, "cursor should stay on the trailing-comma line")
h.assert_equal(cursor[2], 11, "cursor should land right after the existing comma")

print("argument_insert_spec: all assertions passed")
