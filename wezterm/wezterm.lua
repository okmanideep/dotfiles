local wezterm = require 'wezterm';

local config = {}

-- helps provide clearer error messages
if wezterm.config_builder then
  config = wezterm.config_builder()
end

config.color_scheme = "OneHalfDark"
config.use_fancy_tab_bar = true
config.default_prog = {"C:\\Program Files\\WindowsApps\\Microsoft.PowerShell_7.3.3.0_x64__8wekyb3d8bbwe\\pwsh.exe" }
config.leader = { key="a", mods="CTRL" }
config.hide_tab_bar_if_only_one_tab = true
config.keys = {
	{ key = "t", mods = "CTRL",   action=wezterm.action.SpawnCommandInNewTab{}},
	{ key = "1", mods = "LEADER", action=wezterm.action{ActivateTab=0}},
	{ key = "2", mods = "LEADER", action=wezterm.action{ActivateTab=1}},
	{ key = "3", mods = "LEADER", action=wezterm.action{ActivateTab=2}},
	{ key = "4", mods = "LEADER", action=wezterm.action{ActivateTab=3}},
	{ key = "5", mods = "LEADER", action=wezterm.action{ActivateTab=4}},
	{ key = "6", mods = "LEADER", action=wezterm.action{ActivateTab=5}},
	{ key = "7", mods = "LEADER", action=wezterm.action{ActivateTab=6}},
	{ key = "8", mods = "LEADER", action=wezterm.action{ActivateTab=7}},
	{ key = "9", mods = "LEADER", action=wezterm.action{ActivateTab=8}},
}

-- https://github.com/wez/wezterm/issues/522 for renaming tab title

return config
