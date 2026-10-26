local source = debug.getinfo(1, "S").source:sub(2)
local specs_dir = vim.fs.dirname(source)
local unit_dir = vim.fs.dirname(specs_dir)
local config_dir = vim.fs.dirname(vim.fs.dirname(unit_dir)) .. "/config"
local config_root = config_dir .. "/lua"
package.path = unit_dir .. "/?.lua;" .. config_root .. "/?.lua;" .. config_root .. "/?/init.lua;" .. package.path

local h = require("helpers")
require("utils.treesitter.predicates").setup()

-- Parse the repo's query rather than vim.treesitter.query.get(), which
-- would pick up the copy baked into the installed Neovim build.
local query_text = table.concat(vim.fn.readfile(config_dir .. "/queries/mermaid/images.scm"), "\n")
local query = vim.treesitter.query.parse("mermaid", query_text)

local function image_roots(bufnr)
	local root = vim.treesitter.get_parser(bufnr, "mermaid"):parse()[1]:root()
	local found = {}
	for _, match in query:iter_matches(root, bufnr) do
		for id, nodes in pairs(match) do
			if query.captures[id] == "image" then
				table.insert(found, nodes[1])
			end
		end
	end
	return found, root
end

-- A diagram the grammar parses: one image covering the whole file, even
-- though the grammar still nests ERROR nodes inside it.
local clean_bufnr = h.load_fixture("mermaid/flowchart.mmd")
local clean_images, clean_root = image_roots(clean_bufnr)
h.assert_equal(clean_root:type(), "source_file", "flowchart fixture should parse to a source_file root")
h.assert_equal(#clean_images, 1, "nested ERROR nodes must not become extra images")
h.assert_true(clean_images[1]:equal(clean_root), "the image should be the whole file")

-- Regression: valid diagrams with HTML labels parse to an ERROR root, so a
-- query on source_file alone found nothing and the file never rendered.
local html_bufnr = h.load_fixture("mermaid/html_labels.mmd")
local html_images, html_root = image_roots(html_bufnr)
h.assert_equal(html_root:type(), "ERROR", "html_labels fixture should still reproduce the ERROR root")
h.assert_equal(#html_images, 1, "a file with an ERROR root should render as one image")
h.assert_true(html_images[1]:equal(html_root), "the image should be the whole file")
