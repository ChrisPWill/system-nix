-- "Highlight a set of node ranges, auto-clear once the cursor leaves a
-- given range" — shared by every treesitter highlight feature (return
-- positions, mutation sites, ...) so each one only has to describe *what*
-- to highlight, not the namespace/autocmd bookkeeping around it.
local function new(name)
	local ns = vim.api.nvim_create_namespace("treesitter_" .. name)
	local augroup = vim.api.nvim_create_augroup("Treesitter" .. name .. "HighlightClear", { clear = true })
	local M = { ns = ns }

	--- Clear this feature's highlights in `bufnr`.
	function M.clear(bufnr)
		vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)
	end

	--- Highlight `nodes` with `hl_group`, replacing any highlights this
	--- feature previously applied in `bufnr`. The highlight clears
	--- automatically once the cursor leaves `range_node`'s line range.
	---@param bufnr integer
	---@param hl_group string
	---@param nodes TSNode[]
	---@param range_node TSNode node whose line range keeps the highlight alive
	function M.apply(bufnr, hl_group, nodes, range_node)
		M.clear(bufnr)

		for _, node in ipairs(nodes) do
			local srow, scol, erow, ecol = node:range()
			vim.hl.range(bufnr, ns, hl_group, { srow, scol }, { erow, ecol })
		end

		local range_srow, _, range_erow, _ = range_node:range()
		vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
		vim.api.nvim_create_autocmd("CursorMoved", {
			group = augroup,
			buffer = bufnr,
			callback = function()
				local row = vim.api.nvim_win_get_cursor(0)[1] - 1
				if row < range_srow or row > range_erow then
					M.clear(bufnr)
					return true -- delete this autocmd, it's done its job
				end
			end,
		})
	end

	return M
end

return { new = new }
