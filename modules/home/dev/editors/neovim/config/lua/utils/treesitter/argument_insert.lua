-- Finds where a new argument/parameter should go in the call or function
-- signature the cursor is in (or is inside the body of), inserts whatever
-- separator is needed, and drops the cursor there ready to type — no
-- hunting for the closing paren or hand-managing commas.
local scope = require("utils.treesitter.scope")

local M = {}

-- Plural/container list types ("arguments", "value_arguments",
-- "parameters", "function_value_parameters", ...) — not the singular
-- per-item wrapper some grammars use (Kotlin's "value_argument"), which
-- climbing hits first and a bare substring match would mistake for the
-- list itself.
local LIST_PATTERNS = { "arguments", "parameters", "argument_list", "parameter_list" }

-- Kotlin's primary constructor (`class Foo(val a: Int)`) holds its
-- parameters directly, with no "parameters"-named wrapper.
local LIST_EXACT_TYPES = { primary_constructor = true }

local function is_list_node(node)
	local ntype = node:type()
	if LIST_EXACT_TYPES[ntype] then
		return true
	end
	-- A generic type-parameter list (`<T, U>`) also matches "parameter"
	-- but isn't a place a value goes.
	if ntype:find("type_parameter") then
		return false
	end
	return scope.matches_any(ntype, LIST_PATTERNS)
end

--- Walk up from `node` to the nearest enclosing argument/parameter list.
---@param node TSNode
---@return TSNode?
function M.find_enclosing_list(node)
	return scope.find_enclosing(node, is_list_node)
end

-- The list in `node`'s own signature: a direct child, or one level
-- deeper, but never inside a block-like child — otherwise this could
-- wander into a function's body and find an unrelated call's arguments.
local function find_signature_list(node)
	for child in node:iter_children() do
		if is_list_node(child) then
			return child
		end
	end
	for child in node:iter_children() do
		if not scope.is_block_node(child) then
			local found = find_signature_list(child)
			if found then
				return found
			end
		end
	end
	return nil
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
	return enclosing_scope and find_signature_list(enclosing_scope)
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
