return {
	{
		"milanglacier/minuet-ai.nvim",
		enabled = false,
		event = "VeryLazy",
		config = function()
			require("minuet").setup({
				provider = "openai_fim_compatible",
				n_completions = 1,
				context_window = 512,
				provider_options = {
					openai_fim_compatible = {
						api_key = "TERM",
						name = "Ollama",
						end_point = "http://localhost:11434/v1/completions",
						model = "qwen2.5-coder:7b",
					},
				},
			})
		end,
		dependencies = {
			{
				"saghen/blink.cmp",
				optional = true,
				opts = {
					completion = {
						menu = {
							draw = {
								columns = {
									{ "kind_icon" },
									{ "label", "label_description", gap = 1 },
									{ "source_name" },
								},
							},
						},
					},
					sources = {
						default = { "minuet" },
						providers = {
							minuet = {
								name = "minuet",
								module = "minuet.blink",
								async = true,
								score_offset = 50,
							},
						},
					},
				},
			},
		},
	},
	{
		"olimorris/codecompanion.nvim",
		cmd = { "CodeCompanion", "CodeCompanionActions", "CodeCompanionChat" },
		keys = {
			{ "<leader>aa", "<cmd>CodeCompanionChat<cr>", desc = "Open CodeCompanion chat" },
		},
		opts = {
			display = {
				diff = {
					enabled = false,
				},
			},
			memory = {
				prd = {
					description = "create-prd",
					files = { ".cursor/rules/create-prd.md" },
				},
				tasks = {
					description = "create-prd",
					files = { ".cursor/rules/generate-tasks.md" },
				},
				process = {
					description = "create-prd",
					files = { ".cursor/rules/process-task-list.md" },
				},
			},
			strategies = {
				chat = {
					adapter = "openai",
				},
				inline = {
					adapter = "openai",
				},
				adapter = "openai",
				cmd = {},
			},
			adapters = {
				gpt5 = function()
					return require("codecompanion.adapters").extend("openai", {
						schema = {
							model = {
								default = "gpt-5",
							},
						},
					})
				end,
				ollama = function()
					return require("codecompanion.adapters").extend("ollama", {
						schema = {
							model = {
								default = "deepcoder",
								choices = { "gemma3", "qwen2.5-coder", "gpt-oss", "deepcoder" },
							},
						},
					})
				end,
			},
			extensions = {
				mcphub = {
					callback = "mcphub.extensions.codecompanion",
					opts = {
						make_tools = true,
						show_server_tools_in_chat = true,
						add_mcp_prefix_to_tool_name = false,
						show_result_in_chat = true,
						make_vars = true,
						make_slash_commands = true,
					},
				},
			},
		},
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-treesitter/nvim-treesitter",
			"ravitemer/mcphub.nvim",
			{
				"saghen/blink.cmp",
				optional = true,
				opts = {
					sources = {
						per_filetype = {
							codecompanion = { "codecompanion" },
						},
					},
				},
			},
			{
				"folke/noice.nvim",
				optional = true,
				init = function()
					require("plugins.ai.extensions.codecompanion-noice").init()
				end,
			},
		},
	},
	{
		"ravitemer/mcphub.nvim",
		cmd = "MCPHub",
		dependencies = {
			"nvim-lua/plenary.nvim",
		},
		-- build = "npm install -g mcp-hub@latest", -- Installs `mcp-hub` node binary globally
		build = "bundled_build.lua",
		config = function()
			require("mcphub").setup({
				use_bundled_binary = true,
			})
		end,
	},
	{
		"yetone/avante.nvim",
		enabled = false,
		-- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
		-- ⚠️ must add this setting! ! !
		build = vim.fn.has("win32") ~= 0
				and "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false"
			or "make",
		event = "VeryLazy",
		version = false, -- Never set this value to "*"! Never!
		---@module 'avante'
		---@type avante.Config
		opts = {
			-- add any opts here
			-- for example
			provider = "claude",
			providers = {
				ollama = {
					model = "qwen2.5-coder",
				},
				claude = {
					endpoint = "https://api.anthropic.com",
					model = "claude-sonnet-4-20250514",
					timeout = 30000, -- Timeout in milliseconds
					extra_request_body = {
						temperature = 0.75,
						max_tokens = 20480,
					},
				},
				moonshot = {
					endpoint = "https://api.moonshot.ai/v1",
					model = "kimi-k2-0711-preview",
					timeout = 30000, -- Timeout in milliseconds
					extra_request_body = {
						temperature = 0.75,
						max_tokens = 32768,
					},
				},
			},
		},
		dependencies = {
			"nvim-lua/plenary.nvim",
			"MunifTanjim/nui.nvim",
			--- The below dependencies are optional,
			"nvim-mini/mini.pick", -- for file_selector provider mini.pick
			"nvim-telescope/telescope.nvim", -- for file_selector provider telescope
			"hrsh7th/nvim-cmp", -- autocompletion for avante commands and mentions
			"ibhagwan/fzf-lua", -- for file_selector provider fzf
			"stevearc/dressing.nvim", -- for input provider dressing
			"folke/snacks.nvim", -- for input provider snacks
			"nvim-tree/nvim-web-devicons", -- or echasnovski/mini.icons
			"zbirenbaum/copilot.lua", -- for providers='copilot'
			{
				-- support for image pasting
				"HakonHarnes/img-clip.nvim",
				event = "VeryLazy",
				opts = {
					-- recommended settings
					default = {
						embed_image_as_base64 = false,
						prompt_for_file_name = false,
						drag_and_drop = {
							insert_mode = true,
						},
						-- required for Windows users
						use_absolute_path = true,
					},
				},
			},
			{
				-- Make sure to set this up properly if you have lazy=true
				"MeanderingProgrammer/render-markdown.nvim",
				opts = {
					file_types = { "markdown", "Avante" },
				},
				ft = { "markdown", "Avante" },
			},
		},
	},
}
