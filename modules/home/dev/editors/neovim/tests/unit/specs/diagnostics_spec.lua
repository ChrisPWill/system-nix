local source = debug.getinfo(1, "S").source:sub(2)
local specs_dir = vim.fs.dirname(source)
local unit_dir = vim.fs.dirname(specs_dir)
local config_root = vim.fs.dirname(vim.fs.dirname(unit_dir)) .. "/config/lua"
package.path = unit_dir .. "/?.lua;" .. config_root .. "/?.lua;" .. config_root .. "/?/init.lua;" .. package.path

local h = require("helpers")
local diagnostics = require("utils.treesitter.diagnostics")

local ns = vim.api.nvim_create_namespace("treesitter_smells")

local function messages(bufnr)
	diagnostics.refresh(bufnr)
	local ds = vim.diagnostic.get(bufnr, { namespace = ns })
	local out = {}
	for _, d in ipairs(ds) do
		table.insert(out, d.message)
	end
	table.sort(out)
	return out, ds
end

-- Regression: Kotlin's catch_block holds the exception parameter *and*
-- the body braces directly, with no separate block child the way JS's
-- catch_clause has — the empty-body check needs a fallback path for
-- that shape, or it silently finds nothing to inspect.
local catch_bufnr = h.load_fixture("kotlin/empty_catch.kt")
local catch_msgs, catch_ds = messages(catch_bufnr)
h.assert_equal(#catch_msgs, 1, "should flag exactly one empty catch block")
h.assert_true(catch_msgs[1]:find("Empty catch", 1, true) ~= nil, "message should mention the empty catch")
h.assert_equal(catch_ds[1].severity, vim.diagnostic.severity.WARN, "empty catch should be WARN")

-- Too many parameters.
local params_bufnr = h.load_fixture("kotlin/too_many_params.kt")
local params_msgs, params_ds = messages(params_bufnr)
h.assert_equal(#params_msgs, 1, "should flag the 6-parameter function")
h.assert_true(params_msgs[1]:find("6 parameters", 1, true) ~= nil, "message should report the actual count")
h.assert_equal(params_ds[1].severity, vim.diagnostic.severity.HINT, "too-many-params should be HINT")

-- Regression: nesting depth must count the real if_expression levels
-- only, once per crossing of the threshold — not the bare "if" keyword
-- token nested inside each if_expression as a spurious extra level,
-- which used to double the effective depth and report twice.
local nest_bufnr = h.load_fixture("kotlin/deep_nesting.kt")
local nest_msgs = messages(nest_bufnr)
h.assert_equal(#nest_msgs, 1, "should flag deep nesting exactly once, not once per level beyond the threshold")

-- Missing catch-all arm — and, just as importantly, a `when` that DOES
-- have one must not be flagged (regression: `is_branch_node` used to
-- also match Kotlin's when_entry/when_condition, which share the
-- "when" prefix without being the branch construct, causing this to
-- fire on every arm of every `when`, `else` or not).
local arm_bufnr = h.load_fixture("kotlin/missing_arm.kt")
local arm_msgs = messages(arm_bufnr)
h.assert_equal(#arm_msgs, 1, "should flag only noDefault's when, not hasDefault's")
h.assert_true(arm_msgs[1]:find("catch%-all") ~= nil, "message should mention the missing catch-all")

-- Rust edge case: a match with a real wildcard arm must not be flagged.
local rust_bufnr = h.load_fixture("rust/match_wildcard.rs")
local rust_msgs = messages(rust_bufnr)
h.assert_equal(#rust_msgs, 0, "a match with a wildcard arm should not be flagged")

-- Regression: vim.treesitter.get_parser can return ok=true, parser=nil
-- (not an error) for special buffers like a picker's preview buffer —
-- refresh() must not crash trying to call :parse() on that nil.
local scratch_bufnr = vim.api.nvim_create_buf(false, true)
vim.bo[scratch_bufnr].buftype = "nofile"
local ok = pcall(diagnostics.refresh, scratch_bufnr)
h.assert_true(ok, "refresh must not crash on a buffer with no attachable parser")

print("diagnostics_spec: all assertions passed")
