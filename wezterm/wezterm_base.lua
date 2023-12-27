local wezterm = require("wezterm")
wezterm.log_info("loading base config")
local config = {}

if wezterm.config_builder then
	config = wezterm.config_builder()
end

config.window_close_confirmation = "NeverPrompt"
config.hide_tab_bar_if_only_one_tab = true
-- config.color_scheme = "Earthsong"
config.color_scheme = "Bamboo"

-- config.font = wezterm.font("FiraMono Nerd Font")
-- config.default_prog = { "/usr/bin/zsh", "-l" }
-- config.default_prog = { "wsl" }
-- config.default_domain = "WSL:Ubuntu"
return config
