---@class Block
---@field name string
---@field start_time number
---@field end_time number
---@field elapsed number
---@field block_type string

local M = {}
M.__index = M

function M.new(name, block_type, timer)
	local self = setmetatable({}, M)
	self.name = name
	self.block_type = block_type
	self.timer = timer
	return self
end

function M:start()
	self.start_time = os.time()
	self.timer:start()
end

function M:stop()
	self.end_time = os.time()
	self.elapsed = self.end_time - self.start_time
	self.timer:stop()
end

function M:pause()
	self.timer:pause()
end

function M:resume()
	self.timer:resume()
end

return M
