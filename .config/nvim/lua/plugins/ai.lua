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
				http = {
					["gemma"] = function()
						return require("codecompanion.adapters").extend("gemini", {
							schema = {
								model = {
									default = "gemma-4-31b-it",
									choices = { "gemma-4-31b-it", "gemma-4-26b-a4b-it" },
								},
							},
						})
					end,
				},
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
				history = {
					enabled = true,
					opts = {
						-- Keymap to open history from chat buffer (default: gh)
						keymap = "gh",
						-- Keymap to save the current chat manually (when auto_save is disabled)
						save_chat_keymap = "sc",
						-- Save all chats by default (disable to save only manually using 'sc')
						auto_save = false,
						-- Number of days after which chats are automatically deleted (0 to disable)
						expiration_days = 0,
						-- Picker interface (auto resolved to a valid picker)
						picker = "telescope", --- ("telescope", "snacks", "fzf-lua", or "default")
						---Optional filter function to control which chats are shown when browsing
						chat_filter = nil, -- function(chat_data) return boolean end
						-- Customize picker keymaps (optional)
						picker_keymaps = {
							rename = { n = "r", i = "<M-r>" },
							delete = { n = "d", i = "<M-d>" },
							duplicate = { n = "<C-y>", i = "<C-y>" },
						},
						---Automatically generate titles for new chats
						auto_generate_title = true,
						title_generation_opts = {
							---Adapter for generating titles (defaults to current chat adapter)
							adapter = nil, -- "copilot"
							---Model for generating titles (defaults to current chat model)
							model = nil, -- "gpt-4o"
							---Number of user prompts after which to refresh the title (0 to disable)
							refresh_every_n_prompts = 0, -- e.g., 3 to refresh after every 3rd user prompt
							---Maximum number of times to refresh the title (default: 3)
							max_refreshes = 3,
							format_title = function(original_title)
								-- this can be a custom function that applies some custom
								-- formatting to the title.
								return original_title
							end,
						},
						---On exiting and entering neovim, loads the last chat on opening chat
						continue_last_chat = false,
						---When chat is cleared with `gx` delete the chat from history
						delete_on_clearing_chat = false,
						---Directory path to save the chats
						dir_to_save = vim.fn.stdpath("data") .. "/codecompanion-history",
						---Enable detailed logging for history extension
						enable_logging = false,

						-- Summary system
						summary = {
							-- Keymap to generate summary for current chat (default: "gcs")
							create_summary_keymap = "gcs",
							-- Keymap to browse summaries (default: "gbs")
							browse_summaries_keymap = "gbs",

							generation_opts = {
								adapter = nil, -- defaults to current chat adapter
								model = nil, -- defaults to current chat model
								context_size = 90000, -- max tokens that the model supports
								include_references = true, -- include slash command content
								include_tool_outputs = true, -- include tool execution results
								system_prompt = nil, -- custom system prompt (string or function)
								format_summary = nil, -- custom function to format generated summary e.g to remove <think/> tags from summary
							},
						},

						-- Memory system (requires VectorCode CLI)
						memory = {
							-- Automatically index summaries when they are generated
							auto_create_memories_on_summary_generation = true,
							-- Path to the VectorCode executable
							vectorcode_exe = "vectorcode",
							-- Tool configuration
							tool_opts = {
								-- Default number of memories to retrieve
								default_num = 10,
							},
							-- Enable notifications for indexing progress
							notify = true,
							-- Index all existing memories on startup
							-- (requires VectorCode 0.6.12+ for efficient incremental indexing)
							index_on_startup = false,
						},
					},
				},
			},
		},
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-treesitter/nvim-treesitter",
			"ravitemer/mcphub.nvim",
			"ravitemer/codecompanion-history.nvim",
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
