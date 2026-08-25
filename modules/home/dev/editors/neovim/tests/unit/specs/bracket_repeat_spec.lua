local source = debug.getinfo(1, "S").source:sub(2)
local specs_dir = vim.fs.dirname(source)
local unit_dir = vim.fs.dirname(specs_dir)
local config_root = vim.fs.dirname(vim.fs.dirname(unit_dir)) .. "/config/lua"
package.path = config_root .. "/?.lua;" .. config_root .. "/?/init.lua;" .. package.path

local bracket_repeat = require("utils.bracket-repeat").new()
local notifications = {}
local original_notify = vim.notify
local original_mode = vim.api.nvim_get_mode
local mappings = {}
local original_keymap_set = vim.keymap.set
local original_get_keymap = vim.api.nvim_get_keymap

vim.notify = function(message)
	table.insert(notifications, message)
end

local current_mode = "n"
vim.api.nvim_get_mode = function()
	return { mode = current_mode }
end

vim.keymap.set = function(_, lhs, rhs, opts)
	mappings[lhs] = { rhs = rhs, opts = opts }
end

local function assert_equal(actual, expected, message)
	if actual ~= expected then
		error(message .. ": expected " .. vim.inspect(expected) .. ", got " .. vim.inspect(actual))
	end
end

bracket_repeat.repeat_move("next")
assert_equal(notifications[1], "No bracket navigation to repeat", "empty repeat should notify")

local calls = {}
local moves = bracket_repeat.map_pair(
	{ "n", "x" },
	"]t",
	"[t",
	function()
		table.insert(calls, "next")
	end,
	function()
		table.insert(calls, "previous")
	end,
	{ next_desc = "Next test", previous_desc = "Previous test" }
)

assert_equal(mappings["]t"].opts.desc, "Next test", "next mapping description")
assert_equal(mappings["[t"].opts.desc, "Previous test", "previous mapping description")
moves.previous()
bracket_repeat.repeat_move("next")
bracket_repeat.repeat_move("previous")
assert_equal(table.concat(calls, ","), "previous,next,previous", "repeat direction should be independent of last direction")

current_mode = "o"
bracket_repeat.repeat_move("next")
assert_equal(notifications[#notifications], "Previous bracket navigation is unavailable in this mode", "unsupported mode should notify")
assert_equal(table.concat(calls, ","), "previous,next,previous", "unsupported mode should not execute")

current_mode = "v"
bracket_repeat.repeat_move("next")
assert_equal(table.concat(calls, ","), "previous,next,previous,next", "visual mode should normalize to x")

vim.api.nvim_get_keymap = function()
	return {
		{ lhs = "]b", sid = -8, callback = function()
			table.insert(calls, "buffer-next")
		end, desc = ":bnext" },
		{ lhs = "[b", sid = -8, callback = function()
			table.insert(calls, "buffer-previous")
		end, desc = ":bprevious" },
		{ lhs = "]x", sid = 42, callback = function() end, desc = "custom mapping" },
		{ lhs = "[x", sid = 42, callback = function() end, desc = "custom mapping" },
	}
end
bracket_repeat.track_builtin_pairs()
assert_equal(mappings["]b"].opts.desc, ":bnext", "built-in next mapping description")
assert_equal(mappings["[b"].opts.desc, ":bprevious", "built-in previous mapping description")
current_mode = "n"
mappings["]b"].rhs()
bracket_repeat.repeat_move("previous")
assert_equal(table.concat(calls, ","), "previous,next,previous,next,buffer-next,buffer-previous", "built-in pair should register")
assert_equal(mappings["]x"], nil, "custom mapping must not be wrapped")

vim.notify = original_notify
vim.api.nvim_get_mode = original_mode
vim.keymap.set = original_keymap_set
vim.api.nvim_get_keymap = original_get_keymap
