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

config.audible_bell = "Disabled"
config.adjust_window_size_when_changing_font_size = false

config.font = wezterm.font("FiraCode Nerd Font")
-- config.default_prog = { "/usr/bin/zsh", "-l" }
-- config.default_prog = { "wsl" }
-- config.default_domain = "WSL:Ubuntu"

config.enable_wayland = false

config.mouse_bindings = {
	{
		event = {
			Up = {
				streak = 1,
				button = "Left",
			},
		},
		mods = "NONE",
		action = wezterm.action.CompleteSelectionOrOpenLinkAtMouseCursor("Clipboard"),
	},
	{
		event = {
			Down = {
				streak = 1,
				button = "Right",
			},
		},
		mods = "NONE",
		action = wezterm.action.PasteFrom("Clipboard"),
	},
}

return config
