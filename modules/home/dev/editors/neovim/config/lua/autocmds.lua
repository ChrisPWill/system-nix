local utils = require("utils")

-- Improve diagnostics in insert mode and show them in a floating window by default
local group = vim.api.nvim_create_augroup("OoO", {})

local function au(typ, pattern, cmdOrFn)
	if type(cmdOrFn) == "function" then
		vim.api.nvim_create_autocmd(typ, { pattern = pattern, callback = cmdOrFn, group = group })
	else
		vim.api.nvim_create_autocmd(typ, { pattern = pattern, command = cmdOrFn, group = group })
	end
end

au({ "CursorHold", "InsertLeave" }, nil, function()
	local opts = {
		focusable = false,
		scope = "cursor",
		close_events = { "BufLeave", "CursorMoved", "InsertEnter" },
	}
	vim.diagnostic.open_float(nil, opts)
end)

au("InsertEnter", nil, function()
	vim.diagnostic.enable(false)
end)

au("InsertLeave", nil, function()
	vim.diagnostic.enable(true)
end)

-- Refresh lualine on fold level change
au("OptionSet", "foldlevel", function()
	pcall(require("lualine").refresh)
end)

-- Conventional commit editing
local koji_group = vim.api.nvim_create_augroup("KojiAutoInsert", { clear = true })

local function run_koji_native()
	-- 1. Save target destination
	local target_buf = vim.api.nvim_get_current_buf()
	local target_win = vim.api.nvim_get_current_win()
	local cursor = vim.api.nvim_win_get_cursor(target_win)
	local row, col = cursor[1] - 1, cursor[2]

	-- 2. Create a scratch buffer and floating window (the equivalent of `:new`)
	local term_buf = vim.api.nvim_create_buf(false, true)
	local width = math.floor(vim.o.columns * 0.8)
	local height = math.floor(vim.o.lines * 0.8)

	local term_win = vim.api.nvim_open_win(term_buf, true, {
		relative = "editor",
		width = width,
		height = height,
		col = math.floor((vim.o.columns - width) / 2),
		row = math.floor((vim.o.lines - height) / 2),
		style = "minimal",
		border = "rounded",
	})

	-- 3. Run termopen and hook into the native on_exit callback
	vim.fn.termopen("koji --stdout", {
		on_exit = function(_, exit_code, _)
			-- 4. Grab the exact output left in the terminal buffer
			local lines = vim.api.nvim_buf_get_lines(term_buf, 0, -1, false)

			local clean_lines = {}
			for _, line in ipairs(lines) do
				-- Strip ANSI codes and carriage returns
				local clean = line:gsub("\x1b%[[0-9;]*[mK]", ""):gsub("\r", "")
				-- Trim whitespace for cleaner matching
				clean = vim.trim(clean)

				-- Filter Criteria:
				-- 1. Not empty
				-- 2. Doesn't start with '>' (koji UI prompt/cursor)
				-- 3. Doesn't start with Neovim's exit message
				local is_ui_element = clean:sub(1, 1) == ">"
				local is_exit_msg = clean:match("^%[Process exited")

				if clean ~= "" and not is_ui_element and not is_exit_msg then
					table.insert(clean_lines, clean)
				end
			end

			-- 5. Close the terminal window immediately (bypassing the need for <CR>)
			if vim.api.nvim_win_is_valid(term_win) then
				vim.api.nvim_win_close(term_win, true)
			end

			-- 6. Insert the cleaned text into the commit buffer
			-- We check exit_code == 0 to ensure we don't insert errors if you cancel the prompt
			if exit_code == 0 and #clean_lines > 0 and vim.api.nvim_buf_is_valid(target_buf) then
				local success, err = pcall(vim.api.nvim_buf_set_text, target_buf, row, col, row, col, clean_lines)
				if not success then
					vim.notify("Koji insertion failed: " .. tostring(err), vim.log.levels.ERROR)
				end
			end
		end,
	})

	-- Automatically put you in insert mode so you can interact with koji immediately
	vim.cmd("startinsert")
end

