---@class Block
---@field name string
---@field start_time number
---@field end_time number
---@field elapsed number
---@field block_type string

local storage = require("timebox.storage")

local M = {}
M.__index = M

function M.new(name, block_type, timer)
	local self = setmetatable({}, M)
	self.name = name
	self.block_type = block_type
	self.timer = timer
	return self
end

function M:get_elapsed()
    return self.timer:get_elapsed()
end

function M:get_block_info()
    return {
        name = self.name,
        block_type = self.block_type,
        elapsed = self.timer:get_elapsed(),
    }
end

function M:start()
	self.timer:start()
end

function M:stop()
	self.timer:stop()
	storage.log_block(self)
end

function M:pause()
	self.timer:pause()
end

function M:resume()
	self.timer:resume()
end

function M:is_paused()
	return self.timer:is_paused()
end

return M
