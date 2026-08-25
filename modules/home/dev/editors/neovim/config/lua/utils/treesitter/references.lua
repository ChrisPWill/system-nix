-- Illuminate-style reference highlighting: every other occurrence of the
-- identifier under the cursor, refreshed ambiently on CursorHold rather
-- than a keypress — a passive aid, not something you invoke. Scoped like
-- mutations.lua: the enclosing function if there is one, else the whole
-- buffer, so a same-named local in an unrelated sibling function doesn't
-- light up too.
local scope = require("utils.treesitter.scope")
local identifier = require("utils.treesitter.identifier")
local motion = require("utils.treesitter.motion")

local M = {}

local ns = vim.api.nvim_create_namespace("treesitter_references")

-- Underline only, no background: the cursor already marks this spot, so
-- it just needs a light touch — the background on "other" is what's
-- meant to catch your eye elsewhere.
vim.api.nvim_set_hl(0, "TreesitterReferenceCurrent", { underline = true, default = true })
vim.api.nvim_set_hl(0, "TreesitterReferenceOther", { link = "IncSearch", default = true })

local function clear(bufnr)
	vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)
end

local function key_for(node)
	local srow, scol, erow, ecol = node:range()
	return string.format("%d:%d:%d:%d", srow, scol, erow, ecol)
end

-- Depth-first collection of every identifier-shaped node under `node`
-- with the given `name`, excluding `current_key` (the occurrence under
-- the cursor, tracked separately for its own highlight).
local function collect_references(node, name, bufnr, current_key, results)
	for child in node:iter_children() do
		if child:type():find("identifier") and vim.treesitter.get_node_text(child, bufnr) == name then
			if key_for(child) ~= current_key then
				table.insert(results, child)
			end
		end
		collect_references(child, name, bufnr, current_key, results)
	end
end

--- Find every other occurrence of the identifier at `node`, scoped to its
--- enclosing function (or the whole buffer for a module-level name).
---@param bufnr integer? defaults to the current buffer
---@param node TSNode? defaults to the node under the cursor
---@return TSNode? current the resolved identifier under the cursor
---@return TSNode[] others every other matching occurrence in scope
function M.find_references(bufnr, node)
	bufnr = bufnr or vim.api.nvim_get_current_buf()
	node = node or vim.treesitter.get_node({ bufnr = bufnr })
	if not node then
		return nil, {}
	end

	local current = identifier.resolve(node) or identifier.resolve(node:parent())
	if not current then
		return nil, {}
	end
	local name = vim.treesitter.get_node_text(current, bufnr)

	local root = scope.find_enclosing_function(current)
	if not root then
		local parser = vim.treesitter.get_parser(bufnr)
		root = parser and parser:parse()[1]:root()
	end
	if not root then
		return current, {}
	end

	local results = {}
	collect_references(root, name, bufnr, key_for(current), results)
	return current, results
end

--- Recompute the reference highlight for `bufnr` from the identifier
--- under the cursor. A no-op (after clearing) when there's no identifier
--- under the cursor or no parser attached.
---@param bufnr integer? defaults to the current buffer
function M.refresh(bufnr)
	bufnr = bufnr or vim.api.nvim_get_current_buf()
	clear(bufnr)

	if not pcall(vim.treesitter.get_parser, bufnr) then
		return
	end

	local current, others = M.find_references(bufnr)
	if not current then
		return
	end

	local srow, scol, erow, ecol = current:range()
	vim.hl.range(bufnr, ns, "TreesitterReferenceCurrent", { srow, scol }, { erow, ecol })

	for _, node in ipairs(others) do
		local osrow, oscol, oerow, oecol = node:range()
		vim.hl.range(bufnr, ns, "TreesitterReferenceOther", { osrow, oscol }, { oerow, oecol })
	end
end

--- Move the cursor to the next/previous occurrence of the identifier
--- under the cursor (see find_references for scoping).
---@param bufnr integer? defaults to the current buffer
---@param direction "next"|"previous"
local function goto_reference(bufnr, direction)
	bufnr = bufnr or vim.api.nvim_get_current_buf()
	local current, others = M.find_references(bufnr)
	if not current then
		vim.notify("No identifier under cursor", vim.log.levels.WARN, { title = "Treesitter references" })
		return
	end
	table.insert(others, current)
	motion.goto_nearest(others, direction, "reference")
end

function M.goto_next_reference(bufnr)
	goto_reference(bufnr, "next")
end

function M.goto_previous_reference(bufnr)
	goto_reference(bufnr, "previous")
end

-- Ambient trigger: clear immediately on movement so stale highlights
-- don't linger, then recompute once the cursor settles (CursorHold fires
-- after 'updatetime' ms of no movement — the same debounce illuminate
-- itself relies on, no manual timer needed).
local augroup = vim.api.nvim_create_augroup("TreesitterReferences", { clear = true })

vim.api.nvim_create_autocmd("CursorMoved", {
	group = augroup,
	callback = function(args)
		clear(args.buf)
	end,
})

vim.api.nvim_create_autocmd("CursorHold", {
	group = augroup,
	callback = function(args)
		M.refresh(args.buf)
	end,
})

return M
