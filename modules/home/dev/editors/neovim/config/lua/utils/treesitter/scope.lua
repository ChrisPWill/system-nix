-- Shared "what kind of construct is this node" logic: find the function
-- enclosing a node, categorize nodes generically, etc.
local M = {}

-- Generic across grammars, not a per-language node list.
local FUNCTION_PATTERNS = { "function", "method", "lambda" }
local CLASS_PATTERNS = { "class", "struct", "interface", "enum", "trait", "impl", "object" }

-- A stem word alone isn't enough: `function_body` contains "function" too,
-- and a bare keyword token's type is literally "class"/"fun". This suffix
-- marks an actual declaration, not one of its substructures or a keyword.
local DECLARATION_SUFFIXES = { "_declaration", "_definition", "_item" }

-- Closure literals (no enclosing "declaration" — the literal *is* the
-- whole node) don't follow the suffix convention above, so they're
-- allowed through by exact type instead.
local ANONYMOUS_FUNCTION_TYPES = {
	arrow_function = true,
	lambda_expression = true,
	lambda_literal = true,
	function_expression = true,
	anonymous_function = true,
}

--- Does `ntype` contain any of `patterns`? Exported for reuse by other
--- features doing their own substring categorization (e.g. the
--- argument/parameter-list detection behind smart argument insertion).
function M.matches_any(ntype, patterns)
	for _, pattern in ipairs(patterns) do
		if ntype:find(pattern) then
			return true
		end
	end
	return false
end
local has_stem = M.matches_any

--- Walk up from `node` (inclusive) to the nearest ancestor matching
--- `predicate`, or nil. The shape behind find_enclosing_function below,
--- reusable by any feature needing "the nearest ancestor matching X".
---@param node TSNode
---@param predicate fun(node: TSNode): boolean
---@return TSNode?
function M.find_enclosing(node, predicate)
	local current = node
	while current do
		if predicate(current) then
			return current
		end
		current = current:parent()
	end
	return nil
end

local function is_declaration_shaped(ntype)
	for _, suffix in ipairs(DECLARATION_SUFFIXES) do
		if ntype:sub(-#suffix) == suffix then
			return true
		end
	end
	return false
end

function M.is_function_node(node)
	local ntype = node:type()
	if ANONYMOUS_FUNCTION_TYPES[ntype] then
		return true
	end
	return is_declaration_shaped(ntype) and has_stem(ntype, FUNCTION_PATTERNS)
end

function M.is_class_node(node)
	local ntype = node:type()
	return is_declaration_shaped(ntype) and has_stem(ntype, CLASS_PATTERNS)
end

--- Walk up from `node` to the nearest enclosing function-like node.
---@param node TSNode
---@return TSNode?
function M.find_enclosing_function(node)
	return M.find_enclosing(node, M.is_function_node)
end

-- A "flat statement list" container: a function/class body, a plain
-- `{ }` block, the whole file, or (Markdown) a heading's `section`,
-- which nests and can otherwise swallow almost a whole document.
local BLOCK_PATTERNS = { "block", "body", "statements", "program", "source_file", "section" }

function M.is_block_node(node)
	-- The tree root is always block-like, whatever it's named (Lua:
	-- "chunk", Python: "module", ...) — this avoids enumerating every
	-- grammar's root name, and a name we haven't seen can't silently
	-- fall through to "climb past the whole file".
	if not node:parent() then
		return true
	end
	return has_stem(node:type(), BLOCK_PATTERNS)
end

--- Walk up from `node` to the statement directly containing it within its
--- nearest enclosing block — the whole logical statement, but no further
--- (never into the enclosing function). Used to expand a narrow range (a
--- diff hunk, a token) to what it's structurally part of.
---@param node TSNode
---@return TSNode
function M.find_enclosing_statement(node)
	local current = node
	while true do
		local parent = current:parent()
		if not parent or M.is_block_node(parent) then
			return current
		end
		current = parent
	end
end

--- The node at `row`'s first non-blank column, or nil for a blank line
--- (nothing there to anchor to).
---@param bufnr integer
---@param row integer 0-indexed
---@return TSNode?
function M.node_at_line(bufnr, row)
	local line = vim.api.nvim_buf_get_lines(bufnr, row, row + 1, false)[1] or ""
	local col = #line:match("^%s*")
	if col >= #line then
		return nil
	end
	return vim.treesitter.get_node({ bufnr = bufnr, pos = { row, col } })
end

-- Annotations/decorators/attributes that commonly precede a declaration
-- on their own line (Kotlin's `@ProviderMethod`, Java annotations, Rust
-- attributes, ...) and sit ahead of it in the tree — so a declaration's
-- own span starts at the metadata, not at its `fun`/`class` keyword.
local METADATA_PATTERNS = { "modifier", "annotation", "decorator", "attribute" }

function M.is_metadata_node(node)
	return has_stem(node:type(), METADATA_PATTERNS)
end

--- The first child of `node` that isn't leading metadata — i.e. its
--- actual `fun`/`class`/... keyword onward. Falls back to `node` itself
--- if every child looks like metadata.
---@param node TSNode
---@return TSNode
function M.skip_leading_metadata(node)
	for child in node:iter_children() do
		if not M.is_metadata_node(child) then
			return child
		end
	end
	return node
end

return M
