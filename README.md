<h1 align="center">todo-obsidian.nvim</h1>
<hr>

A neovim plugin for accessing todo lists for global space, and a project specific todo list.

### Demo

https://github.com/user-attachments/assets/875c6145-9768-472f-a8cb-69e81337ef23

### Installation

lazy.nvim
```lua
	{
		"chkg2a/todo-obsidian",
		lazy = false, -- load on startup
		priority = 100, -- load early if needed
		opts = {
			file_paths = {
				main_todo = vim.fn.expand("~/.local/share/obsidian_ChK/journaling/todos/TODO.md"),
			},
		},
		config = function(_,opts)
			require("todo-obsidian").setup(opts)
		end,
	}
```

### Usage

Start using the Todo List by Typing the following command

```lua
:OpenTodo
```


If you want to set a keybind. Use this command
```lua
vim.keymap.set("n", "<A-t>", "<cmd> OpenTodo <CR>", { desc = "Open Project Todo"})

```

### TODO

- [ ] Project Specific TODO
