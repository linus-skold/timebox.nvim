local config = require("timebox.config")
local storage = require("timebox.storage")
local timer = require("timebox.timer")
local M = {}

local current_task = nil

function M.setup(opts)
	config.setup(opts)
	storage.setup(config.options.storage)
	timer.setup(config.options)

	local function start_task()
		Snacks.input({ prompt = "What will you work on? " }, function(input)
			if input and input ~= "" then
				current_task = {
					name = input,
					start_time = os.time(),
					block_type = "work",
				}
				vim.notify("Started task: " .. input, vim.log.levels.INFO)
				timer.start()
			else
				vim.notify("Task name cannot be empty.", vim.log.levels.WARN)
			end
		end)
	end

	vim.api.nvim_create_user_command("TimeboxStart", start_task, {})
end

return M
