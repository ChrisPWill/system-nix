-- Structural fold summaries: instead of Neovim's default "12 lines
-- folded", synthesize a one-line summary from the folded node itself (a
-- function's signature, an if/else chain's branch structure, a match/when's
-- arms, ...). Wired up via `vim.opt.foldtext` in plugins/treesitter.lua.
local scope = require("utils.treesitter.scope")

local M = {}

-- `node:type():find("if")` (a plain substring search) would false-positive
-- on node types like "identifier" or "modifier", which happen to contain
-- "if" mid-word. Anchoring at the start avoids that.
local function starts_with_any(ntype, prefixes)
	for _, prefix in ipairs(prefixes) do
		if ntype:sub(1, #prefix) == prefix then
			return true
		end
	end
	return false
end

local IF_PREFIXES = { "if" }
-- match/when/switch-style multi-arm conditionals.
local BRANCH_PREFIXES = { "match", "when", "switch" }
local ARM_PATTERNS = { "arm", "case", "clause", "entry" }

local function is_if_node(node)
	return starts_with_any(node:type(), IF_PREFIXES)
end

local function is_branch_node(node)
	return starts_with_any(node:type(), BRANCH_PREFIXES)
end

local function is_arm_node(node)
	local ntype = node:type()
	for _, pattern in ipairs(ARM_PATTERNS) do
		if ntype:find(pattern) then
			return true
		end
	end
	return false
end

-- The literal first source line of `node`, trimmed of trailing whitespace.
-- Most summaries are just this: a function's signature line, an if's
-- condition line, a class header, etc.
--
-- Goes through vim.treesitter.get_node_text() rather than manually slicing
-- vim.api.nvim_buf_get_lines() at node:range()'s column: that's treesitter's
-- own authoritative rendering of the node's text, so it can't go wrong the
-- way hand-rolled column arithmetic can (see the gsub multi-value bug this
-- file already had).
local function first_line(bufnr, node)
	local text = vim.treesitter.get_node_text(node, bufnr)
	local line = text:match("^[^\n]*") or text
	-- `local` truncates gsub's (string, count) to just the string; returning
	-- the gsub call directly would splat both values into any caller that
	-- takes this as its final argument (e.g. table.insert(t, first_line(...))
	-- would receive the substitution count as a bogus third argument).
	local trimmed = line:gsub("%s+$", "")
	return trimmed
end

local function find_nested_if(node)
	if is_if_node(node) then
		return node
	end
	for child in node:iter_children() do
		if is_if_node(child) then
			return child
		end
	end
	return nil
end

-- Walk an if/else-if/else chain, collecting each branch's condition line.
-- A nested if inside an `else` gets a "} else " prefix so the chain reads
-- naturally as one line; a plain trailing else just closes with "} else {".
--
-- Grammars shape this differently: some wrap the nested if directly inside
-- an `else_clause` node; Kotlin instead has a bare `else` token followed by
-- a sibling `control_structure_body` that wraps the nested if_expression.
-- Handle both: look inside the "else"-ish node itself, and if that's a bare
-- token with nothing inside, look inside its following sibling instead.
local function collect_if_chain(bufnr, node, headers, prefix)
	table.insert(headers, (prefix or "") .. first_line(bufnr, node))

	local children = {}
	for child in node:iter_children() do
		table.insert(children, child)
	end

	local else_index
	for i, child in ipairs(children) do
		if child:type():find("^else") then
			else_index = i
			break
		end
	end
	if not else_index then
		return
	end

	local nested_if = find_nested_if(children[else_index])
	if not nested_if and children[else_index + 1] then
		nested_if = find_nested_if(children[else_index + 1])
	end

	if nested_if then
		collect_if_chain(bufnr, nested_if, headers, "} else ")
	else
		table.insert(headers, "} else {")
	end
end

-- Walk a match/when/switch's arms, collecting each arm's own header line
-- (its pattern/condition, up to its body). Arms usually sit one level
-- below the branch node itself (e.g. Rust wraps them in a `match_block`),
-- so this recurses through wrapper nodes to find them — but never
-- descends into an arm once found, which also means a match/when nested
-- inside one arm's body never has its own arms attributed to the outer
-- one (it's inside a boundary we don't cross).
--
-- Note this deliberately does NOT stop at `is_branch_node`: wrapper types
-- like Rust's `match_block` share the branch construct's own name prefix
-- (both start with "match"), so that check would also block recursing
-- into the very block holding the arms.
local function collect_arms(bufnr, node, headers)
	for child in node:iter_children() do
		if is_arm_node(child) then
			table.insert(headers, first_line(bufnr, child))
		else
			collect_arms(bufnr, child, headers)
		end
	end
end

-- Walk up from the node under the fold's first non-blank column to the
-- node that exactly spans the fold. Nested nodes sharing the same start
-- row (e.g. a function's own name identifier) aren't the folded construct.
local function find_fold_node(bufnr, srow, erow)
	local node = scope.node_at_line(bufnr, srow)

	while node do
		local nsrow, _, nerow = node:range()
		if nsrow == srow and nerow == erow then
			return node
		end
		if nsrow < srow then
			return nil
		end
		node = node:parent()
	end
	return nil
end

--- Build the structural summary for the node folded at `foldstart`.
---@param bufnr integer
---@param foldstart integer 1-indexed, as in v:foldstart
---@param foldend integer 1-indexed, as in v:foldend
---@return string
function M.summarize(bufnr, foldstart, foldend)
	local srow, erow = foldstart - 1, foldend - 1
	local node = find_fold_node(bufnr, srow, erow)

	local headers = {}
	if node and is_if_node(node) then
		collect_if_chain(bufnr, node, headers)
	elseif node and is_branch_node(node) then
		table.insert(headers, first_line(bufnr, node))
		collect_arms(bufnr, node, headers)
	elseif node then
		table.insert(headers, first_line(bufnr, node))
	else
		-- No node spans exactly this fold (e.g. an indent-based fold with
		-- no matching treesitter node) — fall back to the raw first line.
		local line = vim.api.nvim_buf_get_lines(bufnr, srow, srow + 1, false)[1] or ""
		local trimmed = line:gsub("^%s+", "")
		table.insert(headers, trimmed)
	end

	-- Preserve the fold's actual leading indentation rather than starting
	-- the summary flush against the window edge: indent-guide plugins
	-- (e.g. snacks.nvim's `indent` module) draw their vertical guide
	-- characters at fixed indent-width columns on every visible row,
	-- closed folds included, assuming real whitespace is there to draw
	-- into. A flush-left summary has no such whitespace, so the guide
	-- ends up overwriting whichever of our own characters lands on that
	-- column instead.
	local raw_line = vim.api.nvim_buf_get_lines(bufnr, srow, srow + 1, false)[1] or ""
	local indent = raw_line:match("^%s*")

	local summary = table.concat(headers, " ")
	local line_count = erow - srow + 1
	return string.format("%s%s (%d lines)", indent, summary, line_count)
end

-- Thin re-export: other features (e.g. the outline picker) want the same
-- "this node's own header/signature line" text this module already builds
-- fold summaries from.
M.first_line = first_line

--- `vim.opt.foldtext` entry point (called with `v:foldstart`/`v:foldend`
--- set). Falls back to a plain line-count summary on any error, so a
--- grammar quirk never breaks folding itself.
---@return string
function M.render()
	local ok, result = pcall(M.summarize, vim.api.nvim_get_current_buf(), vim.v.foldstart, vim.v.foldend)
	if ok and result then
		return result
	end
	return string.format("%d lines folded", vim.v.foldend - vim.v.foldstart + 1)
end

return M
