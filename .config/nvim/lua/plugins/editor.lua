local Util = require("lazyvim.util")

return {
	{
		"folke/flash.nvim",
		enabled = false,
	},

	{
		"nvim-neo-tree/neo-tree.nvim",
		enabled = false,
	},

	{
		"kristijanhusak/vim-dadbod-ui",
		dependencies = {
			{ "tpope/vim-dadbod", lazy = true },
			{ "kristijanhusak/vim-dadbod-completion", ft = { "sql", "mysql", "plsql" }, lazy = true },
		},
		cmd = {
			"DBUI",
			"DBUIToggle",
			"DBUIAddConnection",
			"DBUIFindBuffer",
		},
		init = function()
			-- Your DBUI configuration
			vim.g.db_ui_use_nerd_fonts = 1
		end,
	},

	{
		"folke/twilight.nvim",
		event = "VeryLazy",
		keys = {
			{
				"<leader>z",
				"<cmd>Twilight<cr>",
				desc = "Toggle twilight",
			},
		},
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
		"nvim-tree/nvim-tree.lua",
		event = "VeryLazy",
		keys = {
			{
				"<leader>n",
				"<cmd>NvimTreeToggle<cr>",
				desc = "Open file explorer",
			},
			{
				"<leader>f",
				"<cmd>NvimTreeFindFile<cr>",
				desc = "Open file explorer selecting current file",
			},
		},
		config = function()
			require("nvim-tree").setup({
				renderer = {
					highlight_git = true,
				},
				on_attach = function(bufnr)
					local api = require("nvim-tree.api")
					local function opts(desc)
						return {
							desc = "nvim-tree: " .. desc,
							buffer = bufnr,
							noremap = true,
							silent = true,
							nowait = true,
						}
					end

					vim.keymap.set("n", "g?", api.tree.toggle_help, opts("Help"))
					vim.keymap.set("n", "q", api.tree.close, opts("Close"))

					vim.keymap.set("n", "R", api.tree.reload, opts("Refresh"))
					vim.keymap.set("n", "K", api.node.show_info_popup, opts("Info"))

					vim.keymap.set("n", "<cr>", api.node.open.edit, opts("Open"))
					vim.keymap.set("n", "o", api.node.open.edit, opts("Open"))
					vim.keymap.set("n", "t", api.node.open.tab, opts("Open: New Tab"))
					vim.keymap.set("n", "v", api.node.open.vertical, opts("Open: Vertical Split"))
					vim.keymap.set("n", "s", api.node.open.horizontal, opts("Open: Horizontal Split"))

					vim.keymap.set("n", "u", api.node.navigate.parent_close, opts("Close Directory"))
					vim.keymap.set("n", "<BS>", api.node.navigate.parent_close, opts("Close Directory"))
					vim.keymap.set("n", "U", api.tree.change_root_to_parent, opts("Up"))

					vim.keymap.set("n", "a", api.fs.create, opts("Create File Or Directory"))
					vim.keymap.set("n", "d", api.fs.remove, opts("Delete"))
					vim.keymap.set("n", "r", api.fs.rename_full, opts("Rename: Full Path"))

					vim.keymap.set("n", "F", api.live_filter.clear, opts("Live Filter: Clear"))
					vim.keymap.set("n", "f", api.live_filter.start, opts("Live Filter: Start"))
					vim.keymap.set("n", "H", api.tree.toggle_hidden_filter, opts("Toggle Filter: Hidden"))
					vim.keymap.set("n", "I", api.tree.toggle_gitignore_filter, opts("Toggle Filter: Git Ignore"))
					vim.keymap.set("n", "B", api.tree.toggle_no_buffer_filter, opts("Toggle Filter: No Buffer"))
					vim.keymap.set("n", "C", api.tree.toggle_git_clean_filter, opts("Toggle Filter: Git Clean"))
					vim.keymap.set("n", "E", api.tree.expand_all, opts("Expand All"))
					vim.keymap.set("n", "W", api.tree.collapse_all, opts("Collapse"))

					-- vim.keymap.set("n", ".", api.node.run.cmd, opts("Run Command"))

					-- vim.keymap.set("n", "c", api.fs.copy.node, opts("Copy"))
					-- vim.keymap.set("n", "x", api.fs.cut, opts("Cut"))
					-- vim.keymap.set("n", "p", api.fs.paste, opts("Paste"))
				end,
			})

			local api = require("nvim-tree.api")
			local Event = api.events.Event

			api.events.subscribe(Event.NodeRenamed, function(data)
				Util.lsp.on_rename(data.old_name, data.new_name)
			end)
		end,
	},

	{
		"stevearc/oil.nvim",
		opts = {},
		-- Optional dependencies
		cmd = "Oil",
		dependencies = { "nvim-tree/nvim-web-devicons" },
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
					require("telescope.builtin").find_files({
						hidden = true,
					})
				end,
				desc = "Lists files in your current working directory, respects .gitignore",
			},
			{
				"<leader>s",
				function()
					require("telescope.builtin").live_grep()
				end,
				desc = "Search for a string in your current working directory and get results live as you type, respects .gitignore",
			},
			{
				"<leader>m",
				function()
					require("telescope.builtin").buffers()
				end,
				desc = "Lists open buffers",
			},
		},
		config = function()
			require("telescope").load_extension("fzf")
		end,
	},
}
