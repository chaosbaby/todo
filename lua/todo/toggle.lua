local M = {}

local function str_replace(str, old_str, new_str)
	return string.gsub(str, old_str:gsub("[%(%)%.%%%+%-%*%?%[%^%$%]]", "%%%1"), new_str)
end

local function clearLine(line, headers)
	local pats = {}
	for _, header in ipairs(headers) do
		table.insert(pats, header)
	end
	local cline = line
	for _, pat in pairs(pats) do
		cline = str_replace(cline, pat, "")
	end
	local pat = " @%w+%(.*%)"
	cline = string.gsub(cline, pat, "")

	return cline
end

local function addTimeTag(mode)
	return string.format(" @%s(%s)", mode, os.date("%Y-%m-%d %H:%M"))
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

function M.change(line, keyWord, tbl)
	local clearedLine = clearLine(line, vim.tbl_values(tbl))
	local _, eIndex, spaceHeader = string.find(clearedLine, "^(%s*%d*%.? ?)")
	spaceHeader = spaceHeader or ""
	local header = tbl[keyWord]
	local subStr = string.sub(clearedLine, eIndex + 1)
	local ret = spaceHeader .. header .. subStr .. addTimeTag(keyWord) .. newTimeTag(line)
	return ret
end
-- vim {{{
local function visual_selection_range()
	local _, ls, cs = unpack(vim.fn.getpos("v"))
	local _, le, ce = unpack(vim.fn.getpos("."))
	return ls - 1, cs - 1, le, ce
end

-- local tblBoxes = get_values_by_key(M.keywords, "box")

function M.todoChange(keyWord, tblBoxes)
	local startIndex, _, endIndex, _ = visual_selection_range()
	if endIndex - startIndex > 0 then
		local optedLines = {}
		local lines = vim.api.nvim_buf_get_lines(0, startIndex, endIndex, false)
		for _, line in ipairs(lines) do
			table.insert(optedLines, M.change(line, keyWord, tblBoxes))
		end
		vim.api.nvim_buf_set_lines(0, startIndex, endIndex, false, optedLines)
	else
		local curLine = vim.api.nvim_get_current_line()
		vim.api.nvim_set_current_line(M.change(curLine, keyWord, tblBoxes))
	end
end

-------------------------------------------------------------------------------- }}} vim

--[[ -- test {{{
local headers = {
	"Todo:",
	"-[X]",
	"-[ ]",
	"-[S]",
}

local todoTable = {
	init = "- [ ] ",
	start = "- [ ] ",
	finish = "- [X] ",
	stop = "- [S] ",
	cancel = "- [C] ",
	tinit = "* [ ] ",
	clear = "",
}

local testLine = "-[X] this is finished"
print(clearLine(testLine, headers))
testLine = "-[X] this is finished @finish(2022-01-01)"
print(clearLine(testLine, headers))

testLine = "Todo: this is finished @finish(2022-01-01)"
print(clearLine(testLine, headers))

testLine = "Todo: this is finished @finish(2022-01-01)"
print(M.change(testLine, "stop", todoTable))

testLine = "Todo: this is finished @start(2023-01-01 12:22)"
print(M.change(testLine, "finish", todoTable)) ]]

-------------------------------------------------------------------------------- }}} test

return M
