---@class Timer

local M = {}
M.__index = M

---@param duration number
---@param callbacks { on_stop: fun(), on_pause: fun(), on_resume: fun() }
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

---@param duration number
---@param end_callback fun()
---@return number
function M:start()
	self.timer = self.uv.new_timer()
	self.timer:start(self.duration, 0, self.stop)
	self.start_time = os.time()
	return self.start_time
end

---@
function M:stop()
	if self.timer then
		self.timer:stop()
		self.timer:close()
		self.timer = nil
		if self.callbacks.on_stop then
			self.callbacks.on_stop()
		end
	end
end

---@
function M:pause()
	if self.timer then
		self.timer:stop()
		self.elapsed = os.time() - self.start_time
		if self.callbacks.on_pause then
			self.callbacks.on_pause()
		end
	end
end

---@
function M:resume()
	if self.timer then
		self.timer:start(self.duration - self.elapsed, 0, self.callbacks.on_timer_end)
		self.start_time = os.time()
		if self.callbacks.on_resume then
			self.callbacks.on_resume()
		end
	end
end

---@return number
function M:get_elapsed()
	if self.start_time then
		return os.time() - self.start_time
	else
		return 0
	end
end

return M
