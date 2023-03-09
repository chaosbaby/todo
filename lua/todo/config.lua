local M = {}

M.settings = {}
M.settings.keywords = {
	init = { box = "- [ ] ", icon = " ", color = "blue", alt = { "@init: ", "@init" } },
	start = { box = "- [ ] ", icon = "▶️", color = "green", alt = { "@start: ", "@start" } },
	finish = { box = "- [X] ", icon = " ", color = "yellow", alt = { "@finish: ", "@finish" } },
	stop = { box = "- [S]", icon = "⏹️", color = "red", alt = { "@stop: ", "@stop" } },
	cancel = { box = "-[C]", icon = "❌", color = "DarkRed", alt = { "@cancel: ", "@cancel" } },
	clear = { box = "", icon = "", color = "white", alt = { "@clear: ", "@clear" } },
}
M.settings.actkeywords = {}

function M.setup(settings)
	if type(settings) == "table" then
		M.settings = vim.tbl_deep_extend("keep", settings, M.settings)
	end
	M.ns = vim.api.nvim_create_namespace("Todo")
	M.boot()
end
-- ❌
--
local color = require("todo.color")
local hl = require("todo.highlight")

local function addHighlightGroupsBaseOnKeywords()
	local groups = {}
	for keyword, options in pairs(M.settings.actkeywords) do
		local group_text = keyword
		local group_sign = "Todo_sign_" .. keyword
		local text_hl_opt = { bg = options.color }
		local sign_hl_opt = { fg = options.color }
		if color.isBright(options.color) then
			text_hl_opt = { bg = options.color, fg = "black" }
		else
			text_hl_opt = { bg = options.color, fg = "white" }
		end

		groups[group_text] = text_hl_opt
		groups[group_sign] = sign_hl_opt
	end
	hl.addHighlightGroups(M.ns, groups)
end

local function defineSignsBaseOnKeywords()
	local signs = {}
	for keyword, options in pairs(M.settings.actkeywords) do
		local sign_name = keyword
		local sign_options = { text = options.icon, texthl = "Todo_sign_" .. keyword }
		signs[sign_name] = sign_options
	end
	hl.defineSigns(signs)
end

local toggle = require("todo.toggle")

local function get_values_by_key(tbl, key)
	local result = {}
	for keyword, v in pairs(tbl) do
		if type(v) == "table" and v[key] ~= nil then
			result[keyword] = v[key]
		end
	end
	return result
end

M.todoChange = function(keyword)
	toggle.todoChange(keyword, get_values_by_key(M.settings.keywords, "box"))
end

function M.boot()
	addHighlightGroupsBaseOnKeywords()
	defineSignsBaseOnKeywords()
	vim.api.nvim_set_hl_ns(M.ns)
end

function M.toggleHighlight()
	if M.ns_set == 0 or nil then
		M.ns_set = M.ns
	else
		M.ns_set = 0
	end
	vim.api.nvim_set_hl_ns(M.ns_set)
end

function M.highlight()
	for keyword, item in pairs(M.settings.actkeywords) do
		for _, word in pairs(item.alt) do
			hl.highlightWord(M.ns, word, keyword, { "vimwiki.markdown" })
		end
	end
end

local autocmd = require("todo.autocmd")
autocmd.toggle_augroup("Todo", function(aug)
	local todoRedrawEvents = {
		"BufWinEnter",
		"WinNew",
		"BufWritePost",
		"WinScrolled",
		"ColorScheme",
	}
	vim.api.nvim_create_autocmd(todoRedrawEvents, {
		pattern = "*",
		callback = function()
			M.highlight()
		end,
		group = aug,
	})
end)
function M.redrawHighlight(keywords)
	M.ns = vim.api.nvim_create_namespace("")
	M.settings.actkeywords = {}
	for _, keyword in ipairs(keywords) do
		M.settings.actkeywords[keyword] = M.settings.keywords[keyword]
	end
	M.boot()
	vim.api.nvim_set_hl_ns(M.ns)
	vim.cmd("w")
end

vim.api.nvim_create_user_command("TodoHl", function(com)
	local args = com.fargs
	M.redrawHighlight(args)
end, {
	nargs = "+",
	complete = function(_, l, _)
		local keywords = require("todo").settings.keywords
		local completions = get_values_by_key(keywords, "box")
		local selected = vim.split(l, " ", {})
		for _, key in ipairs(selected) do
			completions[key] = nil
		end
		return vim.tbl_keys(completions)
	end,
})

return M
