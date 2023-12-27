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

return config
