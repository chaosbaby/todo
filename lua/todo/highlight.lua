local M = {}

local function get_displayed_buffers()
	local displayed_buffers = {}
	local windows = vim.api.nvim_list_wins()
	for _, win in ipairs(windows) do
		local buf = vim.api.nvim_win_get_buf(win)
		table.insert(displayed_buffers, buf)
	end
	return displayed_buffers
end

function M.highlight_word(ns, word, highlight_group, filetypes)
	local bufs = get_displayed_buffers()
	for _, buf in ipairs(bufs) do
		local ft = vim.api.nvim_buf_get_option(buf, "ft")
		if vim.tbl_contains(filetypes, ft) then
			local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
			for i, line in ipairs(lines) do
				if string.find(line, word) then
					local col_start, col_end = string.find(line, word)
					vim.api.nvim_buf_add_highlight(buf, ns, highlight_group, i - 1, col_start - 1, col_end)
					-- vim.fn.sign_place(0, "", highlight_group, buf, { lnum = i, priority = 10 })
				end
			end
		end
	end
end

function M.add_highlight_groups(ns, groups)
	for group_name, highlight_options in pairs(groups) do
		vim.api.nvim_set_hl(ns, group_name, highlight_options)
	end
end

function M.define_signs(signs)
	for sign_name, sign_options in pairs(signs) do
		vim.fn.sign_define(sign_name, sign_options)
	end
end

return M
