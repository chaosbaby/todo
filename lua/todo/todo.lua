local M = {}

local function addTimeTag(mode)
	return string.format(" @%s(%s)", mode, os.date("%Y-%m-%d %H:%M"))
end

local function clearLine(line)
	local pats = {}
	table.insert(pats, "[*-] %[[a-zA-Z ]%] ")
	table.insert(pats, " @%w+%(.*%)")
	local cline = line
	for _, pat in pairs(pats) do
		cline = string.gsub(cline, pat, "")
	end
	return cline
end

local function startTime(line)
	local pattag = " @start%((%d%d%d%d%-%d%d%-%d%d %d%d:%d%d)%)"
	local _, _, timeStr = string.find(line, pattag)
	return timeStr
end

local function findTimeUsed(line)
	local pattag = "@used%((%d+)m%)"
	local _, _, timeStr = string.find(line, pattag)
	if timeStr then
		return tonumber(timeStr)
	else
		return 0
	end
end

local function timeDiff(line)
	local dateStr = startTime(line)
	if dateStr then
		local _, _, y, m, d, _hour, _min, _sec = string.find(dateStr, "(%d+)%-(%d+)%-(%d+)%s*(%d+):(%d+)")
		local timestamp = os.time({
			year = y,
			month = m,
			day = d,
			hour = _hour,
			min = _min,
			sec = _sec,
		})
		local difTime = os.difftime(os.time(), timestamp) / 60
		return difTime
	else
		return 0
	end
end

local function newTimeTag(line)
	local newUsed = findTimeUsed(line) + timeDiff(line)
	local timeTag = ""
	if newUsed ~= 0 then
		timeTag = string.format(" @used(%dm)", newUsed)
	end
	return timeTag
end

function TodoChange(line, keyWord)
	local clearedLine = clearLine(line)
	local _, eIndex, spaceHeader = string.find(clearedLine, "^(%s*%d*%.? ?)")
	spaceHeader = spaceHeader or ""
	local header = vim.g.todoTable[keyWord]
	local subStr = string.sub(clearedLine, eIndex + 1)
	local ret = spaceHeader .. header .. subStr .. addTimeTag(keyWord) .. newTimeTag(line)
	return ret
end

local function visual_selection_range()
	local _, ls, cs = unpack(vim.fn.getpos("v"))
	local _, le, ce = unpack(vim.fn.getpos("."))
	return ls - 1, cs - 1, le, ce
end

function NvimTodoChange(keyWord)
	local startIndex, _, endIndex, _ = visual_selection_range()
	if endIndex - startIndex > 0 then
		local optedLines = {}
		local lines = vim.api.nvim_buf_get_lines(0, startIndex, endIndex, false)
		for _, line in ipairs(lines) do
			table.insert(optedLines, TodoChange(line, keyWord))
		end
		vim.api.nvim_buf_set_lines(0, startIndex, endIndex, false, optedLines)
	else
		local curLine = vim.api.nvim_get_current_line()
		vim.api.nvim_set_current_line(TodoChange(curLine, keyWord))
	end
end

return M
