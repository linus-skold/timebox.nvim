local M = {}

M.defaults = {
	duration = {
		work = 25 * 60 * 1000,
		coffee = 5 * 60 * 1000,
	},
	notifications = true, -- enable/disable notificatios

	messages = {
		start_work = "Time to focus! Work session started.",
		end_work = "Great job! Work session ended.",
		start_coffee = "Take a break! Coffee session started.",
		end_coffee = "Break over! Coffee session ended.",
	},
}

M.options = {}

function M.setup(opts)
	M.options = vim.tbl_deep_extend("force", M.defaults, opts or {})
end

return M
