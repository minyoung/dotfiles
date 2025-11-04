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
			rules = {
				prd = {
					description = "create-prd",
					files = { ".cursor/rules/create-prd.md" },
				},
				tasks = {
					description = "generate-tasks",
					files = { ".cursor/rules/generate-tasks.md" },
				},
				process = {
					description = "process-task-list",
					files = { ".cursor/rules/process-task-list.md" },
				},
			},
			strategies = {
				chat = {
					adapter = {
						name = "anthropic",
						model = "claude-sonnet-4-6",
					},
				},
				inline = {
					adapter = "openai",
				},
				adapter = {
					name = "anthropic",
					model = "claude-sonnet-4-6",
				},
				cmd = {},
			},
			adapters = {
				ollama = function()
					return require("codecompanion.adapters").extend("ollama", {
						schema = {
							model = {
								default = "deepcoder",
								choices = { "gemma3", "qwen3.5", "gpt-oss", "qwen3-coder-next" },
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
}
