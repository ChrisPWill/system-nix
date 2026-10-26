-- Custom treesitter query predicates for queries under config/queries/.
local M = {}

function M.setup()
	-- Lets a query capture a whole file's root whatever the grammar made of
	-- it. Weak grammars (e.g. mermaid) produce an ERROR root for valid files
	-- and ERROR nodes nested anywhere, so matching ERROR alone isn't enough.
	vim.treesitter.query.add_predicate("is-root?", function(match, _, _, pred)
		local nodes = match[pred[2]]
		local node = type(nodes) == "table" and nodes[1] or nodes
		return node ~= nil and node:parent() == nil
	end, { force = true })
end

return M
