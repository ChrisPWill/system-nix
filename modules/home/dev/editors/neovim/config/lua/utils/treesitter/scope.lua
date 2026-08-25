-- Shared "what counts as a function-like scope" logic, used by every
-- treesitter feature that needs to find the function enclosing a node
-- (return highlighting, mutation-site highlighting, ...).
local M = {}

-- Node type substrings that mark a function-like scope. Kept generic
-- (rather than an explicit per-language node list) so this works across
-- whatever treesitter grammar is active.
local FUNCTION_PATTERNS = { "function", "method", "lambda", "arrow_function" }

function M.is_function_node(node)
	local ntype = node:type()
	for _, pattern in ipairs(FUNCTION_PATTERNS) do
		if ntype:find(pattern) then
			return true
		end
	end
	return false
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

return M
