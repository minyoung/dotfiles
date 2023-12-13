return {
	{
		"folke/flash.nvim",
		enabled = false,
	},

	-- Lua
	{
		"folke/twilight.nvim",
		event = "VeryLazy",
		opts = {
			-- your configuration comes here
			-- or leave it empty to use the default settings
			-- refer to the configuration section below
		},
	},

	{
		"dinhhuy258/git.nvim",
		event = "VeryLazy",
		opts = {
			default_mappings = false,
		},
	},

	{
		"nvim-telescope/telescope.nvim",
		dependencies = {
			{
				"nvim-telescope/telescope-fzf-native.nvim",
				build = "make",
			},
			"nvim-lua/plenary.nvim",
		},
		keys = {
			{
				"<leader>t",
				function()
					local builtin = require("telescope.builtin")
					builtin.find_files({
						hidden = true,
					})
				end,
				desc = "Lists files in your current working directory, respects .gitignore",
			},
			{
				"<leader>s",
				function()
					local builtin = require("telescope.builtin")
					builtin.live_grep()
				end,
				desc = "Search for a string in your current working directory and get results live as you type, respects .gitignore",
			},
			{
				"<leader>m",
				function()
					local builtin = require("telescope.builtin")
					builtin.buffers()
				end,
				desc = "Lists open buffers",
			},
		},
		config = function()
			require("telescope").load_extension("fzf")
		end,
	},

	-- buffer line
	{
		"akinsho/bufferline.nvim",
		event = "VeryLazy",
		keys = {
			{ "<C-n>", "<Cmd>BufferLineCycleNext<CR>", desc = "Next tab" },
			{ "<C-p>", "<Cmd>BufferLineCyclePrev<CR>", desc = "Prev tab" },
		},
		opts = {
			options = {
				mode = "tabs",
				show_buffer_close_icons = false,
				show_close_icon = false,
			},
		},
	},
}
