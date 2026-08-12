local source = debug.getinfo(1, "S").source:sub(2)
local config_root = vim.fs.dirname(vim.fs.dirname(source)) .. "/config/lua"
package.path = config_root .. "/?.lua;" .. config_root .. "/?/init.lua;" .. package.path

local bracket_repeat = require("utils.bracket-repeat").new()
local notifications = {}
local original_notify = vim.notify
local original_mode = vim.api.nvim_get_mode
local mappings = {}
local original_keymap_set = vim.keymap.set

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

vim.notify = original_notify
vim.api.nvim_get_mode = original_mode
vim.keymap.set = original_keymap_set
