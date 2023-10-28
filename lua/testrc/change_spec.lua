local default_settings = {
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
		start = { box = "- [ ] ", icon = "▶️", color = "green", alt = { "@start: ", "@start" }, key = "s" },
	},
}

local function get_values_by_key(tbl, key)
	local result = {}
	for keyword, v in pairs(tbl) do
		if type(v) == "table" and v[key] ~= nil then
			result[keyword] = v[key]
		end
	end
	return result
end

local toggle = require("todo.toggle")
local headerTbl = get_values_by_key(default_settings.keywords, "box")

local function todoChange(todoStr, keyWord)
	return toggle.change(todoStr, keyWord, headerTbl)
end
local fakeDate = "2018-01-01 12:00"
os.date = function(_)
	return fakeDate
end

describe("todoChange", function()
	it("should format right", function()
		local todoStr = "do something"
		assert.are.same(string.format("- [ ] do something @init(%s)", fakeDate), todoChange(todoStr, "init"))
	end)
	-- it("should clear out all extra info", function()
	-- 	local todoStr = "- [ ] do something"
	-- 	assert.are.same(todoChange(todoStr, "clean"), "do something @clean(2018-01-01 12:00)")
	-- end)

	it("should clean box", function()
		local todoStr = "- [ ] do something"
		assert.are.same(todoChange(todoStr, "clear"), "do something")
	end)
	it("should clear out all extra info2", function()
		local todoStr = "- [ ] do something @init()"
		assert.are.same(todoChange(todoStr, "clear"), "do something")
	end)

	it("should not effect with re tag to a changed todo line", function()
		local todoStr = "- [ ] do something @init()"
		assert.are.same(string.format("- [ ] do something @init(%s)", fakeDate), todoChange(todoStr, "init"))
	end)
	it("should ok with text indent ", function()
		local indented = "     - [ ] do something @init()"
		assert.are.same(string.format("     - [ ] do something @init(%s)", fakeDate), todoChange(indented, "init"))
	end)
	it("should ok with pre indent ", function()
		local indented = "     - [ ] do something @init()"
		assert.are.same(string.format("     - [ ] do something @init(%s)", fakeDate), todoChange(indented, "init"))
	end)
end)
