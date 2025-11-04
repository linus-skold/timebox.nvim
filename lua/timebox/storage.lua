local M = {}

local dir = nil
local logfile = nil

function M.load_blocks()
	local content = vim.fn.json_encode(blocks)
	local f = io.open(logfile, "w")
	if f then
		f:write(content)
		f:close()
	end
end

function M.save_blocks(tasks)
	local f = io.open(logfile, "r")
	if not f then
		return {}
	end
	local content = f:read("*a")
	f:close()
	local ok, data = pcall(vim.fn.json_decode, content)
	return ok and data or {}
end

function M.log_block(task)
	local blocks = load_blocks()
	table.insert(blocks, {
		task = task.name,
		start_time = task.start_time,
		end_time = task.end_time,
		stop_time = task.stop_time,
		block_type = task.block_type,
	})
	save_blocks(blocks)
end

function M.setup(opts)
	dir = opts.dir
	vim.fn.mkdir(dir, "p")
	logfile = dir .. "/timebox.json"
end

return M
