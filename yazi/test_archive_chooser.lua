-- Run from the repository root: lua yazi/test_archive_chooser.lua
local emitted, commands, notices
local state = {}
ya = {
	sync = function(fn) return function(...) return fn(state, ...) end end,
	emit = function(event, args) emitted[#emitted + 1] = { event, args } end,
	notify = function(opts) notices[#notices + 1] = opts end,
}
Command = setmetatable({ PIPED = "piped" }, { __call = function(_, cmd)
	commands[#commands + 1] = cmd
	local command = {}
	function command:arg() return self end
	function command:stdout() return self end
	function command:stderr() return self end
	function command:output()
		return { status = { code = 1 }, stderr = "not an archive yet" }
	end
	return command
end })
local plugin = dofile("yazi/plugins/archive-edit.yazi/main.lua")

local function enter(name, directory, chooser)
	emitted, commands, notices = {}, {}, {}
	rt = { args = { chooser_file = chooser and "/tmp/selection" or nil } }
	cx = { active = { current = {
		cwd = "/downloads",
		hovered = name and {
			url = setmetatable({ parent = "/downloads" }, {
				__tostring = function() return "/downloads/" .. name end,
			}),
			name = name,
			cha = { len = 0, is_dir = directory },
		} or nil,
	} } }
	plugin:entry({ args = { "enter" } })
end

for _, name in ipairs({ "download.zip", "download.7z", "download.tar.gz", "download.txt" }) do
	enter(name, false, true)
	assert(#commands == 0, name .. ": chooser tried to inspect/extract the pending download")
	assert(#notices == 0 and #emitted == 1 and emitted[1][1] == "open" and emitted[1][2].hovered,
		name .. ": chooser must select the hovered file")
end
enter("folder", true, true)
assert(#commands == 0 and #emitted == 1 and emitted[1][1] == "enter")
enter(nil, false, true)
assert(#commands == 0 and #emitted == 0)
enter("download.zip", false, false)
assert(commands[1] == "7z" and #emitted == 0 and #notices == 1,
	"ordinary browsing must still inspect archives")
enter("download.txt", false, false)
assert(#commands == 0 and #emitted == 1 and emitted[1][1] == "open")
print("PASS: chooser selects pending archives; directories and ordinary browsing retain their behavior")
