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

config.audible_bell = "SystemBeep"
config.adjust_window_size_when_changing_font_size = false

config.font = wezterm.font_with_fallback({
	{ family = "FiraCode Nerd Font" },
	{ family = "Noto Sans CJK JP" },
	-- { family = "Noto Sans CJK JP", assume_emoji_presentation = true },
	-- { family = "Noto Sans Mono", assume_emoji_presentation = true },
	-- { family = "Source Han Code JP L", assume_emoji_presentation = false },
	-- { family = "Source Han Code JP L", assume_emoji_presentation = true },
})
config.font_size = 11
-- config.default_prog = { "/usr/bin/zsh", "-l" }
-- config.default_prog = { "wsl" }
-- config.default_domain = "WSL:Ubuntu"

config.enable_wayland = true
config.enable_kitty_keyboard = true

config.use_ime = true
config.enable_csi_u_key_encoding = false
config.keys = {
	{
		key = "v",
		mods = "CTRL",
		action = wezterm.action.PasteFrom("Clipboard"),
	},
}

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
	{
		event = {
			Down = {
				streak = 1,
				button = { WheelUp = 1 },
			},
		},
		mods = "NONE",
		action = wezterm.action.SendString("\027[5;30012~"),
	},
	{
		event = {
			Down = {
				streak = 1,
				button = { WheelDown = 1 },
			},
		},
		mods = "NONE",
		action = wezterm.action.SendString("\027[5;30013~"),
	},
}

return config
