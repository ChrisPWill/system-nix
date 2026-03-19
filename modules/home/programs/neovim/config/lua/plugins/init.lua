local lze = require("lze")

-- Register handlers
require("lze").register_handlers(require("lzextras").lsp)
-- replace the fallback filetype list retrieval function with a slightly faster one
require("lze").h.lsp.set_ft_fallback(function(name)
	return dofile(nixCats.pawsible({ "allPlugins", "opt", "nvim-lspconfig" }) .. "/lsp/" .. name .. ".lua").filetypes
		or {}
end)

local specs = {}

local modules = {
	"plugins.completion",
	"plugins.treesitter",
	"plugins.navigation",
	"plugins.vcs",
	"plugins.ui",
	"plugins.coding",
	"plugins.test",
	"plugins.debug",
	"plugins.ai",
	"plugins.lsp.servers",
}

for _, module in ipairs(modules) do
	local module_specs = require(module)
	for _, spec in ipairs(module_specs) do
		table.insert(specs, spec)
	end
end

lze.load(specs)
