local M = {}

M.OUT_LINE_LEN = 10000
local function get_line_length(bufnr, line_number)
	local line_text = vim.api.nvim_buf_get_lines(bufnr, line_number - 1, line_number, false)[1]
	return string.len(line_text)
end

local function visual_range()
	local s_mark, e_mark = "<", ">"
	local sr, sc = unpack(vim.api.nvim_buf_get_mark(0, s_mark))
	local er, ec = unpack(vim.api.nvim_buf_get_mark(0, e_mark))
	if ec > M.OUT_LINE_LEN then
		ec = get_line_length(0, er)
	end
	return { sr - 1, sc, er - 1, ec + 1 }
end

local function motion_range()
	local s_mark, e_mark = "[", "]"
	local sr, sc = unpack(vim.api.nvim_buf_get_mark(0, s_mark))
	local er, ec = unpack(vim.api.nvim_buf_get_mark(0, e_mark))
	return { sr - 1, sc, er - 1, ec + 1 }
end

function M.get_op_range(kind)
	local range
	if kind == "V" or kind == "v" then
		range = visual_range()
	else
		range = motion_range()
	end
	return range
end

function M.get_op_text(range)
	local sr, sc, er, ec = unpack(range)
	vim.pretty_print(range)
	local text_tbl = vim.api.nvim_buf_get_text(0, sr, sc, er, ec, {})
	local text = vim.fn.join(text_tbl, "\n")
	return text
end

function M.operator_gen(g_fun_name, keymap)
	local ncmd = ":set opfunc=v:lua." .. g_fun_name .. "<cr>g@"
	local vcmd = ":<c-u>call v:lua." .. g_fun_name .. "(visualmode())<cr>"
	vim.keymap.set("n", keymap, ncmd, { noremap = true, silent = true })
	vim.keymap.set("x", keymap, vcmd, { noremap = true, silent = true })
end

return M
