local utils = require("utils")

return {
	{
		"neotest",
		enabled = nixCats("general") or false,
		event = "DeferredUIEnter",
		after = function()
			local adapters = {}
			if nixCats("python") then
				table.insert(
					adapters,
					require("neotest-python")({
						runner = "unittest",
					})
				)
			end
			if nixCats("rust") then
				table.insert(adapters, require("rustaceanvim.neotest"))
			end
			if nixCats("cpp") then
				table.insert(
					adapters,
					require("neotest-ctest").setup({
						-- Any options here
					})
				)
			end
			if nixCats("java") or nixCats("kotlin") then
				table.insert(adapters, require("neotest-java")({}))
				table.insert(adapters, require("neotest-gradle"))
			end
			require("neotest").setup({
				log_level = vim.log.levels.DEBUG,
				adapters = adapters,
			})

			utils.nmap("<leader>ctt", require("neotest").run.run, "Test (Nearest)")
			utils.nmap("<leader>cT", function()
				require("neotest").run.run(vim.fn.expand("%"))
			end, "Test (File)")
			utils.nmap("<leader>cts", require("neotest").run.stop, "Test (Stop)")
		end,
	},
	{
		"neotest-python",
		enabled = nixCats("python") or false,
		on_require = { "neotest-python" },
	},
	{
		"neotest-ctest",
		enabled = nixCats("cpp") or false,
		on_require = { "neotest-ctest" },
	},
	{
		"neotest-java",
		enabled = nixCats("java") or nixCats("kotlin") or false,
		on_require = { "neotest-java" },
	},
	{
		"neotest-gradle",
		enabled = nixCats("java") or nixCats("kotlin") or false,
		on_require = { "neotest-gradle" },
	},
}
