local M = {}

M.groups = {}
M.funs = {}

function M.toggle_augroup(name, cb)
	local toggle_fun = function(enabled)
		local augroup = vim.api.nvim_create_augroup(name, { clear = true })
		if enabled == true or enabled == false then
			M.groups[name] = enabled
		end
		if M.groups[name] == nil then
			M.groups[name] = false
		end
		if M.groups[name] then
			cb(augroup)
		else
			vim.api.nvim_del_augroup_by_name(name)
		end
		M.groups[name] = not M.groups[name]
	end
	M.funs[name] = toggle_fun
	M.groups[name] = false
	toggle_fun(true)
end

return M
