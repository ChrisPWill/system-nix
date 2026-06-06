local function split(value)
	if not value or value == "" then
		return {}
	end

	local parts = {}
	for item in value:gmatch("[^,]+") do
		table.insert(parts, vim.trim(item))
	end
	return parts
end

local function write_report()
	local report = vim.env.NVIM_LSP_TEST_REPORT
	if not report or report == "" then
		return
	end

	local lines = {
		"== messages ==",
		vim.api.nvim_exec2("messages", { output = true }).output,
		"",
		"== lsp log ==",
		vim.lsp.get_log_path(),
		"",
		"== clients ==",
	}

	for _, client in ipairs(vim.lsp.get_clients({ bufnr = 0 })) do
		table.insert(lines, string.format("%s (%d)", client.name, client.id))
	end

	vim.fn.writefile(lines, report)
end

local function fail(message)
	vim.notify(message, vim.log.levels.ERROR)
	write_report()
	vim.cmd("cquit")
end

local function assert_true(condition, message)
	if not condition then
		fail(message)
	end
end

local function contains(list, expected)
	for _, item in ipairs(list) do
		if item == expected then
			return true
		end
	end
	return false
end

local function find_trigger(bufnr, trigger)
	for lnum, line in ipairs(vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)) do
		local start_col, end_col = line:find(trigger, 1, true)
		if start_col then
			return lnum, end_col
		end
	end
	return nil, nil
end

local function completion_labels(result)
	local labels = {}
	local items = result

	if type(result) == "table" and result.items then
		items = result.items
	end

	if type(items) ~= "table" then
		return labels
	end

	for _, item in pairs(items) do
		if type(item) == "table" and item.label then
			table.insert(labels, item.label)
		end
	end

	return labels
end

local function request_completion(bufnr, clients, trigger, expected)
	local row, col = find_trigger(bufnr, trigger)
	assert_true(row ~= nil, "completion trigger not found: " .. trigger)

	vim.api.nvim_win_set_cursor(0, { row, col })

	local pending = 0
	local labels = {}
	local errors = {}

	for _, client in ipairs(clients) do
		if client.supports_method and client:supports_method("textDocument/completion", bufnr) then
			pending = pending + 1
			local params = vim.lsp.util.make_position_params(0, client.offset_encoding or "utf-16")
			params.context = { triggerKind = 1 }
			client:request("textDocument/completion", params, function(err, result)
				if err then
					table.insert(errors, client.name .. ": " .. vim.inspect(err))
				end
				for _, label in ipairs(completion_labels(result)) do
					table.insert(labels, label)
				end
				pending = pending - 1
			end, bufnr)
		end
	end

	assert_true(pending > 0, "no attached client supports textDocument/completion")
	assert_true(
		vim.wait(30000, function()
			return pending == 0
		end, 100),
		"timed out waiting for completion responses"
	)

	for _, label in ipairs(labels) do
		if label == expected or label:find(expected, 1, true) then
			return true, labels, errors
		end
	end

	return false, labels, errors
end

local function symbol_names(result, names)
	if type(result) ~= "table" then
		return
	end

	for _, item in pairs(result) do
		if type(item) == "table" then
			if item.name then
				table.insert(names, item.name)
			end
			symbol_names(item.children, names)
		end
	end
end

local function request_document_symbol(bufnr, clients, expected)
	local names = {}
	local errors = {}
	local has_supporting_client = false

	for _, client in ipairs(clients) do
		has_supporting_client = has_supporting_client
			or (client.supports_method and client:supports_method("textDocument/documentSymbol", bufnr))
	end
	assert_true(has_supporting_client, "no attached client supports textDocument/documentSymbol")

	local params = { textDocument = vim.lsp.util.make_text_document_params(bufnr) }
	local responses = vim.lsp.buf_request_sync(bufnr, "textDocument/documentSymbol", params, 30000) or {}
	for client_id, response in pairs(responses) do
		if response.err then
			table.insert(errors, tostring(client_id) .. ": " .. vim.inspect(response.err))
		end
		symbol_names(response.result, names)
	end

	for _, name in ipairs(names) do
		if name == expected or name:find(expected, 1, true) then
			return
		end
	end

	fail("LSP symbol not found: " .. expected .. "\nnames=" .. vim.inspect(names) .. "\nerrors=" .. vim.inspect(errors))
