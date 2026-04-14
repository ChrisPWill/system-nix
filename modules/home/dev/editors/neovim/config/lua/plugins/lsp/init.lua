local M = {}

function M.on_attach(client, bufnr)
	if client.server_capabilities.documentSymbolProvider then
		require("nvim-navic").attach(client, bufnr)
	end

	local nmap = function(keys, func, desc, extras)
		if desc then
			desc = "LSP: " .. desc
		end
		local config = extras or {}
		config.buffer = bufnr
		config.desc = desc
		vim.keymap.set("n", keys, func, config)
	end

	-- speed up gr by removing inbuilts
	pcall(vim.keymap.del, "n", "grn", { buffer = bufnr })
	pcall(vim.keymap.del, "n", "grr", { buffer = bufnr })
	pcall(vim.keymap.del, "n", "gra", { buffer = bufnr })
	pcall(vim.keymap.del, "n", "gri", { buffer = bufnr })
	pcall(vim.keymap.del, "n", "grt", { buffer = bufnr })

	nmap("<leader>rn", function()
		return ":IncRename " .. vim.fn.expand("<cword>")
	end, "Rename", { expr = true })

	nmap("<leader>a", function()
		if vim.bo.filetype == "rust" then
			vim.cmd.RustLsp("codeAction")
		else
			require("actions-preview").code_actions()
		end
	end, "Code Actions")

	nmap("gd", vim.lsp.buf.definition, "Definition")
	nmap("gy", vim.lsp.buf.type_definition, "Type Definition")

	if nixCats("general") then
		require("snacks")
		nmap("gr", function()
			Snacks.picker.lsp_references()
		end, "References")
		nmap("gI", function()
			Snacks.picker.lsp_implementations()
		end, "Implementation")
		nmap("<leader>s", function()
			Snacks.picker.lsp_symbols()
		end, "Symbols (Document)")
		nmap("<leader>/s", function()
			Snacks.picker.lsp_symbols()
		end, "Symbols (Document)")
		nmap("<leader>S", function()
			Snacks.picker.lsp_workspace_symbols()
		end, "Symbols (Workspace)")
		nmap("<leader>/S", function()
			Snacks.picker.lsp_workspace_symbols()
		end, "Symbols (Workspace)")
	end

	nmap("K", function()
		if vim.bo.filetype == "rust" then
			vim.cmd.RustLsp({ "hover", "actions" })
		else
			vim.lsp.buf.hover()
		end
	end, "Hover")
	nmap("<C-k>", vim.lsp.buf.signature_help, "Signature")
	if client.server_capabilities.inlayHintProvider then
		vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
	end
	nmap("<leader>ti", function()
		vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = bufnr }), { bufnr = bufnr })
	end, "Inlay Hints")

	nmap("gD", vim.lsp.buf.declaration, "Declaration")
	nmap("<leader>Wa", vim.lsp.buf.add_workspace_folder, "Workspace (Add Folder)")
	nmap("<leader>Wr", vim.lsp.buf.remove_workspace_folder, "Workspace (Remove Folder)")
	nmap("<leader>Wl", function()
		print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
	end, "Workspace (List Folders)")

	vim.api.nvim_buf_create_user_command(bufnr, "Format", function(_)
		vim.lsp.buf.format()
	end, { desc = "Format (LSP)" })
end

return M
