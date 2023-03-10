local M = {}

function M.is_bright(color_str)
	local color = 0
	if type(color_str) == "string" then
		color = vim.api.nvim_get_color_by_name(color_str)
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

function M.to_decimal(hex_color)
	local r = tonumber(hex_color:sub(2, 3), 16)
	local g = tonumber(hex_color:sub(4, 5), 16)
	local b = tonumber(hex_color:sub(6, 7), 16)
	return r * 256 * 256 + g * 256 + b
end

-- print(to_decimal("#ff0000"))
-- print(to_decimal("#0000ff"))
-- print(M.is_bright("white"))
-- print(M.is_bright("red"))
return M
