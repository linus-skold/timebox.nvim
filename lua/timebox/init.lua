local config = require("timebox.config")
local storage = require("timebox.storage")
local timer = require("timebox.timer")
local block = require("timebox.block")
local breakdown = require("timebox.breakdown")

local M = {}

local current_block = nil
local prev_block = nil

---@param opts? timebox.Config
function M.setup(opts)
	config.setup(opts)
	storage.setup(config.options.storage)
	local has_dooing = pcall(require, "dooing")
	local block_list = {} -- session block list
	local start_task
	local handle_block_completion

	handle_block_completion = function()
		vim.notify(" Timer ended for task: " .. current_block.name, vim.log.levels.INFO)
		current_block:stop()
		prev_block = current_block

		Snacks.input({ prompt = " Take a break? (y/n): " }, function(input)
			if input == "y" then
				vim.notify("Started coffee break.", vim.log.levels.INFO)
				current_block = block.new(
					"Coffee Break",
					"break",
					timer.new(config.options.duration.coffee, {
						on_timer_end = function()
							vim.notify(" Coffee break ended. Ready for a new task!", vim.log.levels.INFO)
							current_block:stop()
							start_task(prev_block and prev_block.name or "")
						end,
					})
				)
				current_block:start()
			else
				vim.notify("No break taken. Ready for a new task!", vim.log.levels.INFO)
				start_task(prev_block and prev_block.name or "")
			end
		end)
	end

	local function handle_manual_stop()
		vim.notify(" Timer stopped manually for task: " .. current_block.name, vim.log.levels.INFO)
		current_block:stop()
	end

	local function handle_pause()
		vim.notify(" Timer paused for task: " .. current_block.name, vim.log.levels.INFO)
		current_block:pause()
	end

	local function handle_resume()
		vim.notify(" Timer resumed for task: " .. current_block.name, vim.log.levels.INFO)
		current_block:resume()
	end

	create_task = function(task_name)
		local t = timer.new(config.options.duration.work, {
			on_timer_end = handle_block_completion,
		})
		current_block = block.new(task_name, "work", t)
		Snacks.notifier.notify("Started task: " .. task_name, "info")
		table.insert(block_list, current_block)
		current_block:start()
	end

	task_input = function()
		Snacks.input({ prompt = "What will you work on? ", value = task_name }, function(input)
			if input and input ~= "" then
				create_task(input)
			else
				vim.notify("Task name cannot be empty.", vim.log.levels.WARN)
			end
		end)
	end

	get_session_blocks = function()
		return block_list
	end

	-- TODO: Handle if the UI is closed without new task selection or input
	start_task = function(task_name)
		if has_dooing then
			local s = require("dooing.state")

			local tasks = { { label = "↳ Manual input…", index = 0 } }

			for i, b in ipairs(get_session_blocks()) do
				table.insert(tasks, { label = b.name, index = i })
			end

			for i, todo in ipairs(s.todos) do
				if not todo.done then
					table.insert(tasks, { label = todo.text, index = i })
				end
			end

			vim.ui.select(tasks, {
				prompt = "Some text",
				format_item = function(item)
					return item.label
				end,
			}, function(selected)
				if selected.index == 0 then
					task_input()
				else
					create_task(selected.label)
				end
			end)
		else
			task_input()
		end
	end

	-- TODO: Clean up commands, maybe use a single command with args
	vim.api.nvim_create_user_command("TimeboxBreakdown", breakdown.show_breakdown, {})
	vim.api.nvim_create_user_command("TimeboxStart", start_task, {})
	vim.api.nvim_create_user_command("TimeboxPause", handle_pause, {})
	vim.api.nvim_create_user_command("TimeboxResume", handle_resume, {})
	vim.api.nvim_create_user_command("TimeboxStop", handle_manual_stop, {})
	vim.api.nvim_create_user_command("TimeboxStatus", function()
		if current_block then
			local status = current_block:is_paused() and "Paused" or "Running"
			local elapsed = current_block.timer:get_elapsed() .. "s"
			vim.notify(
				"Current task: " .. current_block.name .. "\nStatus: " .. status .. " with " .. elapsed,
				vim.log.levels.INFO
			)
		else
			vim.notify("No active task.", vim.log.levels.INFO)
		end
	end, {})
end

return M
