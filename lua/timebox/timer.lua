local M = {}

local uv = vim.loop
local timer = nil
local start_time = nil
local elapsed_time = 0

function M.start(duration, timer_start_callback)
	timer = uv.new_timer()
	start_time = os.time()
	timer:start(duration.work, 0, function()
		local stop_time = os.time()
		timer_start_callback(os.time() - start_time, stop_time)
	end)
end

function M.stop(timer_stop_callback)
	if timer then
		timer:stop()
		timer:close()
		timer = nil
		timer_stop_callback()
	end
end

function M.pause(timer_pause_callback)
	if timer then
		timer:stop()
		elapsed_time = os.time() - start_time
		timer_pause_callback()
	end
end

function M.resume(duration, timer_resume_callback)
	if timer then
		timer:start(duration.work, 0, function()
			timer_resume_callback(elapsed)
		end)
	end
end

function M.current_elapsed()
	if start_time then
		return os.time() - start_time
	else
		return 0
	end
end

return M
