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

	-- Neovim 0.12 exposes its built-in bracket navigation as internal callback
	-- mappings. Discover matching [x/]x pairs so new built-ins participate
	-- without duplicating their implementation or maintaining a key list here.
	function M.track_builtin_pairs()
		local mappings = {}
		for _, mapping in ipairs(vim.api.nvim_get_keymap("n")) do
			mappings[mapping.lhs] = mapping
		end

		for next_lhs, next_mapping in pairs(mappings) do
			if next_lhs:sub(1, 1) == "]" and next_mapping.sid == -8 and type(next_mapping.callback) == "function" then
				local previous_lhs = "[" .. next_lhs:sub(2)
				local previous_mapping = mappings[previous_lhs]
				if previous_mapping and previous_mapping.sid == -8 and type(previous_mapping.callback) == "function" then
					local moves = M.wrap(next_mapping.callback, previous_mapping.callback, { "n" })
					vim.keymap.set("n", next_lhs, moves.next, { desc = next_mapping.desc })
					vim.keymap.set("n", previous_lhs, moves.previous, { desc = previous_mapping.desc })
				end
			end
		end
	end

	return M
end

local M = new()
M.new = new

return M
