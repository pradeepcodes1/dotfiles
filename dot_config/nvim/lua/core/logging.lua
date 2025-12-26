-- Centralized logging for Neovim
-- Writes JSON logs to shared dotfiles log file

local M = {}

local config = {
	log_dir = vim.fn.expand("$HOME/.local/state/dotfiles/logs"),
	log_file = "dotfiles.jsonl",
	max_size_mb = 10,
	console_level = "WARN", -- WARN/ERROR show via notify
	file_level = "DEBUG", -- Everything to file
	enabled = vim.env.DOTFILES_JSON_LOG == "1",
}

local levels = { DEBUG = 0, INFO = 1, WARN = 2, ERROR = 3 }

local function json_escape(str)
	if type(str) ~= "string" then
		str = tostring(str)
	end
	return str:gsub("\\", "\\\\"):gsub('"', '\\"'):gsub("\n", "\\n"):gsub("\r", "\\r"):gsub("\t", "\\t")
end

local function build_json(level, component, message, extra)
	local ts = os.date("!%Y-%m-%dT%H:%M:%S.000Z")
	local parts = {
		string.format(
			'{"ts":"%s","level":"%s","component":"%s","msg":"%s","source":"nvim","pid":%d',
			ts,
			level,
			json_escape(component),
			json_escape(message),
			vim.fn.getpid()
		),
	}

	if extra then
		for k, v in pairs(extra) do
			if type(v) == "number" then
				table.insert(parts, string.format(',"%s":%s', k, v))
			else
				table.insert(parts, string.format(',"%s":"%s"', k, json_escape(v)))
			end
		end
	end

	table.insert(parts, "}")
	return table.concat(parts)
end

local function write_log(json_entry)
	if not config.enabled then
		return
	end

	vim.fn.mkdir(config.log_dir, "p")
	local log_path = config.log_dir .. "/" .. config.log_file
	local file = io.open(log_path, "a")
	if file then
		file:write(json_entry .. "\n")
		file:close()
	end
end

local function should_console(level)
	return levels[level] >= levels[config.console_level]
end

local function should_file(level)
	return config.enabled and levels[level] >= levels[config.file_level]
end

function M.log(level, component, message, extra)
	level = level:upper()

	-- Write to file
	if should_file(level) then
		local json = build_json(level, component, message, extra)
		vim.schedule(function()
			write_log(json)
		end)
	end

	-- Show via notify for console levels
	if should_console(level) then
		local ok, notify = pcall(require, "notify")
		if ok then
			local notify_level = vim.log.levels[level] or vim.log.levels.INFO
			notify(message, notify_level, { title = component })
		end
	end
end

function M.debug(component, message, extra)
	M.log("DEBUG", component, message, extra)
end

function M.info(component, message, extra)
	M.log("INFO", component, message, extra)
end

function M.warn(component, message, extra)
	M.log("WARN", component, message, extra)
end

function M.error(component, message, extra)
	M.log("ERROR", component, message, extra)
end

-- Log with timing measurement
function M.timed(component, description, fn)
	local start = vim.loop.hrtime()
	local ok, result = pcall(fn)
	local duration_ms = (vim.loop.hrtime() - start) / 1000000

	if ok then
		M.log("DEBUG", component, description .. " completed", { duration_ms = math.floor(duration_ms) })
		return result
	else
		M.log("ERROR", component, description .. " failed", {
			duration_ms = math.floor(duration_ms),
			error = tostring(result),
		})
		error(result)
	end
end

function M.setup(opts)
	config = vim.tbl_deep_extend("force", config, opts or {})
end

return M
