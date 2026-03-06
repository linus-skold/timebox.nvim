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
	local block_list = {}
	local last_activity = os.time()
	local idle_timer = nil

	local create_task
	local task_input
	local start_task
	local handle_block_completion

	-- Update last_activity on any meaningful user interaction
	vim.api.nvim_create_autocmd(
		{ "CursorMoved", "CursorMovedI", "InsertEnter", "BufWritePost", "TextChanged", "TextChangedI" },
		{ callback = function() last_activity = os.time() end }
	)

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
		if not current_block then
			vim.notify("No active task.", vim.log.levels.WARN)
			return
		end
		vim.notify(" Timer stopped manually for task: " .. current_block.name, vim.log.levels.INFO)
		current_block:stop()
		current_block = nil
	end

	local function handle_pause()
		if not current_block then return end
		vim.notify(" Timer paused for task: " .. current_block.name, vim.log.levels.INFO)
		current_block:pause()
	end

	local function handle_resume()
		if not current_block then return end
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
		last_activity = os.time()
	end

	task_input = function(default_name)
		Snacks.input({ prompt = "What will you work on? ", value = default_name or "" }, function(input)
			if input and input ~= "" then
				create_task(input)
			else
				vim.notify("Task name cannot be empty.", vim.log.levels.WARN)
			end
		end)
	end

	start_task = function(task_name)
		if has_dooing then
			local s = require("dooing.state")

			local tasks = { { label = "↳ Manual input…", index = 0 } }

			for i, b in ipairs(block_list) do
				table.insert(tasks, { label = b.name, index = i })
			end

			for i, todo in ipairs(s.todos) do
				if not todo.done then
					table.insert(tasks, { label = todo.text, index = i })
				end
			end

			vim.ui.select(tasks, {
				prompt = "Select a task",
				format_item = function(item)
					return item.label
				end,
			}, function(selected)
				if not selected then return end
				if selected.index == 0 then
					task_input(task_name)
				else
					create_task(selected.label)
				end
			end)
		else
			task_input(task_name)
		end
	end

	-- Periodically check if the user has gone idle during an active work block
	idle_timer = vim.uv.new_timer()
	idle_timer:start(
		config.options.idle_check_interval * 1000,
		config.options.idle_check_interval * 1000,
		vim.schedule_wrap(function()
			if not current_block or current_block:is_paused() then return end
			local idle_seconds = os.time() - last_activity
			if idle_seconds < config.options.idle_timeout then return end

			current_block:pause()
			local idle_minutes = math.floor(idle_seconds / 60)
			Snacks.input(
				{ prompt = string.format("⏸ Idle for %dm — still working on '%s'? (y/n): ", idle_minutes, current_block.name) },
				function(input)
					if input == "y" then
						current_block:resume()
						last_activity = os.time()
					else
						vim.notify("Stopped task: " .. current_block.name, vim.log.levels.INFO)
						current_block:stop()
						prev_block = current_block
						current_block = nil
						start_task(prev_block.name)
					end
				end
			)
		end)
	)

	-- Prompt what to work on when Neovim finishes loading
	if config.options.startup_prompt then
		vim.api.nvim_create_autocmd("VimEnter", {
			once = true,
			callback = function()
				vim.defer_fn(function()
					start_task("")
				end, 500)
			end,
		})
	end

	vim.api.nvim_create_user_command("TimeboxBreakdown", breakdown.show_breakdown, {})
	vim.api.nvim_create_user_command("TimeboxStart", function() start_task("") end, {})
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
