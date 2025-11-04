local config = require("timebox.config")
local storage = require("timebox.storage")
local M = {}

local current_task = nil

function M.setup(opts)
	config.setup(opts)
	storage.setup(config.options.storage)
end

return M
