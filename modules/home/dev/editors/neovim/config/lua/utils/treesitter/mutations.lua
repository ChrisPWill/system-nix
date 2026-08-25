local scope = require("utils.treesitter.scope")
local identifier = require("utils.treesitter.identifier")
local highlight = require("utils.treesitter.highlight").new("mutations")

local M = {}

-- Node type substrings for nodes that write to a target: plain/augmented
-- assignment (`x = 1`, `x += 1`) and increment/decrement (`x++`). Kept
-- generic rather than an explicit per-language node list, same rationale as
-- utils.treesitter.scope. Variable *declarations* (e.g. `local x = 1`,
-- `let x = 1`) are deliberately excluded: they introduce the binding rather
-- than mutate an existing one.
local MUTATION_PATTERNS = { "assignment", "update_expression" }

-- Field names that might hold the write target, checked in order. Falls
-- back to the first named child if none of these fields exist.
local TARGET_FIELDS = { "left", "target" }

local function is_mutation_node(node)
	local ntype = node:type()
	for _, pattern in ipairs(MUTATION_PATTERNS) do
		if ntype:find(pattern) then
			return true
		end
	end
	return false
end

local function get_target(node)
	for _, field in ipairs(TARGET_FIELDS) do
		local target = node:field(field)[1]
		if target then
			return target
		end
	end
	return node:named_child(0)
end

-- Depth-first collection of mutation nodes targeting `name`. Deliberately
-- descends into nested function-like nodes too: a closure capturing and
-- mutating an outer variable (e.g. Kotlin's `list.forEach { x += it }`) is a
-- genuine mutation site of that variable, not something to hide. This has
-- no shadowing awareness, so a nested function's own same-named local would
-- also match; that's a rare false positive traded for not missing captures.
local function collect_mutations(node, name, bufnr, results)
	for child in node:iter_children() do
		if is_mutation_node(child) then
			local ident = identifier.resolve(get_target(child))
			if ident and vim.treesitter.get_node_text(ident, bufnr) == name then
				table.insert(results, child)
			end
		end
		collect_mutations(child, name, bufnr, results)
	end
end

--- Find the mutation sites (assignment/augmented-assignment/increment) of
--- the identifier at `node`, within its enclosing function.
---
--- Exposed standalone so other features can reuse it without
--- re-highlighting.
---@param bufnr integer? defaults to the current buffer
---@param node TSNode? node to start from; defaults to the node under the cursor
---@return TSNode? ident_node the resolved identifier node, or nil if none was found under the cursor
---@return TSNode[] mutations the mutation-site nodes, possibly empty
---@return TSNode? search_scope the node mutations were searched within (enclosing function, or the whole buffer)
function M.find_mutation_sites(bufnr, node)
	bufnr = bufnr or vim.api.nvim_get_current_buf()
	node = node or vim.treesitter.get_node({ bufnr = bufnr })
	if not node then
		return nil, {}
	end

	local ident = identifier.resolve(node) or identifier.resolve(node:parent())
	if not ident then
		return nil, {}
	end
	local name = vim.treesitter.get_node_text(ident, bufnr)

	-- Fall back to the whole buffer when there's no enclosing function
	-- (e.g. a module-level variable), rather than finding nothing.
	local search_scope = scope.find_enclosing_function(ident)
	local root = search_scope
	if not root then
		local parser = vim.treesitter.get_parser(bufnr)
		root = parser and parser:parse()[1]:root()
	end
	if not root then
		return ident, {}
	end

	local results = {}
	collect_mutations(root, name, bufnr, results)
	return ident, results, search_scope
end

--- Highlight every mutation site of the identifier under the cursor, within
--- its enclosing function (or the whole buffer, for module-level names).
--- The highlight clears automatically once the cursor leaves that range.
---@param bufnr integer? defaults to the current buffer
function M.highlight_mutation_sites(bufnr)
	bufnr = bufnr or vim.api.nvim_get_current_buf()

	local ident, mutations, search_scope = M.find_mutation_sites(bufnr)
	if not ident then
		vim.notify("No identifier found under cursor", vim.log.levels.WARN, { title = "Treesitter mutations" })
		return
	end
	if #mutations == 0 then
		vim.notify("No mutation sites found", vim.log.levels.INFO, { title = "Treesitter mutations" })
		return
	end

	local range_node = search_scope or mutations[1]:tree():root()
	highlight.apply(bufnr, "TreesitterMutationHighlight", mutations, range_node)
end

return M
