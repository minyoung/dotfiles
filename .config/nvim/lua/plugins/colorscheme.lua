return {
	{
		"catppuccin/nvim",
		name = "catppuccin",
		priority = 1000,
		opts = {
			dim_inactive = {
				enabled = true,
				shade = "dark",
				percentage = 0.0,
			},
			custom_highlights = function(colors)
				return {
					WinSeparator = { fg = colors.surface1 },
					NvimTreeGitNew = { fg = colors.lavender },
				}
			end,
			integrations = {
				aerial = true,
				alpha = false,
				bufferline = true,
				cmp = true,
				dashboard = true,
				flash = false,
				gitsigns = true,
				headlines = false,
				illuminate = false,
				indent_blankline = { enabled = true },
				leap = false,
				lsp_trouble = true,
				mason = true,
				markdown = true,
				mini = true,
				native_lsp = {
					enabled = true,
					underlines = {
						errors = { "undercurl" },
						hints = { "undercurl" },
						warnings = { "undercurl" },
						information = { "undercurl" },
					},
				},
				navic = { enabled = false, custom_bg = "lualine" },
				neotest = false,
				neotree = false,
				noice = true,
				notify = true,
				nvimtree = true,
				semantic_tokens = false,
				telescope = true,
				treesitter = true,
				treesitter_context = true,
				which_key = true,
			},
		},
	},

	-- {
	-- 	"Djancyp/custom-theme.nvim",
	-- 	keys = {
	-- 		{ "<leader>ct", ":CustomTheme<Return>" },
	-- 	},
	-- 	config = function()
	-- 		require("custom-theme").setup()
	-- 	end,
	-- },
}
