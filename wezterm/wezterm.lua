local wezterm = require("wezterm")

local useWSL = false
local home = os.getenv("HOME")
if home == nil then
	home = os.getenv("USERPROFILE")
	package.path = package.path .. ";" .. home .. "\\.dotfiles\\wezterm\\?.lua"
	useWSL = true
else
	package.path = package.path .. ";" .. home .. "/.dotfiles/wezterm/?.lua"
end
wezterm.log_info("HOME: ", home)

local config = require("wezterm_base")

if useWSL then
	config.default_prog = { "wsl" }
	config.default_domain = "WSL:Ubuntu"
end
-- config.color_scheme = "AdventureTime"

local local_path = home .. "/.wezterm.local.lua"
local local_file = io.open(local_path, "r")
if local_file then
	local_file:close()
	for key, value in pairs(dofile(local_path)) do
		config[key] = value
	end
end

return config
