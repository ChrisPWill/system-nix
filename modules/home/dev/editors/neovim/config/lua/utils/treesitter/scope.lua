-- Shared "what kind of construct is this node" logic, used by every
-- treesitter feature that needs to categorize nodes generically (find the
-- function enclosing a node, list declarations for an outline, ...).
local M = {}

-- Node type substrings that mark a function-like scope. Kept generic
-- (rather than an explicit per-language node list) so this works across
-- whatever treesitter grammar is active.
local FUNCTION_PATTERNS = { "function", "method", "lambda" }

-- Node type substrings that mark a type/class-like declaration: class,
-- struct, interface, enum, trait, impl block, or Kotlin/Rust's `object`
-- singleton/expression.
local CLASS_PATTERNS = { "class", "struct", "interface", "enum", "trait", "impl", "object" }

-- A node's type containing a stem word like "function" isn't enough on its
-- own: `function_body` and `function_value_parameters` contain "function"
-- too, and a bare keyword token's type is literally "class"/"fun" etc. This
-- suffix marks the node as an actual declaration/definition, not one of
-- its substructures or a keyword leaf.
local DECLARATION_SUFFIXES = { "_declaration", "_definition", "_item" }

-- Anonymous closure-literal node types don't follow the declaration-suffix
-- convention above (there's no enclosing "declaration" — the literal *is*
-- the whole node), but they're still genuine function scopes (a TS arrow
-- function's body, a Kotlin lambda's body, ...), so they're allowed through
-- by exact type match instead.
local ANONYMOUS_FUNCTION_TYPES = {
	arrow_function = true,
	lambda_expression = true,
	lambda_literal = true,
	function_expression = true,
	anonymous_function = true,
}

local function has_stem(ntype, patterns)
	for _, pattern in ipairs(patterns) do
		if ntype:find(pattern) then
			return true
		end
	end
	return false
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
	local current = node
	while current do
		if M.is_function_node(current) then
			return current
		end
		current = current:parent()
	end
	return nil
end

-- Node type substrings for a "flat statement list" container: a function
-- body, a class body, a plain `{ }` block, the whole file, or (Markdown)
-- a heading's `section`, which nests recursively and can otherwise swallow
-- almost a whole document before this stops it. A node whose *parent* is
-- one of these is a top-level statement within it.
local BLOCK_PATTERNS = { "block", "body", "statements", "program", "source_file", "section" }

function M.is_block_node(node)
	-- The tree root is always a flat statement container, whatever its type
	-- happens to be named (Lua: "chunk", Python: "module", C:
	-- "translation_unit", ...) — checking parent-less-ness here means we
	-- don't have to keep enumerating every grammar's root node name, and a
	-- root name we haven't seen before can't silently fall through to
	-- "climb past the whole file" the way BLOCK_PATTERNS alone would.
	if not node:parent() then
		return true
	end
	return has_stem(node:type(), BLOCK_PATTERNS)
end

--- Walk up from `node` to the statement that directly contains it within
--- its nearest enclosing block — i.e. as far as "the whole logical
--- statement this belongs to", but no further (never up into e.g. the
--- whole enclosing function). Useful for expanding a narrow range (a diff
--- hunk, a single token) to what it's structurally part of, without also
--- swallowing everything else living in the same function/class.
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

return M
