-- Ambient, LSP-independent "code smell" diagnostics from generic
-- treesitter structural checks — refreshed on save/text-changed like a
-- lightweight linter, surfaced through vim.diagnostic (so they show up
-- in the normal gutter/virtual-text/`<leader>d` UI, not a bespoke one).
--
-- These are heuristics, not semantic analysis. The missing-arm check in
-- particular can't tell that a `when` over a sealed class/enum is
-- already exhaustive at the language level, so it may flag matches that
-- don't actually need a catch-all — accepted as a HINT-severity
-- trade-off rather than trying to plumb type information through.
local scope = require("utils.treesitter.scope")

local M = {}

local ns = vim.api.nvim_create_namespace("treesitter_smells")
local SOURCE = "treesitter-smells"
local SEVERITY = vim.diagnostic.severity

-- Fixed for now; pull these into a setup() table if a particular
-- language/stack finds them consistently too noisy (e.g. a codebase
-- that idiomatically takes 6+ constructor params).
local MAX_PARAMS = 5
local MAX_NESTING = 3

local CATCH_PATTERNS = { "catch", "except" }
-- Excludes the bare anonymous `catch`/`except` keyword token, which
-- shares the same type-name substring as the clause wrapping it.
local CATCH_SUFFIXES = { "_clause", "_block" }

local function is_catch_node(node)
	local ntype = node:type()
	return scope.matches_any(ntype, CATCH_PATTERNS) and scope.ends_with_any(ntype, CATCH_SUFFIXES)
end

local function is_empty_or_pass(node)
	local count = node:named_child_count()
	if count == 0 then
		return true
	end
	return count == 1 and node:named_child(0):type():find("pass") ~= nil
end

local function diagnostic(node, message, severity)
	local srow, scol, erow, ecol = node:range()
	return {
		lnum = srow,
		col = scol,
		end_lnum = erow,
		end_col = ecol,
		message = message,
		severity = severity,
		source = SOURCE,
	}
end