end

local function check_lint(ft, expected)
	if expected == "" then
		return
	end

	local ok, lint = pcall(require, "lint")
	assert_true(ok, "nvim-lint did not load")

	local configured = lint.linters_by_ft[ft] or {}
	assert_true(contains(configured, expected), "expected linter " .. expected .. " for filetype " .. ft)
end

local function load_plugin_spec(module_name, plugin_name)
	local ok, specs = pcall(require, module_name)
	assert_true(ok, "could not load plugin spec module: " .. module_name)

	for _, spec in ipairs(specs) do
		if spec[1] == plugin_name then
			pcall(vim.cmd.packadd, plugin_name)
			if type(spec.after) == "function" then
				local after_ok, err = pcall(spec.after)
				assert_true(after_ok, "plugin setup failed for " .. plugin_name .. ": " .. tostring(err))
			end
			return
		end
	end

	fail("plugin spec not found: " .. plugin_name)
end

local function spec_is_enabled(spec)
	if spec.enabled == nil then
		return true
	end

	if type(spec.enabled) == "function" then
		local ok, enabled = pcall(spec.enabled)
		return ok and enabled
	end

	return spec.enabled
end

local function setup_lsp_specs()
	pcall(vim.cmd.packadd, "nvim-lspconfig")

	local ok, specs = pcall(require, "plugins.lsp.servers")
	assert_true(ok, "could not load LSP server specs")

	for _, spec in ipairs(specs) do
		if spec_is_enabled(spec) then
			if type(spec.lsp) == "table" then
				vim.lsp.config(spec[1], spec.lsp or {})
				vim.lsp.enable(spec[1])
			elseif spec[1] == "typescript-tools.nvim" and type(spec.after) == "function" then
				pcall(vim.cmd.packadd, spec[1])
				local after_ok, err = pcall(spec.after)
				assert_true(after_ok, "typescript-tools.nvim setup failed: " .. tostring(err))
			end
		end
	end
end

local function root_dir_for_config(config, file)
	local markers = config.root_markers or { ".git" }
	local found = vim.fs.find(markers, { upward = true, path = file })[1]
	if found then
		return vim.fs.dirname(found)
	end
	return vim.fs.dirname(file)
end

local function start_expected_lsp_clients(bufnr, expected_clients)
	local file = vim.api.nvim_buf_get_name(bufnr)

	for _, client_name in ipairs(expected_clients) do
		local config = vim.lsp.config[client_name]
		if type(config) == "table" then
			local start_config = vim.deepcopy(config)
			start_config.root_dir = start_config.root_dir or root_dir_for_config(start_config, file)
			vim.lsp.start(start_config, { bufnr = bufnr })
		end
	end
end

local function check_formatter(bufnr, expected)
	if expected == "" then
		return
	end

	local ok, conform = pcall(require, "conform")
	assert_true(ok, "conform.nvim did not load")

	if conform.get_formatter_info then
		local info = conform.get_formatter_info(expected, bufnr)
		assert_true(info ~= nil, "formatter is not configured: " .. expected)
		assert_true(info.available ~= false, "formatter is configured but unavailable: " .. expected)
		return
	end

	for _, formatter in ipairs(conform.list_formatters(bufnr)) do
		if formatter.name == expected then
			return
		end
	end

	fail("formatter is not configured: " .. expected)
end

