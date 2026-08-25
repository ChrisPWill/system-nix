local source = debug.getinfo(1, "S").source:sub(2)
local specs_dir = vim.fs.dirname(source)
local unit_dir = vim.fs.dirname(specs_dir)
local config_root = vim.fs.dirname(vim.fs.dirname(unit_dir)) .. "/config/lua"
package.path = unit_dir .. "/?.lua;" .. config_root .. "/?.lua;" .. config_root .. "/?/init.lua;" .. package.path

local h = require("helpers")
local outline = require("utils.treesitter.outline")

-- Regression: a declaration's own span starts at its leading metadata
-- (Kotlin's `@ProviderMethod` annotation), so without skipping past it,
-- the outline entry's text would be the annotation line, not the
-- `fun ...` signature.
local bufnr = h.load_fixture("kotlin/annotated_declarations.kt")

local items = outline.list(bufnr)
h.assert_equal(#items, 3, "should find the class, the annotated method, and the nested class")

local class_item, method_item, nested_item = items[1], items[2], items[3]
h.assert_equal(class_item.kind, "class", "first entry should be the outer class")
h.assert_equal(class_item.depth, 0, "outer class should be at depth 0")

h.assert_equal(method_item.kind, "function", "second entry should be the method")
h.assert_true(method_item.text:find("^fun provideThing") ~= nil, "method text should start at 'fun', not the annotation above it")
h.assert_equal(method_item.depth, 1, "method should be nested one level under the class")

h.assert_equal(nested_item.kind, "class", "third entry should be the nested class")
h.assert_equal(nested_item.depth, 1, "nested class should also be one level under the outer class")

-- Items must be deepcopy-safe (no TSNode userdata fields), since the
-- outline picker hands them to Snacks, which deepcopies its items.
for _, item in ipairs(items) do
	local ok = pcall(vim.deepcopy, item)
	h.assert_true(ok, "outline item must be deepcopy-safe")
end

print("outline_spec: all assertions passed")
