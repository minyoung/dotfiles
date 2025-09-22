return {
	-- buffer line
	{
		"akinsho/bufferline.nvim",
		init = function()
			local bufline = require("catppuccin.groups.integrations.bufferline")
			function bufline.get()
				return bufline.get_theme()
			end
		end,
		event = "VeryLazy",
		cmd = { "BufferLineCycleNext", "BufferLineCyclePrev" },
		keys = {
			{ "<C-n>", "<cmd>BufferLineCycleNext<cr>", desc = "Next tab" },
			{ "<C-p>", "<cmd>BufferLineCyclePrev<cr>", desc = "Prev tab" },
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
