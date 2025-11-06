local storage = require("timebox.storage")

local M = {}

---@param blocks Block[]
local function summarize_blocks(blocks)
	local summary = {}
	for _, block in ipairs(blocks) do
		summary[block.name] = (summary[block.name] or 0) + block.elapsed 
	end
	return summary
end


local function graph_blocks(summary)
	local graph = {}
	local max_length = 40
	local max_duration = 0
	for _, dur in pairs(summary) do
		if dur > max_duration then
			max_duration = dur
		end
	end
	for task, dur in pairs(summary) do
		local bar_length = math.floor((dur / max_duration) * max_length)
		local bar = string.rep("█", bar_length)
		table.insert(graph, string.format("%-20s | %s (%.1f mins)", task, bar, dur / 60))
	end
	return graph
end

function M.show_breakdown()
	local blocks = storage.load_blocks()
	if #blocks == 0 then
		vim.notify("No blocks recorded yet.", vim.log.levels.INFO)
		return
	end

	local summary = summarize_blocks(blocks)
	local graph = graph_blocks(summary)

	-- open a scratch buffer
	vim.cmd("tabnew")
	local buf = vim.api.nvim_get_current_buf()
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, graph)
	vim.bo[buf].buftype = "nofile"
	vim.bo[buf].bufhidden = "wipe"
	vim.bo[buf].modifiable = false
	vim.bo[buf].filetype = "nagare_breakdown"
end

return M
