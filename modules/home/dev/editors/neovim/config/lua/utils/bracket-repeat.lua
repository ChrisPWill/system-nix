local function normalize_mode(mode)
	if mode == "v" or mode == "V" or mode == "\22" or mode == "s" or mode == "S" or mode == "\19" then
		return "x"
	end
	return mode
end

local function new()
	local last_move
	local M = {}

	local function notify(message)
		vim.notify(message, vim.log.levels.INFO, { title = "Bracket repeat" })
	end

	function M.wrap(next_move, previous_move, modes)
		return {
			next = function(...)
				last_move = { next_move = next_move, previous_move = previous_move, modes = modes }
				return next_move(...)
			end,
			previous = function(...)
				last_move = { next_move = next_move, previous_move = previous_move, modes = modes }
				return previous_move(...)
			end,
		}
	end

	function M.repeat_move(direction)
		if not last_move then
			notify("No bracket navigation to repeat")
			return
		end

		local mode = normalize_mode(vim.api.nvim_get_mode().mode)
		if not vim.tbl_contains(last_move.modes, mode) then
			notify("Previous bracket navigation is unavailable in this mode")
			return
		end

		return last_move[direction .. "_move"]()
	end

	function M.map_pair(modes, next_lhs, previous_lhs, next_move, previous_move, opts)
		local moves = M.wrap(next_move, previous_move, modes)
		local map_opts = vim.deepcopy(opts or {})
		local next_desc = map_opts.next_desc
		local previous_desc = map_opts.previous_desc
		map_opts.next_desc = nil
		map_opts.previous_desc = nil
		vim.keymap.set(modes, next_lhs, moves.next, vim.tbl_extend("force", map_opts, { desc = next_desc }))
		vim.keymap.set(modes, previous_lhs, moves.previous, vim.tbl_extend("force", map_opts, { desc = previous_desc }))
		return moves
	end

	return M
end

local M = new()
M.new = new

return M
