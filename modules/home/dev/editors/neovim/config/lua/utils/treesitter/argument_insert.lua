-- Finds where a new argument/parameter should go in the call or function
-- signature the cursor is in (or is inside the body of), inserts whatever
-- separator is needed, and drops the cursor there ready to type — no
-- hunting for the closing paren or hand-managing commas.
local scope = require("utils.treesitter.scope")

local M = {}

--- Walk up from `node` to the nearest enclosing argument/parameter list.
---@param node TSNode
---@return TSNode?
function M.find_enclosing_list(node)
	return scope.find_enclosing(node, scope.is_list_node)
end

local function is_function_or_class(node)
	return scope.is_function_node(node) or scope.is_class_node(node)
end

--- The list to add an argument/parameter to for `node`'s position: the
--- list directly enclosing it, or — so this also works from inside a
--- function's body, not just its signature — the signature list of the
--- nearest enclosing function or class.
---@param node TSNode
---@return TSNode?
function M.find_target_list(node)
	local direct = M.find_enclosing_list(node)
	if direct then
		return direct
	end

	local enclosing_scope = scope.find_enclosing(node, is_function_or_class)
	return enclosing_scope and scope.find_signature_list(enclosing_scope)
end

-- Where a new argument/parameter goes, and what separator (if any) it
-- needs from whatever's already there.
---@param list_node TSNode
---@return integer row 0-indexed
---@return integer col 0-indexed
---@return "none"|"space_if_needed"|"comma_space" separator
local function insertion_point(list_node)
	local count = list_node:named_child_count()
	if count == 0 then
		-- `f(<here>)` needs nothing before the first argument.
		local srow, scol = list_node:range()
		return srow, scol + 1, "none"
	end

	local last = list_node:named_child(count - 1)
	local _, _, erow, ecol = last:range()

	-- An existing trailing comma (rustfmt's multi-line style, or a
	-- one-line `f(a,)`) needs the insertion *after* it, or we'd
	-- duplicate the comma.
	local sibling = last:next_sibling()
	if sibling and not sibling:named() and sibling:type() == "," then
		local _, _, srow2, scol2 = sibling:range()
		return srow2, scol2, "space_if_needed"
	end

	return erow, ecol, "comma_space"
end

--- Move the cursor to where a new argument/parameter should go — in the
--- call/signature enclosing the cursor, or the signature of the
--- function/class its enclosing body belongs to — inserting whatever
--- separator is needed, and enter insert mode there.
---@param bufnr integer? defaults to the current buffer
function M.insert_argument(bufnr)
	bufnr = bufnr or vim.api.nvim_get_current_buf()
	local node = vim.treesitter.get_node({ bufnr = bufnr })
	if not node then
		vim.notify("No node under cursor", vim.log.levels.WARN, { title = "Treesitter arguments" })
		return
	end

	local list_node = M.find_target_list(node)
	if not list_node then
		vim.notify("No call/parameter list found here", vim.log.levels.WARN, { title = "Treesitter arguments" })
		return
	end

	local row, col, separator = insertion_point(list_node)

	local text = ""
	if separator == "comma_space" then
		text = ", "
	elseif separator == "space_if_needed" then
		local next_char = vim.api.nvim_buf_get_text(bufnr, row, col, row, col + 1, {})[1] or ""
		if next_char ~= "" and not next_char:match("%s") then
			text = " "
		end
	end

	if text ~= "" then
		vim.api.nvim_buf_set_text(bufnr, row, col, row, col, { text })
	end

	-- startinsert first: Normal-mode cursor positioning clamps to the
	-- line's last character, but our target column is sometimes one past
	-- that (appending at eol) — only Insert mode allows it.
	vim.cmd("startinsert")
	vim.api.nvim_win_set_cursor(0, { row + 1, col + #text })
end

return M
