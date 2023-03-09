local M = {}

function M.isBright(colorStr)
	local color = 0
	if type(colorStr) == "string" then
		color = vim.api.nvim_get_color_by_name(colorStr)
	end
	-- print(color)
	local b = color % 256
	local g = (color - b) / 256 % 256
	local r = (color - b - g) / 256 / 256 % 256
	local luminance = (0.299 * r + 0.587 * g + 0.114 * b) / 255
	if luminance > 0.5 then
		return true -- bright colors, black font
	else
		return false -- dark colors, white font
	end
end

function M.toDecimal(hexColor)
	local r = tonumber(hexColor:sub(2, 3), 16)
	local g = tonumber(hexColor:sub(4, 5), 16)
	local b = tonumber(hexColor:sub(6, 7), 16)
	return r * 256 * 256 + g * 256 + b
end

-- print(toDecimal("#ff0000"))
-- print(toDecimal("#0000ff"))
-- print(M.isBright("white"))
-- print(M.isBright("red"))
return M
