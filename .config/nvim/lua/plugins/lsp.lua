return {
	-- tools
	{
		"mason-org/mason.nvim",
		opts = function(_, opts)
			vim.list_extend(opts.ensure_installed, {
				-- "jsonlsp",
				"shellcheck",
				"shfmt",
				"tailwindcss-language-server",
				"typescript-language-server",
				"css-lsp",
				"python-lsp-server",
				"rust-analyzer",
				"rustfmt",
			})
		end,
	},

	-- lsp servers
	{
		"neovim/nvim-lspconfig",
		opts = {
			inlay_hints = { enabled = false },
			---@type lspconfig.options
			servers = {
				biome = {},
				cssls = {},
				jsonls = {
					settings = {
						json = {
							schemas = require("schemastore").json.schemas({}),
							validate = { enable = true },
						},
					},
				},
				tailwindcss = {},
				tsserver = {
					root_dir = function(...)
						return require("lspconfig.util").root_pattern(".git")(...)
					end,
					single_file_support = false,
					settings = {
						typescript = {
							inlayHints = {
								includeInlayParameterNameHints = "literal",
								includeInlayParameterNameHintsWhenArgumentMatchesName = false,
								includeInlayFunctionParameterTypeHints = true,
								includeInlayVariableTypeHints = false,
								includeInlayPropertyDeclarationTypeHints = true,
								includeInlayFunctionLikeReturnTypeHints = true,
								includeInlayEnumMemberValueHints = true,
							},
						},
						javascript = {
							inlayHints = {
								includeInlayParameterNameHints = "all",
								includeInlayParameterNameHintsWhenArgumentMatchesName = false,
								includeInlayFunctionParameterTypeHints = true,
								includeInlayVariableTypeHints = true,
								includeInlayPropertyDeclarationTypeHints = true,
								includeInlayFunctionLikeReturnTypeHints = true,
								includeInlayEnumMemberValueHints = true,
							},
						},
					},
				},
				html = {},
			},
			setup = {},
		},
	},
}
