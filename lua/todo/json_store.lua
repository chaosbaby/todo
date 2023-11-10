local M = {}
function M.readJsonFile(filename)
	local file = io.open(filename, "r")
	if not file then
		return nil, "Failed to open file: " .. filename
	end

	local contents = file:read("*a")
	file:close()

	local data = vim.json.decode(contents)
	if not data then
		return nil, "Failed to parse JSON data"
	end

	return data
end

return M
