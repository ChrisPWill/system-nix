-- Structural context for git/jj hunks: expand each hunk's changed text to
-- the smallest treesitter node it's actually part of, so e.g. changing one
-- string literal deep inside a call highlights just that literal — not the
-- raw diff line, and not the whole enclosing statement either. Built on
-- gitsigns' own hunk (and, where possible, its internal word-diff) data —
-- this adds a second, treesitter-aware overlay alongside its usual sign
-- column, it doesn't replace or recompute the diff itself.
local scope = require("utils.treesitter.scope")

local M = {}

local ns = vim.api.nvim_create_namespace("treesitter_hunk_context")

-- Deliberately distinct from gitsigns' own add/change highlight groups
-- (which mark "this line changed") — "DiffText" is Vim's own convention
-- for "the exact text that changed within a changed line", which is
-- precisely the claim being made here, background and all.
vim.api.nvim_set_hl(0, "TreesitterHunkContext", { link = "DiffText", default = true })

-- Per-buffer on/off state. Off by default everywhere — this is a
-- toggleable overlay, not an always-on one.
local enabled = {}

local function clear(bufnr)
	vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)
end

-- Targets are plain {srow, scol, erow, ecol} ranges rather than TSNodes
-- throughout this module: a word-diff region that turns out to have no
-- snug covering node (see below) still needs to be highlighted as the raw
-- range, so nodes and raw ranges have to be interchangeable.
local function key_for(range)
	return string.format("%d:%d:%d:%d", range[1], range[2], range[3], range[4])
end

local function range_of(node)
	local srow, scol, erow, ecol = node:range()
	return { srow, scol, erow, ecol }
end

-- The smallest node whose range fully contains [srow, scol] to [erow,
-- ecol] — i.e. "what actually got changed", when that range comes from a
-- word-level diff rather than a single cursor position.
local function node_covering(bufnr, srow, scol, erow, ecol)
	local node = vim.treesitter.get_node({ bufnr = bufnr, pos = { srow, scol } })
	while node do
		local nsrow, nscol, nerow, necol = node:range()
		local starts_before_or_at = nsrow < srow or (nsrow == srow and nscol <= scol)
		local ends_after_or_at = nerow > erow or (nerow == erow and necol >= ecol)
		if starts_before_or_at and ends_after_or_at then
			return node
		end
		node = node:parent()
	end
	return nil
end

-- Snap a word-diff region to its covering node's range when that's a
-- reasonably snug fit (an identifier, a string literal, ...) — but not
-- when the smallest available node is disproportionately wider than the
-- diffed text itself. Plain prose (Markdown, comments) has no treesitter
-- node finer than a whole paragraph/statement, since nothing subdivides
-- continuous text into words; in that case the raw diffed range is a much
-- more useful highlight than ballooning out to the whole paragraph.
local function tight_target(bufnr, srow, scol, erow, ecol)
	local node = node_covering(bufnr, srow, scol, erow, ecol)
	if node then
		local nsrow, nscol, nerow, necol = node:range()
		local region_width = ecol - scol
		local node_width = necol - nscol
		if nsrow == srow and nerow == erow and node_width <= region_width + 20 then
			return range_of(node)
		end
	end
	return { srow, scol, erow, ecol }
end

-- Word-level diff regions for one hunk, translated from gitsigns'
-- line-relative/1-indexed convention into 0-indexed buffer rows/cols.
-- Returns nil when unavailable: gitsigns' word-diff only pairs lines
-- 1:1, so it can't say anything for a hunk that adds/removes a different
-- number of lines (a pure addition, or an uneven replacement).
local function word_diff_regions(bufnr, hunk)
	if #hunk.removed.lines ~= #hunk.added.lines then
		return nil
	end
	local ok, diff_int = pcall(require, "gitsigns.diff_int")
	if not ok then
		return nil
	end
	local ok_run, _, added_regions = pcall(diff_int.run_word_diff, hunk.removed.lines, hunk.added.lines)
	if not ok_run or not added_regions or #added_regions == 0 then
		return nil
	end

	local results = {}
	for _, region in ipairs(added_regions) do
		local line_idx, _, start_col, end_col = region[1], region[2], region[3], region[4]
		local row = hunk.added.start - 1 + (line_idx - 1)
		-- gitsigns' columns are 1-indexed with an inclusive-end convention
		-- (verified empirically against its own `run_word_diff`, since it's
		-- an internal, undocumented API): buffer-space 0-indexed
		-- start/end-exclusive is simply each minus 1.
		table.insert(results, { row = row, scol = start_col - 1, ecol = end_col - 1 })
	end
	return results
