local json_store = require("todo.json_store")
describe("readJsonFile", function()
	it("should get json file path", function()
		local filename = vim.fn.getcwd() .. "/f-fzf-wait.json"
		local expected = "/home/chaos/chaosbaby/todo/f-fzf-wait.json"
		assert.are.same(expected, filename)
		-- local data, err = json_store.readJsonFile(filename)
		--
		-- assert.are.same(data, {})
	end)
	it("should get task count right", function()
		local filename = vim.fn.getcwd() .. "/f-fzf-wait.json"
		local data = json_store.readJsonFile(filename)
		local expected_count = 6
		assert.are.same(expected_count, #data)
	end)
end)
