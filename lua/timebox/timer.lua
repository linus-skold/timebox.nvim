local M = {}

local duration = {}

local uv = vim.loop
local timer = nil
local start_time = nil

function M.start()
	timer = uv.new_timer()
	start_time = os.time()
	timer:start(duration.work, 0, function()
		local elapsed = os.time() - start_time
		print("Timer running: " .. elapsed .. " seconds elapsed")
	end)
end

function M.stop()
	print("Timer stopped")
end

function M.pause()
	print("Timer paused")
end

function M.show()
	print("Showing timer status")
end

function M.setup(opts)
	duration = opts.duration or {}
end

return M
