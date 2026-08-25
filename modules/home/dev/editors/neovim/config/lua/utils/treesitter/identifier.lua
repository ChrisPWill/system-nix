-- Resolving "the identifier this node is really about" — shared by any
-- feature that needs the binding behind a possibly-composite expression
-- (mutation-site lookup today; a future rename/reference helper likely).
local M = {}

--- If `node` is itself an identifier, return it. Otherwise search its
--- direct children for one, preferring the last match (e.g. `count` in a
--- `self.count` member/field access — the last identifier child is the
--- actual binding being read or written, the earlier ones are the path to
--- it).
---@param node TSNode?
---@return TSNode?
function M.resolve(node)
	if not node then
		return nil
	end
	if node:type():find("identifier") then
		return node
	end

	local last
	for child in node:iter_children() do
		if child:type():find("identifier") then
			last = child
		end
	end
	return last
end

return M
