local base_model = "qwen2.5-coder:3b-base"

return {
	{
		"copilot.lua",
		enabled = nixCats("copilot") or false,
		event = "DeferredUIEnter",
		on_require = "copilot",
		after = function()
			require("copilot").setup({
				suggestion = { enabled = false },
				panel = { enabled = false },
				filetypes = {
					["grug-far"] = false,
					["grug-far-history"] = false,
					["grug-far-help"] = false,
				},
			})
		end,
	},
	{
		"copilot-lualine",
		enabled = nixCats("copilot") or false,
		event = "DeferredUIEnter",
		on_require = "copilot-lualine",
		on_plugin = "lualine.nvim",
	},
	{
		"minuet-ai.nvim",
		on_require = { "minuet", "minuet.blink" },
		dep_of = { "blink.cmp" },
		keys = {
			{
				"<A-y>",
				function()
					require("minuet").make_blink_map()
				end,
				mode = "i",
				desc = "Trigger AI completion (minuet)",
			},
		},
		enabled = nixCats("local-llm") or nixCats("gemini") or false,
		after = function()
			-- Load the required dependency if using lz.n optional loading
			vim.cmd("packadd plenary.nvim")

			local provider = "openai_fim_compatible"
			if nixCats("gemini") then
				provider = "gemini"
			end

			require("minuet").setup({
				provider = provider,
				-- Requesting 1 completion at a time keeps the RTX 2080 generating as fast as possible
				n_completions = 1,
				provider_options = {
					gemini = {
						model = "gemini-3.1-flash-lite-preview",
						stream = true,
						api_key = "GEMINI_API_KEY",
						end_point = "https://generativelanguage.googleapis.com/v1beta/models",
						optional = {
							generationConfig = {
								maxOutputTokens = 256,
								thinkingConfig = {
									thinkingLevel = "minimal",
								},
							},
						},
						-- a list of functions to transform the endpoint, header, and request body
						transform = {},
					},
					openai_fim_compatible = {
						api_key = "TERM",
						model = base_model,
						end_point = "http://127.0.0.1:11434/v1/completions",
						stream = true,
						optional = {
							options = {
								num_predict = 256,
								temperature = 0.1,
								top_p = 0.9,
							},
						},
					},
				},
			})
		end,
	},
	{
		"avante.nvim",
		enabled = nixCats("local-llm") or nixCats("gemini") or false,
		on_require = { "avante" },
		dep_of = { "blink.cmp" },
		-- Lazy load when executing these commands
		cmd = { "AvanteAsk", "AvanteToggle", "AvanteChat" },
		-- Or lazy load on keybinds
		keys = {
			{
				"<leader>Aa",
				function()
					require("avante.api").ask()
				end,
				mode = "n",
				desc = "Avante Ask",
			},
			{
				"<leader>At",
				function()
					require("avante.api").toggle()
				end,
				mode = "n",
				desc = "Avante Toggle",
			},
		},
		after = function()
			-- lz.n does not auto-load dependency trees like lazy.nvim does.
			-- If your dependencies are in 'optionalPlugins', you must packadd them here.
			-- (Skip these if you put them in 'startupPlugins' in nixCats).
			vim.cmd("packadd plenary.nvim")
			vim.cmd("packadd nui.nvim")
			vim.cmd("packadd render-markdown.nvim")
			vim.cmd("packadd dressing.nvim")

			require("avante").setup({
				provider = nixCats("gemini") and "gemini-cli" or "ollama",
				-- Keep auto-suggestions disabled here if you are using llm.nvim for FIM
				auto_suggestions_provider = nixCats("gemini") and "gemini-cli" or "ollama",
				providers = {
					ollama = {
						model = base_model,
						is_env_set = require("avante.providers.ollama").check_endpoint_alive,
					},
					gemini = {
						model = "gemini-2.5-flash-lite",
					},
				},
				acp_providers = {
					["gemini-cli"] = {
						command = "gemini",
						args = { "--experimental-acp" },
						env = {
							NODE_NO_WARNINGS = "1",
							HOME = os.getenv("HOME"),
							GEMINI_API_KEY = os.getenv("GEMINI_API_KEY"),
							GEMINI_DEFAULT_AUTH_TYPE = "oauth-personal",
						},
						auth_method = "oauth-personal",
					},
				},
				behaviour = {
					auto_suggestions = false,
					auto_set_highlight_group = true,
					auto_set_keymaps = true,
				},
			})
		end,
	},
}
