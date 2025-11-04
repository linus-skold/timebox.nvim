local M = {}

local dir = nil

function M.load_blocks()
	-- Placeholder for loading blocks from storage
	return {}
end

function M.save_blocks(tasks)
	-- Placeholder for saving blocks to storage
end

function M.log_block(task)
	-- Placeholder for logging an ended block
end

function M.setup(opts)
	dir = opts.dir
end

return M