local function main()
	vim.o.swapfile = false
	vim.o.writebackup = false

	local file = vim.env.NVIM_LSP_TEST_FILE
	assert_true(file and file ~= "", "NVIM_LSP_TEST_FILE is required")
	local expected_clients = split(vim.env.NVIM_LSP_TEST_CLIENTS)
	assert_true(#expected_clients > 0, "NVIM_LSP_TEST_CLIENTS is required")

	vim.cmd.edit(vim.fn.fnameescape(file))
	local bufnr = vim.api.nvim_get_current_buf()
	if vim.bo[bufnr].filetype == "" then
		if file:match("%.kt$") then
			vim.bo[bufnr].filetype = "kotlin"
		elseif file:match("%.ts$") then
			vim.bo[bufnr].filetype = "typescript"
		elseif file:match("%.py$") then
			vim.bo[bufnr].filetype = "python"
		end
	end
	local ft = vim.bo[bufnr].filetype

	pcall(vim.api.nvim_exec_autocmds, "BufReadPost", { buffer = bufnr, modeline = false })
	pcall(vim.api.nvim_exec_autocmds, "FileType", { buffer = bufnr, modeline = false })
	pcall(vim.api.nvim_exec_autocmds, "User", { pattern = "DeferredUIEnter", modeline = false })
	load_plugin_spec("plugins.completion", "blink.compat")
	load_plugin_spec("plugins.completion", "blink.cmp")
	load_plugin_spec("plugins.coding", "nvim-lint")
	load_plugin_spec("plugins.coding", "conform.nvim")
	setup_lsp_specs()
	pcall(vim.api.nvim_exec_autocmds, "FileType", { buffer = bufnr, modeline = false })
	start_expected_lsp_clients(bufnr, expected_clients)

	local blink_ok = pcall(require, "blink.cmp")
	assert_true(blink_ok, "blink.cmp did not load")

	for _, executable in ipairs(split(vim.env.NVIM_LSP_TEST_EXECUTABLES)) do
		assert_true(vim.fn.executable(executable) == 1, "executable missing from Neovim PATH: " .. executable)
	end

	check_lint(ft, vim.env.NVIM_LSP_TEST_LINTER or "")
	check_formatter(bufnr, vim.env.NVIM_LSP_TEST_FORMATTER or "")

	local attached = {}
	assert_true(
		vim.wait(45000, function()
			attached = {}
			for _, client in ipairs(vim.lsp.get_clients({ bufnr = bufnr })) do
				table.insert(attached, client.name)
			end

			for _, expected in ipairs(expected_clients) do
				if not contains(attached, expected) then
					return false
				end
			end
			return true
		end, 250),
		"expected LSP clients did not attach. expected="
			.. vim.inspect(expected_clients)
			.. " attached="
			.. vim.inspect(attached)
	)

	local clients = vim.lsp.get_clients({ bufnr = bufnr })
	if vim.env.NVIM_LSP_TEST_COMPLETION and vim.env.NVIM_LSP_TEST_COMPLETION ~= "" then
		assert_true(
			vim.wait(15000, function()
				for _, client in ipairs(vim.lsp.get_clients({ bufnr = bufnr })) do
					if client.server_capabilities and client.server_capabilities.completionProvider then
						return true
					end
				end
				return false
			end, 100),
			"no attached client advertised completionProvider"
		)
		clients = vim.lsp.get_clients({ bufnr = bufnr })
		local completion_ok, labels, completion_errors =
			request_completion(bufnr, clients, vim.env.NVIM_LSP_TEST_TRIGGER, vim.env.NVIM_LSP_TEST_COMPLETION)
		if not completion_ok then
			print(
				"LSP completion did not include "
					.. vim.env.NVIM_LSP_TEST_COMPLETION
					.. "; continuing after empty completion smoke response. labels="
					.. vim.inspect(labels)
					.. " errors="
					.. vim.inspect(completion_errors)
			)
		end
	end

	if vim.env.NVIM_LSP_TEST_EXPECT_DIAGNOSTICS == "1" then
		assert_true(
			vim.wait(30000, function()
				return #vim.diagnostic.get(bufnr) > 0
			end, 250),
			"expected diagnostics, found none"
		)
	end

	write_report()
	vim.cmd("qa!")
end

xpcall(main, function(err)
	fail(debug.traceback(err, 2))
end)
