
---@class TimeboxConfig
---@field enable boolean
---@field debug boolean
---@field duration {work: number, coffee: number}
---@field notifications boolean
---@field messages {start_work: string, end_work: string, start_coffee: string, end_coffee: string}
---@field storage {dir: string}

local M = {}

M.defaults = {
    enable = true,
    debug = false,
	notifications = true, 
    duration = {
		work = 25 * 60,
		coffee = 5 * 60,
	},
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
