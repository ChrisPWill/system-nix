-- Custom treesitter-powered helpers, grouped by feature so each one stays
-- reusable on its own (require("utils.treesitter.returns") etc.) while this
-- module gives a single entry point to discover what's available.
local M = {}

M.scope = require("utils.treesitter.scope")
M.returns = require("utils.treesitter.returns")
M.mutations = require("utils.treesitter.mutations")

return M
