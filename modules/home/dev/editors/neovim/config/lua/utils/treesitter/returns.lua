local scope = require("utils.treesitter.scope")
local motion = require("utils.treesitter.motion")
local highlight = require("utils.treesitter.highlight").new("returns")

local M = {}

-- Languages whose grammar treats a block's trailing expression as an
-- implicit return (no `return` keyword). Everything else relies purely on
-- explicit `return`-shaped nodes.
local IMPLICIT_RETURN_LANGS = { rust = true, ruby = true }

-- Kept as a thin re-export: existing callers (and this file) refer to
-- `M.find_enclosing_function`; the logic itself is shared with other
-- treesitter features via utils.treesitter.scope.
M.find_enclosing_function = scope.find_enclosing_function

-- Depth-first collection of explicit `return`-shaped nodes belonging to
-- `node`, without descending into nested function-like nodes (their returns
-- belong to them, not to the enclosing function).
local function collect_explicit_returns(node, results)
	for child in node:iter_children() do
		if scope.is_function_node(child) then
			goto continue
		end
		if child:type():find("return") then
			table.insert(results, child)
		else
			collect_explicit_returns(child, results)
		end
		::continue::
	end
end

-- Follow a tail expression down through `if`/`match`-style branches so each
-- branch contributes its own implicit return position, rather than
-- highlighting the whole wrapping expression as a single blob.
local function collect_tail_expressions(node, results)
	local ntype = node:type()
	if ntype:find("if") or ntype:find("match") or ntype:find("case") then
		for child in node:iter_children() do
			if child:named() and (child:type():find("block") or child:type():find("arm") or child:type():find("body")) then
				collect_tail_expressions(child, results)
			end
		end
		return
	end
	table.insert(results, node)
end

-- For implicit-return languages, the function's return value (when no
-- explicit `return` was found) is whatever its body block evaluates to: the
-- last named child, unless that's already a statement with no value.
local function collect_implicit_return(fn_node, lang, results)
	if not IMPLICIT_RETURN_LANGS[lang] then
		return
	end

	local body = fn_node:field("body")[1]
	if not body then
		for child in fn_node:iter_children() do
			if child:type():find("block") then
				body = child
				break
			end
		end
	end
	if not body then
		return
	end

	local last = body:named_child(body:named_child_count() - 1)
	if not last or last:type():find("return") then
		return
	end
	collect_tail_expressions(last, results)
end

--- Find the return positions belonging to the function enclosing `node`:
--- explicit `return` statements, or (for languages like Rust/Ruby where the
--- grammar has no `return` keyword for the common case) the implicit
--- tail-expression return.
---
--- Exposed standalone so other features (e.g. the return-position motion
--- below) can reuse it without re-highlighting.
---@param bufnr integer? defaults to the current buffer
---@param node TSNode? node to search from; defaults to the node under the cursor
---@return TSNode? fn_node the enclosing function-like node, or nil if none was found
---@return TSNode[] returns the return-position nodes, possibly empty
function M.find_return_positions(bufnr, node)
	bufnr = bufnr or vim.api.nvim_get_current_buf()
	node = node or vim.treesitter.get_node({ bufnr = bufnr })
	if not node then
		return nil, {}
	end

	local fn_node = M.find_enclosing_function(node)
	if not fn_node then
		return nil, {}
	end

	local results = {}
	collect_explicit_returns(fn_node, results)

	if #results == 0 then
		local lang = vim.treesitter.language.get_lang(vim.bo[bufnr].filetype) or vim.bo[bufnr].filetype
		collect_implicit_return(fn_node, lang, results)
	end

	return fn_node, results
end

--- Highlight every return position in the function enclosing the cursor.
--- The highlight clears automatically once the cursor leaves that
--- function's line range.
---@param bufnr integer? defaults to the current buffer
function M.highlight_return_positions(bufnr)
	bufnr = bufnr or vim.api.nvim_get_current_buf()

	local fn_node, returns = M.find_return_positions(bufnr)
	if not fn_node then
		vim.notify("No enclosing function found", vim.log.levels.WARN, { title = "Treesitter returns" })
		return
	end
	if #returns == 0 then
		vim.notify("No return positions found in this function", vim.log.levels.INFO, { title = "Treesitter returns" })
		return
	end

	highlight.apply(bufnr, "TreesitterReturnHighlight", returns, fn_node)
end

--- Move the cursor to the next return position in the enclosing function.
---@param bufnr integer? defaults to the current buffer
function M.goto_next_return(bufnr)
	bufnr = bufnr or vim.api.nvim_get_current_buf()
	local fn_node, returns = M.find_return_positions(bufnr)
	if not fn_node then
		vim.notify("No enclosing function found", vim.log.levels.WARN, { title = "Treesitter returns" })
		return
	end
	motion.goto_nearest(returns, "next", "return position")
end

--- Move the cursor to the previous return position in the enclosing function.
---@param bufnr integer? defaults to the current buffer
function M.goto_previous_return(bufnr)
	bufnr = bufnr or vim.api.nvim_get_current_buf()
	local fn_node, returns = M.find_return_positions(bufnr)
	if not fn_node then
		vim.notify("No enclosing function found", vim.log.levels.WARN, { title = "Treesitter returns" })
		return
	end
	motion.goto_nearest(returns, "previous", "return position")
end

return M
