local scope = require("utils.treesitter.scope")

local M = {}

--- The declaration's own header line — trimmed, single line — starting
-- from its `fun`/`class`/... keyword rather than any metadata above it.
---@param bufnr integer
---@param node TSNode
---@return string text
---@return integer row 0-indexed
local function header_line(bufnr, node)
	local header_node = scope.skip_leading_metadata(node)
	local srow = header_node:range()
	local line = vim.api.nvim_buf_get_lines(bufnr, srow, srow + 1, false)[1] or ""
	local trimmed = line:gsub("^%s+", ""):gsub("%s+$", "")
	return trimmed, srow
end

-- Depth-first walk collecting every function/class-like declaration,
-- flat but tagged with its nesting `depth` so a picker can indent entries
-- to show structure (a method nested under its class, etc.). Recurses
-- into every node regardless of kind — a class's methods, and a
-- function's nested closures, are all still worth listing.
local function collect(bufnr, node, depth, results)
	for child in node:iter_children() do
		local kind
		if scope.is_function_node(child) then
			kind = "function"
		elseif scope.is_class_node(child) then
			kind = "class"
		end

		if kind then
			local text, row = header_line(bufnr, child)
			table.insert(results, {
				-- Deliberately no `node` (TSNode userdata) field here: a
				-- Snacks picker deepcopies its items, and deepcopy on a
				-- TSNode errors. `row` already has what navigation needs.
				--
				-- `buf` + `pos` are Snacks' own item-location fields, so its
				-- default previewer shows the real source (from the live
				-- buffer, unsaved edits included) instead of falling back
				-- to dumping the item table.
				bufnr = bufnr,
				buf = bufnr,
				pos = { row + 1, 0 },
				kind = kind,
				depth = depth,
				text = text,
				row = row,
			})
			collect(bufnr, child, depth + 1, results)
		else
			collect(bufnr, child, depth, results)
		end
	end
end

--- List every function/class-like declaration in `bufnr`, in document
--- order, each entry annotated with its nesting depth.
---@param bufnr integer? defaults to the current buffer
---@return { bufnr: integer, kind: "function"|"class", depth: integer, text: string, row: integer }[]
function M.list(bufnr)
	bufnr = bufnr or vim.api.nvim_get_current_buf()
	local parser = vim.treesitter.get_parser(bufnr)
	if not parser then
		return {}
	end

	local root = parser:parse()[1]:root()
	local results = {}
	collect(bufnr, root, 0, results)
	return results
end

return M