-- 7. The Autocommand Trigger
vim.api.nvim_create_autocmd("FileType", {
	group = koji_group,
	pattern = { "gitcommit", "jjdescription" },
	callback = function(args)
		vim.keymap.set("n", "<leader>k", run_koji_native, {
			buffer = args.buf,
			desc = "Run koji and insert output",
		})

		-- Help float for Koji
		local help_win = utils.createHelpFloat("<leader>k: Run Koji")
		vim.api.nvim_create_autocmd({ "BufLeave", "BufDelete" }, {
			buffer = args.buf,
			once = true,
			callback = function()
				if help_win then
					help_win:close()
				end
			end,
		})

		if vim.b[args.buf].koji_auto_ran then
			return
		end
		vim.b[args.buf].koji_auto_ran = true

		vim.schedule(run_koji_native)
	end,
})

-- Read-only viewer for `jar://<archive>!/<entry>` locations. LSPs that resolve
-- definitions into JDK/library sources (kotlin-lsp into the JDK's src.zip,
-- Metals into dependency jars, etc.) hand back this URI convention directly —
-- it's a real file inside a zip on disk, not a server-side virtual document,
-- so it can be read with `unzip` rather than any LSP request. Without this,
-- `vim.lsp.buf.definition` opens an empty buffer for the URI and then crashes
-- trying to move the cursor to a line that doesn't exist (`nvim_win_set_cursor`:
-- "Invalid cursor line: out of range").
au("BufReadCmd", "jar://*", function(args)
	local archive, entry = args.match:match("^jar://(.-)!/(.*)$")
	if not archive or not entry then
		vim.notify("Could not parse jar URI: " .. args.match, vim.log.levels.ERROR)
		return
	end

	local lines = vim.fn.systemlist({ "unzip", "-p", archive, entry })
	if vim.v.shell_error ~= 0 then
		vim.notify(("Failed to read %s from %s"):format(entry, archive), vim.log.levels.ERROR)
		return
	end

	vim.bo[args.buf].modifiable = true
	vim.api.nvim_buf_set_lines(args.buf, 0, -1, false, lines)
	vim.bo[args.buf].modifiable = false
	vim.bo[args.buf].modified = false
	vim.bo[args.buf].buftype = "nofile"
	vim.bo[args.buf].readonly = true
	-- NOTE: deliberately not attaching an LSP client to this buffer. Sending
	-- textDocument/didOpen for a jar:// URI has been observed to crash
	-- kotlin-lsp's IntelliJ-platform backend — it disposes its entire analyzer
	-- project seconds after opening one of these buffers (see
	-- ~/.cache/nvim/kotlin-lsp/system/log/intellij-server.log), taking down
	-- the client for the whole real project along with it. This is a
	-- read-only source viewer only; gd/hover do not work inside it.
	vim.bo[args.buf].filetype = vim.filetype.match({ buf = args.buf, filename = entry }) or ""
end)

-- Grug-far buffer-local keybindings
local grug_far_group = vim.api.nvim_create_augroup("GrugFarKeybindings", { clear = true })
vim.api.nvim_create_autocmd("FileType", {
	group = grug_far_group,
	pattern = { "grug-far" },
	callback = function(args)
		-- Help float for Grug-far
		local help_win = utils.createHelpFloat("<leader>c: Close | Ctrl-Ent: Save/Close | \\w: Regex/Fixed")
		vim.api.nvim_create_autocmd({ "BufLeave", "BufDelete" }, {
			buffer = args.buf,
			once = true,
			callback = function()
				if help_win then
					help_win:close()
				end
			end,
		})

		-- Open location and close grug-far
		vim.keymap.set("n", "<C-enter>", function()
			local instance = require("grug-far").get_instance(0)
			if instance then
				instance:open_location()
				instance:close()
			end
		end, { buffer = args.buf, desc = "Grug-far: Open location and close" })

		-- Toggle --fixed-strings
		vim.keymap.set("n", "<localleader>w", function()
			local instance = require("grug-far").get_instance(0)
			if instance then
				local state = unpack(instance:toggle_flags({ "--fixed-strings" }))
				vim.notify("grug-far: toggled --fixed-strings " .. (state and "ON" or "OFF"))
			end
		end, { buffer = args.buf, desc = "Grug-far: Toggle --fixed-strings" })
	end,
})
