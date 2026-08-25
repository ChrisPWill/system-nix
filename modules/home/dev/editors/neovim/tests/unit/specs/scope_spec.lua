local source = debug.getinfo(1, "S").source:sub(2)
local specs_dir = vim.fs.dirname(source)
local unit_dir = vim.fs.dirname(specs_dir)
local config_root = vim.fs.dirname(vim.fs.dirname(unit_dir)) .. "/config/lua"
package.path = unit_dir .. "/?.lua;" .. config_root .. "/?.lua;" .. config_root .. "/?/init.lua;" .. package.path

local h = require("helpers")
local scope = require("utils.treesitter.scope")

-- TSNode has no stable identity/equality method beyond comparing ranges;
-- these two turn a node into something assert_equal can compare, and
-- avoid range()'s multiple return values silently truncating to just
-- the first when passed straight into assert_equal.
local function range_str(node)
	return table.concat({ node:range() }, ":")
end

local function find_type(node, ntype)
	if node:type() == ntype then
		return node
	end
	for child in node:iter_children() do
		local found = find_type(child, ntype)
		if found then
			return found
		end
	end
	return nil
end

local function find_containing(node, ntype, substring, source_bufnr)
	if node:type() == ntype then
		local text = vim.treesitter.get_node_text(node, source_bufnr)
		if text:find(substring, 1, true) then
			return node
		end
	end
	for child in node:iter_children() do
		local found = find_containing(child, ntype, substring, source_bufnr)
		if found then
			return found
		end
	end
	return nil
end

-- is_function_node/is_class_node: a function/class's own substructures
-- (its body, its parameter list) share the same stem word but aren't the
-- declaration itself.
local bufnr = h.load_fixture("kotlin/nested_declarations.kt")
local root = vim.treesitter.get_parser(bufnr):parse()[1]:root()

local class_decl = find_type(root, "class_declaration")
local fn_decl = find_type(root, "function_declaration")
local fn_body = find_type(root, "function_body")
local primary_ctor = find_type(root, "primary_constructor")

h.assert_true(scope.is_class_node(class_decl), "class_declaration should be a class node")
h.assert_true(scope.is_function_node(fn_decl), "function_declaration should be a function node")
h.assert_true(not scope.is_function_node(fn_body), "function_body is a substructure, not the function itself")

-- Regression: find_signature_list must recognize Kotlin's primary
-- constructor (holds params directly, no separate "parameters" node).
local sig_list = scope.find_signature_list(class_decl)
h.assert_true(sig_list ~= nil, "find_signature_list should find something for the class")
h.assert_equal(range_str(sig_list), range_str(primary_ctor), "find_signature_list should find the primary constructor")

-- Regression: is_if_node/is_branch_node must require an actual
-- construct-shaped suffix, not just a prefix — otherwise the bare
-- anonymous "if" keyword token (inside its own if_expression) and
-- Kotlin's when_entry/when_condition (which share the "when" prefix
-- with when_expression without being it) would also match.
local if_bufnr = h.load_fixture("kotlin/if_when_chain.kt")
local if_root = vim.treesitter.get_parser(if_bufnr):parse()[1]:root()
local if_expr = find_type(if_root, "if_expression")
local when_expr = find_type(if_root, "when_expression")
local when_entry = find_type(if_root, "when_entry")

h.assert_true(scope.is_if_node(if_expr), "if_expression should be an if node")
h.assert_true(scope.is_branch_node(when_expr), "when_expression should be a branch node")
h.assert_true(not scope.is_branch_node(when_entry), "when_entry shares the 'when' prefix but is not the branch construct")

-- The bare "if" keyword token itself (if_expression's first child) must
-- not independently count as another nesting level.
local bare_if_token
for child in if_expr:iter_children() do
	if child:type() == "if" then
		bare_if_token = child
		break
	end
end
h.assert_true(bare_if_token ~= nil, "expected to find the bare 'if' keyword token")
h.assert_true(not scope.is_if_node(bare_if_token), "the bare 'if' keyword token must not itself count as an if node")

-- Regression: is_block_node/find_enclosing_statement must treat the tree
-- root as block-like regardless of its grammar-specific name (Lua's is
-- "chunk", not "block"/"source_file"), or climbing falls through to
-- "the whole file" instead of stopping at the enclosing statement.
local lua_bufnr = h.load_fixture("lua/module_assignments.lua")
local lua_root = vim.treesitter.get_parser(lua_bufnr):parse()[1]:root()
h.assert_equal(lua_root:type(), "chunk", "sanity check: Lua's root node is called 'chunk'")

-- `local M = {}` is itself wrapped in an assignment_statement too, so
-- searching by type alone would grab that one instead of `M.foo = ...`
-- — search by content to get the one actually intended.
local assignment = find_containing(lua_root, "assignment_statement", "foo", lua_bufnr)
h.assert_true(assignment ~= nil, "expected to find the M.foo assignment")
local stmt = scope.find_enclosing_statement(assignment)
h.assert_equal(range_str(stmt), range_str(assignment), "enclosing statement should be the assignment itself, not the whole chunk")

-- Regression: Markdown's `section` nests recursively (a top-level
-- heading's section can span almost the whole document) and needs to be
-- recognized as block-like too, or a change inside one paragraph climbs
-- all the way out to "the whole section".
local md_bufnr = h.load_fixture("markdown/nested_sections.md")
local md_root = vim.treesitter.get_parser(md_bufnr):parse(true)[1]:root()
local paragraph = find_type(md_root, "paragraph")
h.assert_true(paragraph ~= nil, "expected to find a paragraph node")
local md_stmt = scope.find_enclosing_statement(paragraph)
h.assert_equal(md_stmt:type(), "paragraph", "enclosing statement in Markdown should stop at the paragraph, not balloon out to the whole section")

-- node_at_line: nil for a blank line, since there's nothing there to
-- anchor a node to.
local blank_bufnr = h.load_fixture("lua/blank_line.lua")
h.assert_nil(scope.node_at_line(blank_bufnr, 1), "node_at_line should be nil on a blank line")
h.assert_true(scope.node_at_line(blank_bufnr, 0) ~= nil, "node_at_line should find a node on a non-blank line")

print("scope_spec: all assertions passed")
