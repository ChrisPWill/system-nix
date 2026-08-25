-- Custom treesitter-powered helpers, grouped by feature so each one stays
-- reusable on its own (require("utils.treesitter.returns") etc.) while this
-- module gives a single entry point to discover what's available.
local M = {}

M.scope = require("utils.treesitter.scope")
M.identifier = require("utils.treesitter.identifier")
M.motion = require("utils.treesitter.motion")
M.highlight = require("utils.treesitter.highlight")
M.returns = require("utils.treesitter.returns")
M.mutations = require("utils.treesitter.mutations")
M.foldtext = require("utils.treesitter.foldtext")
M.outline = require("utils.treesitter.outline")

return M
