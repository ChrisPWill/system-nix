local M = {}

function M.on_attach(_, bufnr)
	-- we create a function that lets us more easily define mappings specific
	-- for LSP related items. It sets the mode, buffer and description for us each time.

	local nmap = function(keys, func, desc)
		if desc then
			desc = "LSP: " .. desc
		end
		vim.keymap.set("n", keys, func, { buffer = bufnr, desc = desc })
	end

	nmap("<leader>rn", vim.lsp.buf.rename, "[R]ename")
	nmap("<leader>a", function()
		if vim.bo.filetype == "rust" then
			vim.cmd.RustLsp("codeAction")
		else
			vim.lsp.buf.code_action()
		end
	end, "Code [A]ction")

	nmap("gd", vim.lsp.buf.definition, "[G]oto [D]efinition")
	nmap("gy", vim.lsp.buf.type_definition, "[G]oto T[y]pe Definition")

	if nixCats("general") then
		require("snacks")
		nmap("gr", function()
			Snacks.picker.lsp_references()
		end, "[G]oto [R]eferences")
		nmap("gI", function()
			Snacks.picker.lsp_implementations()
		end, "[G]oto [I]mplementation")
		nmap("<leader>s", function()
			Snacks.picker.lsp_symbols()
		end, "Document [S]ymbols")
		nmap("<leader>/s", function()
			Snacks.picker.lsp_symbols()
		end, "Search: Document [S]ymbols")
		nmap("<leader>S", function()
			Snacks.picker.lsp_workspace_symbols()
		end, "[W]orkspace [S]ymbols")
		nmap("<leader>/S", function()
			Snacks.picker.lsp_workspace_symbols()
		end, "Search: [W]orkspace [S]ymbols")
	end

	-- See `:help K` for why this keymap
	nmap("K", function()
		if vim.bo.filetype == "rust" then
			vim.cmd.RustLsp({ "hover", "actions" })
		else
			vim.lsp.buf.hover()
		end
	end, "Hover Documentation")
	nmap("<C-k>", vim.lsp.buf.signature_help, "Signature Documentation")

	-- Lesser used LSP functionality
	nmap("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")
	nmap("<leader>Wa", vim.lsp.buf.add_workspace_folder, "[W]orkspace [A]dd Folder")
	nmap("<leader>Wr", vim.lsp.buf.remove_workspace_folder, "[W]orkspace [R]emove Folder")
	nmap("<leader>Wl", function()
		print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
	end, "[W]orkspace [L]ist Folders")

	-- Create a command `:Format` local to the LSP buffer
	vim.api.nvim_buf_create_user_command(bufnr, "Format", function(_)
		vim.lsp.buf.format()
	end, { desc = "Format current buffer with LSP" })
end

return M
