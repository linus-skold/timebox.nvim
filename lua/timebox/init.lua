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

	local function continue_prompt()
		Snacks.input({ prompt = " Continue working on:" .. current_block.name .. " (y/n): " }, function(input)
			if input == "y" then
				vim.notify("Resumed task: " .. current_block.name, vim.log.levels.INFO)
				current_block:resume() -- should resume the current block and remove the coffee break from the elapsed time
			else
				vim.notify("No task resumed. Ready for a new task!", vim.log.levels.INFO)
			end
		end)
	end

	local function on_timer_end()
		vim.notify(" Timer ended for task: " .. current_block.name, vim.log.levels.INFO)
		current_block:stop()
		storage.log_block(current_block)

		Snacks.input({ prompt = " Take a break? (y/n): " }, function(input)
			if input == "y" then
				vim.notify("Started coffee break.", vim.log.levels.INFO)
				-- start coffee break logic here
				--
			else
				continue_prompt()
			end
		end)
	end

	local function on_stop()
		vim.notify(" Timer stopped for task: " .. current_block.name, vim.log.levels.INFO)
		current_block:stop()
		storage.log_block(current_block)
	end

	local function on_pause()
		vim.notify(" Timer paused for task: " .. current_block.name, vim.log.levels.INFO)
	end

	local function on_resume()
		vim.notify(" Timer resumed for task: " .. current_block.name, vim.log.levels.INFO)
	end

	local function start_task()
		Snacks.input({ prompt = "What will you work on? " }, function(input)
			if input and input ~= "" then
				local t = timer.new(config.duration.work, {
					on_timer_end = on_timer_end,
					on_stop = on_stop,
					on_pause = on_pause,
					on_resume = on_resume,
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
end

return M
