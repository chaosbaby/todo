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
	local text_tbl = vim.api.nvim_buf_get_text(0, sr, sc, er, ec, {})
	local text = vim.fn.join(text_tbl, "\n")
	return text
end

function M.default(v, default)
	if v == nil then
		if type(default) == "function" then
			default = default()
		end

		return default
	else
		return v
	end
end

_G.vimrc__unique_id = M.default(_G.vimrc__unique_id, -1)
function M.unique_id()
	_G.vimrc__unique_id = _G.vimrc__unique_id + 1
	return _G.vimrc__unique_id
end

M.opfuncs = {}
function M.create_operator(inherent_motion, op)
	local opfunc_name = string.format("vimrc__opfunc_%d", M.unique_id())
	local opfunc_lambda =
		string.format([[{motion -> v:lua.require('chaos.user.opfunc').opfuncs.%s(motion)}]], opfunc_name)

	local opfunc = function(motion)
		if motion == nil then
			vim.o.operatorfunc = opfunc_lambda
			return "g@" .. inherent_motion
		end

		op(motion)

		-- In case anything in `op` changes the opfunc, reset it so we can
		-- still do repeat.
		vim.o.operatorfunc = opfunc_lambda
	end

	M.opfuncs[opfunc_name] = opfunc
	return opfunc
end

function M.new_operator(op)
	return M.create_operator("", op)
end

return M
