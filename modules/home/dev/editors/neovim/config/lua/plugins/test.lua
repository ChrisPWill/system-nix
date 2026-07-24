local utils = require("utils")

return {
	{
		"neotest",
		enabled = nixCats("general") or false,
		event = "DeferredUIEnter",
		after = function()
			local adapters = {}
			if utils.hasExecutable("pytest") then
				table.insert(
					adapters,
					require("neotest-python")({
						runner = "unittest",
					})
				)
			end
			if utils.hasExecutable("cargo") then
				table.insert(adapters, require("rustaceanvim.neotest"))
			end
			if utils.hasExecutable("ctest") then
				table.insert(
					adapters,
					require("neotest-ctest").setup({
						-- Any options here
					})
				)
			end
			if utils.hasExecutable("java") then
				table.insert(adapters, require("neotest-java")({}))
			end
			if utils.hasExecutables({ "java", "kotlin-lsp" }) then
				table.insert(adapters, require("neotest-kotlin"))
			end
			require("neotest").setup({
				log_level = vim.log.levels.DEBUG,
				adapters = adapters,
				watch = {
					symbol_queries = {
						kotlin = [[
							(import_header (identifier) @symbol)
							(class_declaration (type_identifier) @symbol)
							(function_declaration (simple_identifier) @symbol)
						]],
					},
				},
			})

			utils.nmap("<leader>ctt", require("neotest").run.run, "Test (Nearest)")
			utils.nmap("<leader>cT", function()
				require("neotest").run.run(vim.fn.expand("%"))
			end, "Test (File)")
			utils.nmap("<leader>ctw", require("neotest").watch.toggle, "Test (Watch)")
			utils.nmap("<leader>cts", require("neotest").run.stop, "Test (Stop)")
			utils.nmap("<leader>tt", require("neotest").summary.toggle, "Test Summary")
		end,
	},
	{
		"neotest-python",
		enabled = function()
			return utils.hasExecutable("pytest")
		end,
		on_require = { "neotest-python" },
	},
	{
		"neotest-ctest",
		enabled = function()
			return utils.hasExecutable("ctest")
		end,
		on_require = { "neotest-ctest" },
	},
	{
		"neotest-java",
		enabled = function()
			return utils.hasExecutable("java")
		end,
		on_require = { "neotest-java" },
	},
	{
		"neotest-kotlin",
		enabled = function()
			return utils.hasExecutables({ "java", "kotlin-lsp" })
		end,
		on_require = { "neotest-kotlin" },
	},
}
