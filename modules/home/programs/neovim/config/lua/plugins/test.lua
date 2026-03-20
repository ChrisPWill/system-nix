local utils = require("utils")

return {
	{
		"neotest",
		enabled = nixCats("general") or false,
		event = "DeferredUIEnter",
		load = function(name)
			vim.cmd.packadd("neotest-python")
			vim.cmd.packadd("plenary.nvim")
			vim.cmd.packadd(name)
		end,
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
}
