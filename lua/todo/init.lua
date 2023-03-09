local M = {}
local config = require("todo.config")
M.default_settings = {
	keywords = {
		init = { box = "- [ ] ", icon = " ", color = "blue", alt = { "@init: ", "@init" }, key = "i" },
		start = { box = "- [ ] ", icon = "▶️", color = "green", alt = { "@start: ", "@start" }, key = "s" },
		finish = { box = "- [X] ", icon = " ", color = "yellow", alt = { "@finish: ", "@finish" }, key = "f" },
		stop = { box = "- [S]", icon = "⏹️", color = "red", alt = { "@stop: ", "@stop" }, key = "x" },
		cancel = { box = "-[C]", icon = "❌", color = "DarkRed", alt = { "@cancel: ", "@cancel" }, key = "k" },
		clear = { box = "", icon = "", color = "white", alt = { "@clear: ", "@clear" }, key = "c" },
	},
}

M.todoChange = config.todoChange
M.setup = config.setup
M.setup(M.default_settings)
M.settings = config.settings
-- vim.pretty_print(config.settings.keywords)
M.togglehl = config.toggleHighlight

local keymap = require("chaos.plugin.func").keymap

local markdown_group = vim.api.nvim_create_augroup("markdown", { clear = true })
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
	group = markdown_group,
	pattern = { "*.md", "*.markdown", "*.vimwiki" },
	callback = function()
		for keyword, opts in pairs(M.settings.keywords) do
			keymap({ "n", "x" }, "<Leader>m" .. opts.key, function()
				M.todoChange(keyword)
			end, { buffer = true })
		end
	end,
})

return M
