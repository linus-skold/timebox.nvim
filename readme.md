# Timebox 

Timebox is a simple nvim plugin that allows you to configure a timer for tasks, to keep momentum and focus.
It has a dependency on [snacks.nvim](https://github.com/folke/snacks.nvim) for rendering input fields.
There is an optional dependency on [dooing](https://github.com/atiladefreitas/dooing) for task management integration.
> [!Important] 
> The dooing integration is currently experimental and may not work as expected.
> Expected behavior is that when a dooing task is started through timebox, it will be created in timebox for tracking purposes, and if the task is new and created through timebox it  should be created in dooing as well. 


## Features
- Start, pause, and reset a timer for focused work sessions.
- Customizable time intervals for work sessions and breaks.

## Configuration
### Lazy
```lua
return {
	"linus-skold/timebox.nvim",
	dependencies = { "folke/snacks.nvim" },
	opts = {
		duration = {
			work = 25 * 60,
			coffee = 5 * 60,
		},
        win = {
            width = 120,
        },
    },
}
```
