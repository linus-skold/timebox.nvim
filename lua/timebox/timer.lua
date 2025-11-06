---@class Timer

local M = {}
M.__index = M

---@param duration number
---@param callbacks { on_timer_end: fun() }
function M.new(duration, callbacks)
	local self = setmetatable({}, M)
	self.uv = vim.loop
	self.start_time = nil
	self.timer = nil
	self.elapsed = 0
	self.duration = duration
	self.callbacks = callbacks or {}
	return self
end

---@return number
function M:start()
	self.timer = self.uv.new_timer()
	self.timer:start(self.duration * 1000, 0, self.callbacks.on_timer_end)
	self.start_time = os.time()
	return self.start_time
end

---@return number
function M:stop()
	self.end_time = os.time()
	if self.timer then
		self.timer:stop()
		self.timer:close()
		self.timer = nil
	end
	return self:get_elapsed()
end

function M:pause()
	if self.timer then
		self.timer:stop()
		self.elapsed = self.elapsed + (os.time() - self.start_time)
	end
end

function M:resume()
	if self.timer then
		self.timer:start((self.duration - self.elapsed) * 1000, 0, self.callbacks.on_timer_end)
		self.start_time = os.time()
	end
end

---@return number
function M:get_elapsed()
	if self.start_time then
		return self.elapsed + (os.time() - self.start_time)
	else
		return 0
	end
end

---@return boolean
function M:is_paused()
	return self.timer == nil or not self.timer:is_active()
end

return M
