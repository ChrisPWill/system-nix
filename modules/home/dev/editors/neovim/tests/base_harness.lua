local utils = require("utils")

local unavailable = {
	"nixd",
	"basedpyright-langserver",
	"ruff",
	"rust-analyzer",
	"gopls",
	"lua-language-server",
	"typescript-language-server",
	"kotlin-lsp",
	"clangd",
	"bash-language-server",
}

for _, command in ipairs(unavailable) do
	if utils.hasExecutable(command) then
		error("base meow unexpectedly exposes language executable: " .. command)
	end
end

local function assert_no_clients(file)
	vim.cmd.edit(file)

	if vim.wait(1500, function()
		return #vim.lsp.get_clients({ bufnr = 0 }) > 0
	end, 100) then
		error("base meow started an unavailable LSP client: " .. vim.inspect(vim.lsp.get_clients({ bufnr = 0 })))
	end
end

assert_no_clients(vim.env.NVIM_BASE_TEST_FILE)
assert_no_clients(vim.env.NVIM_BASE_TEST_RUST_FILE)
vim.cmd.quitall()
