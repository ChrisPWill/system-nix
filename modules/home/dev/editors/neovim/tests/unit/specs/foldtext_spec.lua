local source = debug.getinfo(1, "S").source:sub(2)
local specs_dir = vim.fs.dirname(source)
local unit_dir = vim.fs.dirname(specs_dir)
local config_root = vim.fs.dirname(vim.fs.dirname(unit_dir)) .. "/config/lua"
package.path = unit_dir .. "/?.lua;" .. config_root .. "/?.lua;" .. config_root .. "/?/init.lua;" .. package.path

local h = require("helpers")
local foldtext = require("utils.treesitter.foldtext")

-- Regression: Kotlin's else-if chain has a bare `else` token followed by
-- a *sibling* control_structure_body wrapping the nested if_expression,
-- unlike grammars that wrap the nested if directly inside an
-- else_clause. Both branches of that chain need to show up.
local bufnr = h.load_fixture("kotlin/if_else_chain.kt")
local summary = foldtext.summarize(bufnr, 3, 9)
h.assert_true(summary:find("if (n > 10)", 1, true) ~= nil, "should show the if branch")
h.assert_true(summary:find("else if (n > 0)", 1, true) ~= nil, "should show the else-if branch, not just the first if")
h.assert_true(summary:find("} else {", 1, true) ~= nil, "should show the trailing else")

-- Regression: match arms sit one level below the branch node itself
-- (Rust wraps them in a match_block), so they need recursing into to
-- find — but the arm-holding wrapper (match_block) mustn't itself be
-- treated as a nested branch and skipped.
local rust_bufnr = h.load_fixture("rust/match_arms.rs")
local rust_summary = foldtext.summarize(rust_bufnr, 2, 6)
h.assert_true(rust_summary:find("match n {", 1, true) ~= nil, "should show the match subject")
h.assert_true(rust_summary:find('0 => "zero"', 1, true) ~= nil, "should show the first arm")
h.assert_true(rust_summary:find('_ => "negative"', 1, true) ~= nil, "should show the wildcard arm")

-- Regression: the summary must preserve the fold's actual leading
-- indentation. snacks.nvim's indent-guide module draws vertical guide
-- characters at fixed indent-width columns on every visible row
-- (closed folds included), assuming real whitespace is there to draw
-- into — a flush-left summary gets those guide characters drawn on top
-- of its own text instead.
local indent_bufnr = h.load_fixture("kotlin/indented_function.kt")
local indented_summary = foldtext.summarize(indent_bufnr, 2, 4)
h.assert_equal(indented_summary:match("^%s*"), "    ", "summary should preserve the fold's leading indentation")

print("foldtext_spec: all assertions passed")
