---@class Storage
---@field dir string
---@field logfile string

---@class Block
---@field name string
---@field start_time number
---@field end_time number
---@field elapsed number
---@field block_type string


local M = {}

local dir = nil
local logfile = nil

---@param blocks Block[]
function M.save_blocks(blocks)
	local content = vim.fn.json_encode(blocks)
	local f = io.open(logfile, "w")
	if f then
		f:write(content)
		f:close()
	end
end

---@return Block[]
function M.save_blocks()
	local f = io.open(logfile, "r")
	if not f then
		return {}
	end
	local content = f:read("*a")
	f:close()
	local ok, data = pcall(vim.fn.json_decode, content)
	return ok and data or {}
end

---@param block Block
function M.log_block(block)
	local blocks = load_blocks()
	table.insert(blocks, {
		task = block.name,
		start_time = block.start_time,
		end_time = block.end_time,
		elapsed = block.elapsed,
		block_type = block.block_type,
	})
	save_blocks(blocks)
end

---@param opts {dir: string}
function M.setup(opts)
	dir = opts.dir
	vim.fn.mkdir(dir, "p")
	logfile = dir .. "/timebox.json"
end

return M
