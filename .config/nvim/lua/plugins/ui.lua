return {
	-- buffer line
	{
		"akinsho/bufferline.nvim",
		event = "VeryLazy",
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
