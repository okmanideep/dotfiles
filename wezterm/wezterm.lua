local wezterm = require 'wezterm';

local config = {}

-- helps provide clearer error messages
if wezterm.config_builder then
	config = wezterm.config_builder()
end

-- ❤️👉🙏
config.unicode_version = 14
config.color_scheme_dirs = { wezterm.home_dir .. "/Documents/code/personal/dotfiles/wezterm" }
config.color_scheme = "okmanideep"
config.use_fancy_tab_bar = true
config.keys = {
	{ key = "t",     mods = "CTRL",       action = wezterm.action.SpawnCommandInNewTab {} },
	{ key = "1",     mods = "ALT",        action = wezterm.action.ActivateTab(0) },
	{ key = "2",     mods = "ALT",        action = wezterm.action.ActivateTab(1) },
	{ key = "3",     mods = "ALT",        action = wezterm.action.ActivateTab(2) },
	{ key = "4",     mods = "ALT",        action = wezterm.action.ActivateTab(3) },
	{ key = "5",     mods = "ALT",        action = wezterm.action.ActivateTab(4) },
	{ key = "6",     mods = "ALT",        action = wezterm.action.ActivateTab(5) },
	{ key = "7",     mods = "ALT",        action = wezterm.action.ActivateTab(6) },
	{ key = "8",     mods = "ALT",        action = wezterm.action.ActivateTab(7) },
	{ key = "9",     mods = "ALT",        action = wezterm.action.ActivateTab(8) },
	{ key = "v",     mods = "ALT",        action = wezterm.action.PasteFrom('Clipboard') },
	{ key = "r",     mods = "CTRL|SHIFT", action = wezterm.action.ReloadConfiguration },
	{ key = "d",     mods = "CTRL|SHIFT", action = wezterm.action.ShowDebugOverlay },
	{ key = "Enter", mods = "CMD",        action = wezterm.action.ToggleFullScreen },
}
config.window_padding = {
	left = 0,
	right = 0,
	top = 0,
	bottom = 0,
}

local bg_color = "#21252b"
local fg_color = "#dcdfe4"

local path_after_scheme = function(path)
	local p = path:match("://(.*)")
	if p == nil then
		p = path
	end
	return p
end

local path_in_unix_format = function(path)
	local p = path:gsub("\\", "/")
	return p
end

local get_dir_name = function(path)
	if path_after_scheme(path) == path_in_unix_format(wezterm.home_dir) then
		return "ﴤ"
	end

	-- remove trailing slash
	path = path:gsub("/$", "")

	local dir_name = path:match("^.*/(.*)$")
	if dir_name == nil then
		dir_name = path
	end
	return dir_name
end

-- https://github.com/wez/wezterm/issues/522 for renaming tab title
wezterm.on("format-tab-title", function(tab, _, _, _, _, _)
	local tab_title = tab.tab_title
	local formatted

	if tab_title ~= nil and #tab_title > 0 then
		formatted = (tab.tab_index + 1) .. "  " .. tab_title
	else
		formatted = (tab.tab_index + 1) .. "  " .. get_dir_name(tab.active_pane.current_working_dir)
	end

	local bg = wezterm.color.parse(bg_color)
	local fg = wezterm.color.parse(fg_color)
	if (not tab.is_active) then
		bg = bg:darken(0.2)
		fg = fg:darken(0.5)
	end

	return {
		{ Background = { Color = bg } },
		{ Foreground = { Color = fg } },
		{ Text = " " .. formatted .. " " },
	}
end)

config.window_decorations = "INTEGRATED_BUTTONS|RESIZE"
config.initial_cols = 136
config.initial_rows = 44
config.window_frame = {
	font = wezterm.font_with_fallback({ { family = 'Roboto', weight = 'Regular' }, 'Symbols Nerd Font' }),
	font_size = 12,
}

config.font = wezterm.font_with_fallback({
	"IBM Plex Mono Text",
	"IBM Plex Mono Medm",
	"Symbols Nerd Font Mono",
	"Noto Sans Telugu",
})
config.font_rules = {
	{
		intensity = "Normal",
		italic = false,
		font = wezterm.font_with_fallback({ "IBM Plex Mono Text", "Noto Sans Telugu" }),
	},
	{
		intensity = "Normal",
		italic = true,
		font = wezterm.font_with_fallback({ { family = "IBM Plex Mono Text", style = "Italic" }, "Noto Sans Telugu" }),
	},
	{
		intensity = "Bold",
		font = wezterm.font_with_fallback({ { family = "IBM Plex Mono", weight = "Bold" }, "Noto Sans Telugu" }),
	},
}
config.font_size = 12.0

if wezterm.target_triple == "aarch64-apple-darwin" then
	config.default_prog = { "/opt/homebrew/bin/nu" }
	config.font_size = 18.0
	config.window_frame = {
		font = wezterm.font_with_fallback({ { family = 'Roboto', weight = 'Regular' }, 'Symbols Nerd Font' }),
		font_size = 14,
	}
elseif wezterm.target_triple == "x86_64-pc-windows-msvc" then
	config.default_prog = {
		"nu" }
end


return config
