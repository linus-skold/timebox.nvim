
---@class TimeboxConfig
---@field duration table
---@field notifications boolean
---@field messages table
---@field storage table

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
	storage = {
		dir = vim.fn.stdpath("data") .. "/timebox",
	},
}

M.options = {}

---@param opts? TimeboxConfig
function M.setup(opts)
	M.options = vim.tbl_deep_extend("force", M.defaults, opts or {})
end

return M
