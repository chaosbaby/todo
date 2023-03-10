local M = {}
local config = require("todo.config")
M.default_settings = {
	highlight_at_first = false,
	prekey = "<Leader>m",
	keywords = {
		init = { box = "- [ ] ", icon = " ", color = "blue", alt = { "@init: ", "@init" }, key = "i" },
		start = { box = "- [ ] ", icon = "▶️", color = "green", alt = { "@start: ", "@start" }, key = "s" },
		finish = { box = "- [X] ", icon = " ", color = "yellow", alt = { "@finish: ", "@finish" }, key = "f" },
		stop = { box = "- [S] ", icon = "⏹️", color = "red", alt = { "@stop: ", "@stop" }, key = "x" },
		cancel = { box = "- [C] ", icon = "❌", color = "darkred", alt = { "@cancel: ", "@cancel" }, key = "k" },
		clear = { box = "", icon = "", color = "white", alt = { "@clear: ", "@clear" }, key = "c" },
	},
	actkeywords = {
		finish = { box = "- [X] ", icon = " ", color = "yellow", alt = { "@finish: ", "@finish" }, key = "f" },
	},
}

M.todo_change = config.todo_change
M.setup = config.setup
M.setup(M.default_settings)
M.settings = config.settings
-- vim.pretty_print(config.settings.keywords)
M.togglehl = config.toggle_highlight

return M