end

-- For one hunk's added-line range, the distinct statements touched by
-- those lines (deduped by range, so a hunk spanning several lines of the
-- *same* statement only highlights it once; a hunk touching two adjacent
-- statements highlights both, separately, rather than their common
-- ancestor). Used as a fallback when a narrower word-level diff isn't
-- available (pure additions, or line-count-changing edits).
local function statements_touching(bufnr, start_row, end_row, seen, results)
	for row = start_row, end_row do
		local node = scope.node_at_line(bufnr, row)
		if node then
			local stmt = range_of(scope.find_enclosing_statement(node))
			local key = key_for(stmt)
			if not seen[key] then
				seen[key] = true
				table.insert(results, stmt)
			end
		end
	end
end

--- Recompute the hunk-context highlight for `bufnr` from gitsigns' current
--- hunks. A no-op (after clearing any previous highlight) when not
--- enabled for this buffer, when gitsigns isn't available, or when the
--- buffer has no parser.
---@param bufnr integer
function M.refresh(bufnr)
	clear(bufnr)
	if not enabled[bufnr] then
		return
	end

	local ok_gitsigns, gitsigns = pcall(require, "gitsigns")
	if not ok_gitsigns then
		return
	end
	local hunks = gitsigns.get_hunks(bufnr)
	if not hunks then
		return
	end

	if not pcall(vim.treesitter.get_parser, bufnr) then
		return
	end

	local seen = {}
	local targets = {}

	for _, hunk in ipairs(hunks) do
		-- A pure deletion (`added.count == 0`) has no footprint in the
		-- current buffer — nothing to point a highlight at, so it's
		-- skipped rather than highlighting some nearby unrelated line.
		if hunk.added and hunk.added.count > 0 then
			local regions = word_diff_regions(bufnr, hunk)
			if regions then
				for _, r in ipairs(regions) do
					local target = tight_target(bufnr, r.row, r.scol, r.row, r.ecol)
					local key = key_for(target)
					if not seen[key] then
						seen[key] = true
						table.insert(targets, target)
					end
				end
			else
				local start_row = hunk.added.start - 1
				local end_row = start_row + hunk.added.count - 1
				statements_touching(bufnr, start_row, end_row, seen, targets)
			end
		end
	end

	for _, range in ipairs(targets) do
		vim.hl.range(bufnr, ns, "TreesitterHunkContext", { range[1], range[2] }, { range[3], range[4] })
	end
end

--- Toggle the hunk-context overlay for `bufnr` on/off.
---@param bufnr integer? defaults to the current buffer
function M.toggle(bufnr)
	bufnr = bufnr or vim.api.nvim_get_current_buf()
	enabled[bufnr] = not enabled[bufnr]
	M.refresh(bufnr)
	vim.notify(
		"Hunk context highlighting " .. (enabled[bufnr] and "enabled" or "disabled"),
		vim.log.levels.INFO,
		{ title = "Treesitter hunks" }
	)
end

-- Keep the overlay in sync as the diff changes (on save, staging, jj/git
-- operations, ...). Registered once, buffer-agnostic — cheap to no-op for
-- any buffer that isn't enabled, so there's no need to set this up
-- per-toggle.
vim.api.nvim_create_autocmd("User", {
	pattern = "GitSignsUpdate",
	callback = function(args)
		local bufnr = args.data and args.data.buffer
		if bufnr and enabled[bufnr] then
			M.refresh(bufnr)
		end
	end,
})

-- Drop state for buffers that no longer exist, rather than growing
-- `enabled` forever across a long session.
vim.api.nvim_create_autocmd("BufDelete", {
	callback = function(args)
		enabled[args.buf] = nil
	end,
})

return M