-- An empty catch/except block — nothing in its body, or a lone `pass`
-- (Python's explicit no-op) — silently swallows whatever it caught.
--
-- Grammars shape the body differently: some (JS's catch_clause) nest it
-- in a separate block child; Kotlin's catch_block holds the exception
-- parameter *and* the body braces directly, with no separate block node
-- — so if there's no distinct block child, the body is "whatever comes
-- after the clause's own opening brace" instead.
local function check_empty_catch(root, results)
	for child in root:iter_children() do
		if is_catch_node(child) then
			local body
			for grandchild in child:iter_children() do
				if scope.is_block_node(grandchild) then
					body = grandchild
					break
				end
			end

			local empty
			if body then
				empty = is_empty_or_pass(body)
			else
				local seen_brace, count, only = false, 0, nil
				for grandchild in child:iter_children() do
					if not seen_brace then
						seen_brace = grandchild:type() == "{"
					elseif grandchild:named() then
						count = count + 1
						only = grandchild
					end
				end
				empty = count == 0 or (count == 1 and only ~= nil and only:type():find("pass") ~= nil)
			end

			if empty then
				table.insert(results, diagnostic(child, "Empty catch block swallows the error", SEVERITY.WARN))
			end
		end
		check_empty_catch(child, results)
	end
end

-- A function or class whose own signature has more than MAX_PARAMS
-- parameters — often a sign it should take a struct/object instead.
local function check_too_many_params(root, results)
	for child in root:iter_children() do
		if scope.is_function_node(child) or scope.is_class_node(child) then
			local list = scope.find_signature_list(child)
			if list then
				local count = list:named_child_count()
				if count > MAX_PARAMS then
					table.insert(
						results,
						diagnostic(
							list,
							string.format("%d parameters (recommended max %d)", count, MAX_PARAMS),
							SEVERITY.HINT
						)
					)
				end
			end
		end
		check_too_many_params(child, results)
	end
end

-- Conditionals/loops nested more than MAX_NESTING levels deep within one
-- function. Flags only the node where nesting *first* crosses the
-- threshold, not every level beyond it, so one deeply-nested branch
-- doesn't produce a cascade of near-duplicate diagnostics.
local function check_nesting(node, depth, results)
	for child in node:iter_children() do
		if scope.is_nesting_node(child) then
			local child_depth = depth + 1
			if child_depth == MAX_NESTING + 1 then
				table.insert(
					results,
					diagnostic(child, string.format("Nested %d levels deep (recommended max %d)", child_depth, MAX_NESTING), SEVERITY.HINT)
				)
			end
			check_nesting(child, child_depth, results)
		else
			check_nesting(child, depth, results)
		end
	end
end

local function check_deep_nesting(root, results)
	for child in root:iter_children() do
		if scope.is_function_node(child) then
			check_nesting(child, 0, results)
		end
		check_deep_nesting(child, results)
	end
end

-- Does `node` (a match/when/switch arm) look like a catch-all — Rust's
-- `_`, Kotlin's `else`, a `default` case? Heuristic: check its own first
-- line for one of those tokens at the start, since there's no generic
-- "is this the wildcard pattern" node type across grammars.
local function is_catchall_arm(bufnr, node)
	local text = vim.treesitter.get_node_text(node, bufnr)
	local first_line = text:match("^[^\n]*") or text
	return first_line:match("^%s*_") or first_line:match("^%s*else") or first_line:match("^%s*default")
end

-- Arms usually sit one level below the branch node itself (e.g. Rust
-- wraps them in a match_block), so this recurses through wrapper nodes
-- to find them — but stops at each arm rather than also searching
-- inside its body, where something coincidentally starting with
-- "else"/"_"/"default" (a variable name, say) could false-match.
local function has_catchall_arm(bufnr, node)
	for child in node:iter_children() do
		if scope.is_arm_node(child) then
			if is_catchall_arm(bufnr, child) then
				return true
			end
		elseif has_catchall_arm(bufnr, child) then
			return true
		end
	end
	return false
end

-- A match/when/switch with no catch-all arm — easy to silently miss a
-- case. `if`/`else` chains are deliberately not checked here: an `if`
-- with no `else` is common and usually intentional, not a smell.
local function check_missing_arm(bufnr, root, results)
	for child in root:iter_children() do
		if scope.is_branch_node(child) and not has_catchall_arm(bufnr, child) then
			table.insert(results, diagnostic(child, "No catch-all (else/_/default) arm", SEVERITY.HINT))
		end
		check_missing_arm(bufnr, child, results)
	end
end

--- Recompute all code-smell diagnostics for `bufnr`. A no-op (diagnostics
--- cleared) when there's no parser attached.
---@param bufnr integer? defaults to the current buffer
function M.refresh(bufnr)
	bufnr = bufnr or vim.api.nvim_get_current_buf()

	-- get_parser can also return `ok=true, parser=nil` (rather than
	-- erroring) for special buffers like a picker's preview buffer, so
	-- both need checking, not just the pcall's own success.
	local ok, parser = pcall(vim.treesitter.get_parser, bufnr)
	if not ok or not parser then
		vim.diagnostic.set(ns, bufnr, {})
		return
	end

	local root = parser:parse()[1]:root()
	local results = {}
	check_empty_catch(root, results)
	check_too_many_params(root, results)
	check_deep_nesting(root, results)
	check_missing_arm(bufnr, root, results)

	vim.diagnostic.set(ns, bufnr, results)
end

-- Same trigger set as nvim-lint's own autocmd (plugins/coding.lua):
-- CursorHold already gives idle-debounced "recheck once you pause"
-- behaviour for free, so there's no need for a separate manual-timer
-- debounce here — and both diagnostic sources end up recomputing on the
-- same cadence rather than two different ones.
local augroup = vim.api.nvim_create_augroup("TreesitterSmells", { clear = true })

vim.api.nvim_create_autocmd({ "FileType", "CursorHold", "BufWritePost", "InsertLeave" }, {
	group = augroup,
	callback = function(args)
		M.refresh(args.buf)
	end,
})

return M
