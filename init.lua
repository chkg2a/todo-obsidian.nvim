local M = {}

local state = {
	floating = {
		buf = -1,
		win = -1,
	},
}

-- Default config
local config = {
	file_paths = {
		main_todo = vim.fn.expand("~/todo.md"), -- fallback if not overridden
	},
}

function M.setup(user_config)
	-- Merge user config with defaults
	config = vim.tbl_deep_extend("force", config, user_config or {})

	vim.api.nvim_create_user_command("OpenTodo", function()
		M.toggle_todo()
	end, {})

	-- Auto open on startup
	-- vim.schedule(function()
	-- 	M.toggle_todo()
	-- end)

	-- Auto-save on floating win close
	vim.api.nvim_create_autocmd("WinClosed", {
		pattern = "*",
		callback = function(args)
			local winid = tonumber(args.match)
			if not winid then
				return
			end

			local buf = vim.api.nvim_win_get_buf(winid)
			if
				vim.api.nvim_buf_is_valid(buf)
				and vim.api.nvim_buf_get_option(buf, "modified")
				and vim.api.nvim_buf_get_name(buf) ~= ""
			then
				vim.api.nvim_buf_call(buf, function()
					vim.cmd("silent write!")
				end)
			end
		end,
	})
end

function M.toggle_todo()
	if not vim.api.nvim_win_is_valid(state.floating.win) then
		state.floating = M.open_floating_window({
			filepath = config.file_paths.main_todo
		})
	else
		vim.api.nvim_win_close(state.floating.win, true)
		state.floating = { buf = -1, win = -1 }
	end
end

function M.open_floating_window(opts)
	opts = opts or {}
	local filepath = opts.filepath or config.filepath

	local columns = vim.o.columns
	local lines = vim.o.lines

	local width = opts.width or math.floor(columns * 0.5)
	local height = opts.height or math.floor(lines * 0.8)

	local col = math.floor((columns - width) / 2)
	local row = math.floor((lines - height) / 2)

	local buf = nil
	local abs_path = vim.fn.fnamemodify(filepath, ":p")

	for _, b in ipairs(vim.api.nvim_list_bufs()) do
		if vim.api.nvim_buf_get_name(b) == abs_path then
			buf = b
			break
		end
	end

	if not buf or not vim.api.nvim_buf_is_valid(buf) then
		buf = vim.api.nvim_create_buf(true, false)
		local lines = vim.fn.readfile(abs_path)
		vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
		vim.api.nvim_buf_set_name(buf, abs_path)
	end

	local win_opts = {
		relative = "editor",
		width = width,
		height = height,
		col = col,
		row = row,
		style = "minimal",
		border = "rounded",
	}

	local win = vim.api.nvim_open_win(buf, true, win_opts)

	return { buf = buf, win = win }
end

return M
