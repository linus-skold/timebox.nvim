local config = require("timebox.config")
local storage = require("timebox.storage")
local M = {}

local uv = vim.loop
local timer = nil
local current_task = nil
local start_time = nil

function M.setup(opts)
	config.setup(opts)
	storage.setup(config.options.storage)
end

return M
