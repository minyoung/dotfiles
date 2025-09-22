local bit = require("bit")

-- much inspiration from: https://www.reddit.com/r/neovim/comments/tjzmnt/better_lsp_rename/
local M = {}

---Url-decode a string
---@param value string
---@return string
local function url_decode(value)
	if value == nil then
		error("Cannot decode nil value", 0)
	end

	local result = {}
	local i = 1

	while i <= #value do
		local char = value:sub(i, i)

		if char == "+" then
			table.insert(result, " ")
			i = i + 1
		elseif char ~= "%" then
			table.insert(result, char)
			i = i + 1
		else
			local v1 = tonumber(value:sub(i + 1, i + 1), 16)
			local v2 = tonumber(value:sub(i + 2, i + 2), 16)

			table.insert(result, string.char(bit.bor(bit.lshift(v1, 4), v2)))
			i = i + 3
		end
	end

	return table.concat(result)
end

---@class QFEntry
---@field filename string
---@field lnum integer
---@field col integer
---@field text string

---@param qf_list QFEntry[]
---@param filename string
local function append_qf_entries(qf_list, filename, changes)
	local file = url_decode(filename)
	local file_path = string.gsub(file, "file://", "")
	local buf_id = -1
	if vim.uri and vim.uri.uri_to_bufnr then
		buf_id = vim.uri.uri_to_bufnr(file)
	else
		buf_id = vim.fn.bufadd(file_path)
	end
	vim.fn.bufload(buf_id)
	for _, change in ipairs(changes) do
		local row, col = change.range.start.line, change.range.start.character
		table.insert(qf_list, {
			filename = file_path,
			lnum = row + 1,
			col = col + 1,
			text = vim.api.nvim_buf_get_lines(buf_id, row, row + 1, false)[1],
		})
	end
end

function M.rename()
	local curr_name = vim.fn.expand("<cword>")
	local new_name = vim.fn.input({ prompt = "Rename: ", default = curr_name })
	if not new_name or #new_name == 0 or curr_name == new_name then
		return
	end

	local lsp_params = vim.lsp.util.make_position_params()
	lsp_params.newName = new_name

	-- request lsp rename
	vim.lsp.buf_request(0, "textDocument/rename", lsp_params, function(err, res, ...)
		if err and err.message then
			vim.notify("[LSPRename] Error while renaming: " .. err.message, vim.lsp.log_levels.ERROR)
			return
		end

		if not res or vim.tbl_isempty(res) then
			vim.notify("[LSPRename] Nothing renamed", vim.lsp.log_levels.WARN)
			return
		end

		-- apply rename
		vim.lsp.handlers["textDocument/rename"](err, res, ...)

		-- print renames
		local changed_files_count = 0
		local changed_instances_count = 0
		local qf_list = {}

		if res.documentChanges then
			for _, entry in pairs(res.documentChanges) do
				changed_files_count = changed_files_count + 1
				changed_instances_count = changed_instances_count + #entry.edits
				append_qf_entries(qf_list, entry.textDocument.uri, entry.edits)
			end
		elseif res.changes then
			for file, changes in pairs(res.changes) do
				changed_instances_count = changed_instances_count + #changes
				changed_files_count = changed_files_count + 1
				append_qf_entries(qf_list, file, changes)
			end
		end

		vim.notify(
			string.format(
				"Renamed %s instance%s in %s file%s",
				changed_instances_count,
				changed_instances_count == 1 and "" or "s",
				changed_files_count,
				changed_files_count == 1 and "" or "s"
			)
		)

		if changed_files_count > 1 then
			vim.fn.setqflist(qf_list, "r")
			vim.cmd([[
        belowright cwindow
        wincmd p
      ]])
		end
	end)
end

vim.keymap.set("n", "<leader>rn", function()
	M.rename()
end)

return M
