-- Cursor-relative node navigation — shared by any "jump to the next/
-- previous X" feature built on a list of TSNodes (return positions today;
-- mutation sites or similar are likely future callers).
local M = {}

--- 0-indexed (row, col) of the cursor in the current window, matching
--- TSNode:range()'s coordinate space.
---@return integer row
---@return integer col
function M.cursor_pos()
	local cursor = vim.api.nvim_win_get_cursor(0)
	return cursor[1] - 1, cursor[2]
end

--- Move the cursor to the start of `node`.
---@param node TSNode
function M.move_to(node)
	local srow, scol = node:range()
	vim.api.nvim_win_set_cursor(0, { srow + 1, scol })
end

local function by_position(a, b)
	local arow, acol = a:range()
	local brow, bcol = b:range()
	return arow < brow or (arow == brow and acol < bcol)
end

--- Move the cursor to whichever of `nodes` is nearest after the cursor
--- (`direction = "next"`) or before it (`direction = "previous"`),
--- notifying via `label` (e.g. "return position") when none qualifies.
---@param nodes TSNode[]
---@param direction "next"|"previous"
---@param label string used only for the "nothing found" notification
function M.goto_nearest(nodes, direction, label)
	if #nodes == 0 then
		vim.notify("No " .. label .. " found", vim.log.levels.INFO, { title = "Treesitter motion" })
		return
	end

	-- Sort a copy so callers' lists (and any order they rely on elsewhere,
	-- e.g. highlighting) aren't mutated by this lookup.
	local sorted = {}
	for i, node in ipairs(nodes) do
		sorted[i] = node
	end
	table.sort(sorted, by_position)

	local crow, ccol = M.cursor_pos()
	if direction == "next" then
		for _, node in ipairs(sorted) do
			local srow, scol = node:range()
			if srow > crow or (srow == crow and scol > ccol) then
				M.move_to(node)
				return
			end
		end
	else
		for i = #sorted, 1, -1 do
			local srow, scol = sorted[i]:range()
			if srow < crow or (srow == crow and scol < ccol) then
				M.move_to(sorted[i])
				return
			end
		end
	end
	vim.notify("No " .. direction .. " " .. label, vim.log.levels.INFO, { title = "Treesitter motion" })
end

return M
