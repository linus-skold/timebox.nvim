local config = require("timebox.config")
local storage = require("timebox.storage")
local timer = require("timebox.timer")
local block = require("timebox.block")

local M = {}

local current_block = nil

---@param opts? timebox.Config
function M.setup(opts)
	config.setup(opts)
	storage.setup(config.options.storage)

	local function stop_and_log(block)
		if block then
			block:stop()
			storage.log_block(block)
		end
	end

	local function handle_block_completion()
		vim.notify(" Timer ended for task: " .. current_block.name, vim.log.levels.INFO)
		stop_and_log(current_block)

		Snacks.input({ prompt = " Take a break? (y/n): " }, function(input)
			if input == "y" then
				vim.notify("Started coffee break.", vim.log.levels.INFO)
				-- TODO: start coffee break logic here
			else
				vim.notify("No break taken. Ready for a new task!", vim.log.levels.INFO)
			end
		end)
	end

	local function handle_manual_stop()
		vim.notify(" Timer stopped manually for task: " .. current_block.name, vim.log.levels.INFO)
		stop_and_log(current_block)
	end

	local function handle_pause()
		vim.notify(" Timer paused for task: " .. current_block.name, vim.log.levels.INFO)
		current_block:pause()
	end

	local function handle_resume()
		vim.notify(" Timer resumed for task: " .. current_block.name, vim.log.levels.INFO)
		current_block:resume()
	end

	local function start_task()
		Snacks.input({ prompt = "What will you work on? " }, function(input)
			if input and input ~= "" then
				local t = timer.new(config.options.duration.work, {
					on_timer_end = handle_block_completion,
				})

				current_block = block.new(input, "work", t)
				vim.notify("Started task: " .. input, vim.log.levels.INFO)
				current_block:start()
			else
				vim.notify("Task name cannot be empty.", vim.log.levels.WARN)
			end
		end)
	end

	vim.api.nvim_create_user_command("TimeboxStart", start_task, {})
	vim.api.nvim_create_user_command("TimeboxPause", handle_pause, {})
	vim.api.nvim_create_user_command("TimeboxResume", handle_resume, {})
	vim.api.nvim_create_user_command("TimeboxStop", handle_manual_stop, {})
end

return M
