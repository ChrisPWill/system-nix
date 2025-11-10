local bufnr = vim.api.nvim_get_current_buf()

vim.keymap.set("n", "<leader>ce", function()
	vim.cmd.RustLsp("explainError")
end, { silent = true, buffer = bufnr, desc = "[C]ode [E]xplain" })

vim.keymap.set("n", "<leader>ctt", function()
	vim.cmd.RustLsp("testables")
end, { silent = true, buffer = bufnr, desc = "[C]ode [T]estables [T]est" })

vim.keymap.set("n", "<leader>ctp", function()
	vim.cmd.RustLsp({ "testables", bang = true })
end, { silent = true, buffer = bufnr, desc = "[C]ode [T]estables [P]revious (re-run)" })

vim.keymap.set("n", "<leader>crr", function()
	vim.cmd.RustLsp("runnables")
end, { silent = true, buffer = bufnr, desc = "[C]ode [R]unnables [R]un" })

vim.keymap.set("n", "<leader>crp", function()
	vim.cmd.RustLsp({ "runnables", bang = true })
end, { silent = true, buffer = bufnr, desc = "[C]ode [R]unnables [P]revious (re-run)" })

vim.keymap.set("n", "<leader>K", function()
	vim.cmd.RustLsp("openDocs")
end, { silent = true, buffer = bufnr, desc = "Open docs.rs doc for symbol" })
