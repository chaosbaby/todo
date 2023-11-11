describe("string.find", function()
	it(" should find box", function()
		local box_str = "- [✅] do something"
		local index = string.find(box_str, "- [✅]", 1, true)
		assert.are.same(1, index)
	end)
end)
