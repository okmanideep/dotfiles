local wezterm = require 'wezterm';

local config = {}

-- helps provide clearer error messages
if wezterm.config_builder then
	config = wezterm.config_builder()
end

config.color_scheme_dirs = { wezterm.home_dir .. "/Documents/code/personal/dotfiles/wezterm" }
config.color_scheme = "okmanideep"
config.use_fancy_tab_bar = true
config.default_prog = { "C:\\Program Files\\WindowsApps\\Microsoft.PowerShell_7.3.3.0_x64__8wekyb3d8bbwe\\pwsh.exe" }
config.leader = { key = "a", mods = "CTRL" }
config.keys = {
	{ key = "t", mods = "CTRL",   action = wezterm.action.SpawnCommandInNewTab {} },
	{ key = "1", mods = "ALT", action = wezterm.action.ActivateTab(0) },
	{ key = "2", mods = "ALT", action = wezterm.action.ActivateTab(1) },
	{ key = "3", mods = "ALT", action = wezterm.action.ActivateTab(2) },
	{ key = "4", mods = "ALT", action = wezterm.action.ActivateTab(3) },
	{ key = "5", mods = "ALT", action = wezterm.action.ActivateTab(4) },
	{ key = "6", mods = "ALT", action = wezterm.action.ActivateTab(5) },
	{ key = "7", mods = "ALT", action = wezterm.action.ActivateTab(6) },
	{ key = "8", mods = "ALT", action = wezterm.action.ActivateTab(7) },
	{ key = "9", mods = "ALT", action = wezterm.action.ActivateTab(8) },
	{ key = "v", mods = "ALT", action = wezterm.action.PasteFrom('Clipboard')},
	{ key = "r", mods = "CTRL|SHIFT", action = wezterm.action.ReloadConfiguration},
}
config.window_decorations = "RESIZE"
config.initial_cols = 120
config.initial_rows = 44

local bg_color = "#282c34"
local fg_color = "#dcdfe4"

-- https://github.com/wez/wezterm/issues/522 for renaming tab title
wezterm.on("format-tab-title", function(tab, _, _, _, _, _)
	local pane_title = tab.active_pane.title
	local user_title = tab.active_pane.user_vars.panetitle

	if user_title ~= nil and #user_title > 0 then
		pane_title = (tab.tab_index + 1) .. ":" .. user_title
	end

	local bg = wezterm.color.parse(bg_color)
	local fg = wezterm.color.parse(fg_color)
	if (not tab.is_active) then
		bg = bg:darken(0.2)
		fg = fg:darken(0.2)
	end

	return {
		{Background={Color=bg}},
		{Foreground={Color=fg}},
		{Text=" " .. pane_title .. " "},
	}
end)


return config
