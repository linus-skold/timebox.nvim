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
		local time_display
        -- ISSUE: Number presented as 3.@@@ when duration is above a minute
        if dur < 60 then
			time_display = string.format("%d seconds", math.floor(dur + 0.5))
		else
			time_display = string.format("%d minutes", math.floor(dur / 60 + 0.5))
		end
		table.insert(graph, string.format("%-20s | %s (%s)", task, bar, time_display))
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

	-- create a scratch buffer
	local buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, graph)
	vim.bo[buf].buftype = "nofile"
	vim.bo[buf].bufhidden = "wipe"
	vim.bo[buf].modifiable = false
	vim.bo[buf].filetype = "breakdown"

	-- calculate window size
    -- TODO: Dynamically size based on content? Alternatively user configurable and scrollable
	local width = 70
	local height = #graph
	local ui = vim.api.nvim_list_uis()[1]
	local win_width = ui.width
	local win_height = ui.height

	-- create floating window
	-- TODO: Add config options for window
    local win = vim.api.nvim_open_win(buf, true, {
		relative = "editor",
		width = width,
		height = height,
		col = math.floor((win_width - width) / 2),
		row = math.floor((win_height - height) / 2),
		style = "minimal",
		border = "rounded",
		title = " Task Breakdown ",
		title_pos = "center",
	})

	-- close on q or Esc
	vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = buf, nowait = true })
	vim.keymap.set("n", "<Esc>", "<cmd>close<cr>", { buffer = buf, nowait = true })
end

return M
