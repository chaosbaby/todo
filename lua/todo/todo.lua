local M = {}

local function add_time_tag(mode)
	return string.format(" @%s(%s)", mode, os.date("%Y-%m-%d %H:%M"))
end

local function clear_line(line)
	local pats = {}
	table.insert(pats, "[*-] %[[a-z_a-Z ]%] ")
	table.insert(pats, " @%w+%(.*%)")
	local cline = line
	for _, pat in pairs(pats) do
		cline = string.gsub(cline, pat, "")
	end
	return cline
end

local function start_time(line)
	local pattag = " @start%((%d%d%d%d%-%d%d%-%d%d %d%d:%d%d)%)"
	local _, _, time_str = string.find(line, pattag)
	return time_str
end

local function find_time_used(line)
	local pattag = "@used%((%d+)m%)"
	local _, _, time_str = string.find(line, pattag)
	if time_str then
		return tonumber(time_str)
	else
		return 0
	end
end

local function time_diff(line)
	local date_str = start_time(line)
	if date_str then
		local _, _, y, m, d, _hour, _min, _sec = string.find(date_str, "(%d+)%-(%d+)%-(%d+)%s*(%d+):(%d+)")
		local timestamp = os.time({
			year = y,
			month = m,
			day = d,
			hour = _hour,
			min = _min,
			sec = _sec,
		})
		local dif_time = os.difftime(os.time(), timestamp) / 60
		return dif_time
	else
		return 0
	end
end

local function new_time_tag(line)
	local new_used = find_time_used(line) + time_diff(line)
	local time_tag = ""
	if new_used ~= 0 then
		time_tag = string.format(" @used(%dm)", new_used)
	end
	return time_tag
end

function todo_change(line, key_word)
	local cleared_line = clear_line(line)
	local _, e_index, space_header = string.find(cleared_line, "^(%s*%d*%.? ?)")
	space_header = space_header or ""
	local header = vim.g.todo_table[key_word]
	local sub_str = string.sub(cleared_line, e_index + 1)
	local ret = space_header .. header .. sub_str .. add_time_tag(key_word) .. new_time_tag(line)
	return ret
end

local function visual_selection_range()
	local _, ls, cs = unpack(vim.fn.getpos("v"))
	local _, le, ce = unpack(vim.fn.getpos("."))
	return ls - 1, cs - 1, le, ce
end

function nvim_todo_change(key_word)
	local start_index, _, end_index, _ = visual_selection_range()
	if end_index - start_index > 0 then
		local opted_lines = {}
		local lines = vim.api.nvim_buf_get_lines(0, start_index, end_index, false)
		for _, line in ipairs(lines) do
			table.insert(opted_lines, todo_change(line, key_word))
		end
		vim.api.nvim_buf_set_lines(0, start_index, end_index, false, opted_lines)
	else
		local cur_line = vim.api.nvim_get_current_line()
		vim.api.nvim_set_current_line(todo_change(cur_line, key_word))
	end
end

return M
