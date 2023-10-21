local M = {}

M.settings = {}

local function get_values_by_key(tbl, key)
	local result = {}
	for keyword, v in pairs(tbl) do
		if type(v) == "table" and v[key] ~= nil then
			result[keyword] = v[key]
		end
	end
	return result
end

function M.setup(settings)
	if type(settings) == "table" then
		M.settings = vim.tbl_deep_extend("keep", settings, M.settings)
	end
	M.ns = vim.api.nvim_create_namespace("")
	if settings.highlight_at_first then
		M.settings.actkeywords = M.settings.keywords
	end
	M.boot()
	local function keymap(mode, lhs, rhs, opts)
		local options = { noremap = true, silent = true }
		options = vim.tbl_deep_extend("force", options, opts or {})
		vim.keymap.set(mode, lhs, rhs, options)
	end

	local markdown_group = vim.api.nvim_create_augroup("markdown", { clear = true })
	vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
		group = markdown_group,
		pattern = { "*.md", "*.markdown", "*.vimwiki" },
		callback = function()
			for keyword, opts in pairs(M.settings.keywords) do
				keymap({ "n", "x" }, M.settings.prekey .. opts.key, function()
					M.todo_change(keyword)
				end, { buffer = true, desc = keyword })
			end
		end,
	})
	vim.api.nvim_create_user_command("TodoHl", function(com)
		local args = com.fargs
		M.redraw_highlight(args)
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
end

--
local color = require("todo.color")
local hl = require("todo.highlight")

local function add_highlight_groups_base_on_keywords()
	local groups = {}
	for keyword, options in pairs(M.settings.actkeywords) do
		local group_text = keyword
		local group_sign = "Todo_sign_" .. keyword
		local text_hl_opt = { bg = options.color }
		local sign_hl_opt = { fg = options.color }
		if color.is_bright(options.color) then
			text_hl_opt = { bg = options.color, fg = "black" }
		else
			text_hl_opt = { bg = options.color, fg = "white" }
		end

		groups[group_text] = text_hl_opt
		groups[group_sign] = sign_hl_opt
	end
	hl.add_highlight_groups(M.ns, groups)
end

local function define_signs_base_on_keywords()
	local signs = {}
	for keyword, options in pairs(M.settings.actkeywords) do
		local sign_name = keyword
		local sign_options = { text = options.icon, texthl = "Todo_sign_" .. keyword }
		signs[sign_name] = sign_options
	end
	hl.define_signs(signs)
end

local toggle = require("todo.toggle")

M.todo_change = function(keyword)
	toggle.todo_change(keyword, get_values_by_key(M.settings.keywords, "box"))
end

function M.boot()
	add_highlight_groups_base_on_keywords()
	define_signs_base_on_keywords()
	vim.fn.sign_unplace("todo")
	vim.api.nvim_set_hl_ns(M.ns)
end

function M.toggle_highlight()
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
			hl.highlight_word(M.ns, word, keyword, { "vimwiki.markdown" })
		end
	end
end

local autocmd = require("todo.autocmd")
autocmd.toggle_augroup("Todo", function(aug)
	local todo_redraw_events = {
		"BufWinEnter",
		"WinNew",
		"BufWritePost",
		"WinScrolled",
		"ColorScheme",
	}
	vim.api.nvim_create_autocmd(todo_redraw_events, {
		pattern = "*",
		callback = function()
			M.highlight()
		end,
		group = aug,
	})
end)

function M.redraw_highlight(keywords)
	M.ns = vim.api.nvim_create_namespace("")
	M.settings.actkeywords = {}
	for _, keyword in ipairs(keywords) do
		M.settings.actkeywords[keyword] = M.settings.keywords[keyword]
	end
	-- vim.fn.sign_unplace()
	M.boot()
	vim.api.nvim_set_hl_ns(M.ns)
	vim.cmd("w")
end

return M
