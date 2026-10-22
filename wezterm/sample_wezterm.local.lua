local wezterm = require("wezterm")
local mux = wezterm.mux
local config = wezterm.config_builder()

wezterm.on("gui-startup", function()
	local tab1, _, window = mux.spawn_window({
		-- cwd = wezterm.home_dir .. ".dotfiles/",
		args = { "/home/tshm/.nix-profile/bin/zsh", "-lic", "tm" },
	})
	tab1:set_title("Main")

	local tab2 = window:spawn_tab({
		domain = { DomainName = "WSL:Ubuntu" },
		args = { "/home/tshm/.nix-profile/bin/zsh", "-lic", "autossh -M 20007 tp" },
	})
	tab2:set_title("tp")

	tab1:activate()
end)

return config
