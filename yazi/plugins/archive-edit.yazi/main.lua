local M = {}

local DEFAULT_MAX_SIZE = 100 * 1024 * 1024
local DEFAULT_MAX_FILES = 100

local function notify(level, content)
	ya.notify({ title = "Archive", content = content, timeout = 5, level = level })
end

local function starts_with(path, root)
	return path == root or path:sub(1, #root + 1) == root .. "/"
end

local function archive_kind(name)
	name = name:lower()
	if name:sub(-4) == ".zip" then
		return "zip"
	elseif name:sub(-3) == ".7z" then
		return "7z"
	elseif name:sub(-7) == ".tar.gz" or name:sub(-4) == ".tgz" then
		return "tar.gz"
	elseif name:sub(-7) == ".tar.xz" or name:sub(-4) == ".txz" then
		return "tar.xz"
	elseif name:sub(-4) == ".tar" then
		return "tar"
	elseif name:sub(-7) == ".tar.bz" or name:sub(-8) == ".tar.bz2" or name:sub(-4) == ".tbz" or name:sub(-5) == ".tbz2" then
		return "tar.bz2"
	end
end

local function sanitize(name)
	local safe = name:gsub("[^%w%._%-]", "_")
	return safe == "" and "archive" or safe
end

local function q(path)
	return "'" .. tostring(path):gsub("'", "'\\''") .. "'"
end

local function trim(s)
	return tostring(s or ""):gsub("^%s+", ""):gsub("%s+$", "")
end

local function run_shell(command)
	local pipe = io.popen(command .. " 2>&1")
	if not pipe then
		return false, command
	end
	local output = pipe:read("*a")
	local ok, _, code = pipe:close()
	return ok or code == 0, trim(output)
end

local function shell_count_files(root)
	local ok, output = run_shell("find " .. q(root) .. " -type f | wc -l")
	if not ok then
		return nil, output
	end
	return tonumber(output:match("%d+")) or 0
end

local function temp_parent(root)
	return root:gsub("/work/?$", "")
end

local function save_session(state, session, cleanup)
	local count, err = shell_count_files(session.root)
	if not count then
		return false, "Archive save failed: " .. err
	elseif count > state.max_files then
		return false, string.format("Archive has too many entries: %d > %d", count, state.max_files)
	end

	local tmp = string.format("%s.yazi-tmp-%s", session.archive, tostring(ya.time()):gsub("%W", ""))
	local create
	if session.kind == "zip" then
		create = "cd " .. q(session.root) .. " && 7z a -tzip " .. q(tmp) .. " ."
	elseif session.kind == "7z" then
		create = "cd " .. q(session.root) .. " && 7z a -t7z " .. q(tmp) .. " ."
	elseif session.kind == "tar.gz" then
		create = "tar -czf " .. q(tmp) .. " -C " .. q(session.root) .. " ."
	elseif session.kind == "tar.xz" then
		create = "tar -cJf " .. q(tmp) .. " -C " .. q(session.root) .. " ."
	elseif session.kind == "tar" then
		create = "tar -cf " .. q(tmp) .. " -C " .. q(session.root) .. " ."
	else
		create = "tar -cjf " .. q(tmp) .. " -C " .. q(session.root) .. " ."
	end

	local ok, output = run_shell(create)
	if not ok then
		run_shell("rm -f " .. q(tmp))
		return false, "Archive save failed: " .. (output ~= "" and output or create)
	end

	ok, output = run_shell("mv -f " .. q(tmp) .. " " .. q(session.archive))
	if not ok then
		run_shell("rm -f " .. q(tmp))
		return false, "Archive save failed: " .. (output ~= "" and output or "mv")
	end

	if cleanup then
		run_shell("rm -rf " .. q(temp_parent(session.root)))
		state.sessions[session.root] = nil
	end
	return true, "Archive saved: " .. session.archive
end

local init_state = ya.sync(function(state, opts)
	opts = opts or {}
	state.max_size = opts.max_size or DEFAULT_MAX_SIZE
	state.max_files = opts.max_files or DEFAULT_MAX_FILES
	state.sessions = state.sessions or {}
	if state.subscribed then
		return false
	end
	state.subscribed = true
	return true
end)

local current_hovered = ya.sync(function(state)
	local h = cx.active.current.hovered
	if not h then
		return nil
	end
	return {
		path = tostring(h.url),
		parent = tostring(h.url.parent),
		cwd = tostring(cx.active.current.cwd),
		name = tostring(h.name or h.url.name),
		size = h.cha and h.cha.len,
		is_dir = h.cha and h.cha.is_dir or false,
		max_size = state.max_size or DEFAULT_MAX_SIZE,
		max_files = state.max_files or DEFAULT_MAX_FILES,
	}
end)

local add_session = ya.sync(function(state, session)
	state.sessions = state.sessions or {}
	state.sessions[session.root] = session
end)

local live_session = ya.sync(function(state, archive)
	for _, session in pairs(state.sessions or {}) do
		if session.archive == archive then
			return { root = session.root }
		end
	end
end)

local flush_current = ya.sync(function(state)
	local cwd = tostring(cx.active.current.cwd)
	for root, session in pairs(state.sessions or {}) do
		if starts_with(cwd, root) and not session.saving then
			session.saving = true
			local ok, msg = save_session(state, session, false)
			notify(ok and "info" or "error", msg)
			session.saving = false
			return
		end
	end
	notify("warn", "No editable archive here")
end)

local on_cd = ya.sync(function(state)
	local new_cwd = tostring(cx.active.current.cwd)
	local old_cwd = state.last_cwd
	local leaving
	for root, session in pairs(state.sessions or {}) do
		if old_cwd and starts_with(old_cwd, root) and not starts_with(new_cwd, root) then
			leaving = session
			break
		end
	end

	if leaving and not leaving.saving then
		leaving.saving = true
		notify("info", "Saving archive: " .. leaving.archive)
		local ok, msg = save_session(state, leaving, true)
		notify(ok and "info" or "error", msg)
		if ok and leaving.return_to and starts_with(new_cwd, temp_parent(leaving.root)) then
			state.last_cwd = leaving.return_to
			ya.emit("cd", { Url(leaving.return_to) })
			return
		elseif state.sessions[leaving.root] then
			state.sessions[leaving.root].saving = false
		end
	end
	state.last_cwd = new_cwd
end)

local function command_output(cmd, args)
	local output, err = Command(cmd):arg(args):stdout(Command.PIPED):stderr(Command.PIPED):output()
	if not output then
		return nil, tostring(err)
	end
	local status = output.status
	if status and (status.success or status.code == 0) then
		return output.stdout or "", nil
	end
	return nil, trim(output.stderr) ~= "" and trim(output.stderr) or ("exit " .. tostring(status and status.code or "?"))
end

local function command_status(cmd, args)
	local output, err = Command(cmd):arg(args):stdout(Command.PIPED):stderr(Command.PIPED):output()
	if not output then
		return false, tostring(err)
	end
	local status = output.status
	if status and (status.success or status.code == 0) then
		return true, nil
	end
	return false, trim(output.stderr) ~= "" and trim(output.stderr) or ("exit " .. tostring(status and status.code or "?"))
end

local function count_7z(path)
	local out, err = command_output("7z", { "l", "-ba", "--", path })
	if not out then
		return nil, err
	end
	local count = 0
	for line in out:gmatch("[^\n]+") do
		local attr = line:match("^%d%d%d%d%-%d%d%-%d%d%s+%d%d:%d%d:%d%d%s+(%S+)%s+")
		if attr and not attr:match("D") then
			count = count + 1
		end
	end
	return count
end

local function count_tar(kind, path)
	local flag = kind == "tar.gz" and "-tzf" or kind == "tar.xz" and "-tJf" or kind == "tar" and "-tf" or "-tjf"
	local out, err = command_output("tar", { flag, path })
	if not out then
		return nil, err
	end
	local count = 0
	for line in out:gmatch("[^\n]+") do
		if line ~= "" and line:sub(-1) ~= "/" then
			count = count + 1
		end
	end
	return count
end

local function archive_count(kind, path)
	if kind == "zip" or kind == "7z" then
		return count_7z(path)
	end
	return count_tar(kind, path)
end

local function extract(kind, archive, work)
	if kind == "zip" or kind == "7z" then
		return command_status("7z", { "x", "-y", "-o" .. work, "--", archive })
	elseif kind == "tar.gz" then
		return command_status("tar", { "-xzf", archive, "-C", work })
	elseif kind == "tar.xz" then
		return command_status("tar", { "-xJf", archive, "-C", work })
	elseif kind == "tar" then
		return command_status("tar", { "-xf", archive, "-C", work })
	end
	return command_status("tar", { "-xjf", archive, "-C", work })
end

function M:setup(opts)
	if init_state(opts) then
		ps.sub("cd", function() on_cd() end)
	end
end

function M:entry(job)
	local action = job.args[1]
	if action == "flush" then
		flush_current()
		return
	elseif action ~= "enter" then
		return
	end

	local h = current_hovered()
	if not h then
		return
	elseif h.is_dir then
		ya.emit("enter", { hovered = true })
		return
	end

	local kind = archive_kind(h.name)
	if not kind then
		ya.emit("open", { hovered = true })
		return
	end

	local live = live_session(h.path)
	if live then
		notify("warn", "Archive already open for editing")
		return
	end

	if h.size and h.size > h.max_size then
		notify("error", string.format("Archive too large: %d > %d", h.size, h.max_size))
		return
	end

	local count, err = archive_count(kind, h.path)
	if not count then
		notify("error", "Archive count failed: " .. err)
		return
	elseif count > h.max_files then
		notify("error", string.format("Archive has too many entries: %d > %d", count, h.max_files))
		return
	end

	local base = (os.getenv("TMPDIR") or "/tmp") .. "/yazi-archive"
	local temp = string.format("%s/%s-%s", base, tostring(ya.time()):gsub("%W", ""), sanitize(h.name))
	local work = temp .. "/work"
	local ok, mkdir_err = command_status("mkdir", { "-p", work })
	if not ok then
		notify("error", "Archive temp failed: " .. mkdir_err)
		return
	end

	ok, err = extract(kind, h.path, work)
	if not ok then
		Command("rm"):arg({ "-rf", temp }):status()
		notify("error", "Archive extract failed: " .. err)
		return
	end

	add_session({ archive = h.path, parent = h.parent, kind = kind, root = work, return_to = h.cwd, saving = false })
	ya.emit("cd", { Url(work) })
end

return M
