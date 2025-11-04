local config = require("timebox.config")
local storage = require("timebox.storage")
local timer = require("timebox.timer")
local M = {}

local current_task = nil

function M.setup(opts)
	config.setup(opts)
	storage.setup(config.options.storage)
	timer.setup(config.options)

	local function continue_prompt()
		Snacks.input({ prompt = " Continue working on:" .. current_task.name .. " (y/n): " }, function(input)
			if input == "y" then
				current_task = {
					name = current_task.name,
					start_time = os.time(),
					block_type = current_task.block_type,
				}
				vim.notify("Resumed task: " .. current_task.name, vim.log.levels.INFO)
				timer.start()
			else
				vim.notify("No task resumed. Ready for a new task!", vim.log.levels.INFO)
				start_task()
			end
		end)
	end

	local function on_block_end(block)
		Snacks.input({ prompt = " Take a break? (y/n): " }, function(input)
			if input == "y" then
				-- Start a coffee break
				current_task = {
					name = "Coffee Break",
					start_time = os.time(),
					block_type = "coffee",
				}
				vim.notify("Started coffee break.", vim.log.levels.INFO)
				timer.start()
			else
				vim.notify("No break taken. Ready for the next task!", vim.log.levels.INFO)
				continue_prompt()
			end
		end)
	end

	local function start_task()
		Snacks.input({ prompt = "What will you work on? " }, function(input)
			if input and input ~= "" then
				current_task = {
					name = input,
					start_time = os.time(),
					block_type = "work",
				}
				vim.notify("Started task: " .. input, vim.log.levels.INFO)
				timer.start(config.duration.work, function(elapsed, stop_time)
					on_block_end({
						name = current_task.name,
						start_time = current_task.start_time,
						end_time = stop_time,
						elapsed = elapsed,
						block_type = current_task.block_type,
					})
				end)
			else
				vim.notify("Task name cannot be empty.", vim.log.levels.WARN)
			end
		end)
	end

	local function pause_task()
		if current_task then
			timer.pause()
			vim.notify("Paused task: " .. current_task.name, vim.log.levels.INFO)
		else
			vim.notify("No active task to pause.", vim.log.levels.WARN)
		end
	end

	local function stop_task()
		if current_task then
			current_task.end_time = os.time()
			current_task.stop_time = os.time()
			storage.log_block(current_task)
			vim.notify("Stopped task: " .. current_task.name, vim.log.levels.INFO)
			current_task = nil
			timer.stop()
		else
			vim.notify("No active task to stop.", vim.log.levels.WARN)
		end
	end

	vim.api.nvim_create_user_command("TimeboxStart", start_task, {})
end

return M
