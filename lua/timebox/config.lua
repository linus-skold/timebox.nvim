local M = {}

M.defaults = {
	duration = {
		work = 25 * 60 * 1000,
		coffee = 5 * 60 * 1000,
	},
	notifications = true, -- enable/disable notifications
}

M.options = {}

function M.setup(opts)
	M.options = vim.tbl_deep_extend("force", M.defaults, opts or {})
end

return M
