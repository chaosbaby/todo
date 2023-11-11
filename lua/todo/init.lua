local M = {}
local config = require("todo.config")
-- stylua: ignore
M.default_settings = {
			highlight_at_first = false,
			prekey = "<leader>m",
		keywords = {
      pending = { box = "- [⏳] ", icon = " ", color = "yellow", alt = { "@pending: ", "@pending" }, key = "p", },
      completed = { box = "- [✅] ", icon = " ", color = "green", alt = { "@completed: ", "@completed" }, key = "c", },
		  deleted = { box = "- [❌] ", icon = "⏹️", color = "red", alt = { "@deleted: ", "@deleted" }, key = "d", },
		  clear = { box = "", icon = "", color = "white", alt = { "@clear: ", "@clear" }, key = "l" },
      },
		actkeywords = {
			},
		}
M.todo_change = config.todo_change
M.setup = config.setup
-- M.setup(M.default_settings)
-- M.settings = config.settings
config.settings = M.default_settings
M.togglehl = config.toggle_highlight

return M
