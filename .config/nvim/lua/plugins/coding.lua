return {
	-- Incremental rename
	{
		"smjonas/inc-rename.nvim",
		enabled = true,
		keys = {
			{
				"<leader>rn",
				function()
					return ":IncRename " .. vim.fn.expand("<cword>")
				end,
				desc = "Rename identifier",
				expr = true,
			},
		},
		config = true,
	},

	-- Refactoring tool
	{
		"ThePrimeagen/refactoring.nvim",
		keys = {
			{
				"<leader>r",
				function()
					require("refactoring").select_refactor()
				end,
				mode = "v",
				noremap = true,
				silent = true,
				expr = false,
				desc = "Refactor selected code",
			},
		},
		opts = {},
	},

	{
		"echasnovski/mini.comment",
		event = "VeryLazy",
		opts = {
			mappings = {
				-- Toggle comment (like `gcip` - comment inner paragraph) for both
				-- Normal and Visual modes
				comment = "",

				-- Toggle comment on current line
				comment_line = "<leader>;",

				-- Toggle comment on visual selection
				comment_visual = "<leader>;",

				-- Define 'comment' textobject (like `dgc` - delete whole comment block)
				textobject = "",
			},
		},
	},

	{
		"stevearc/aerial.nvim",
		event = "VeryLazy",
		keys = {
			{ "<leader>cs", "<cmd>AerialToggle!<cr>", desc = "Symbols Outline" },
		},
		opts = {},
	},

	-- lualine integration
	{
		"nvim-lualine/lualine.nvim",
		optional = true,
		opts = function(_, opts)
			table.insert(opts.sections.lualine_c, {
				"aerial",
				sep = " ", -- separator between symbols
				sep_icon = " ", -- separator between icon and symbol

				-- The number of symbols to render top-down. In order to render only 'N' last
				-- symbols, negative numbers may be supplied. For instance, 'depth = -1' can
				-- be used in order to render only current symbol.
				depth = 5,

				-- When 'dense' mode is on, icons are not rendered near their symbols. Only
				-- a single icon that represents the kind of current symbol is rendered at
				-- the beginning of status line.
				dense = false,

				-- The separator to be used to separate symbols in dense mode.
				dense_sep = ".",

				-- Color the symbol icons.
				colored = true,
			})
		end,
	},
}
