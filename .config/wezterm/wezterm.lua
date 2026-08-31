local wezterm = require('wezterm') --[[@as Wezterm]]
local config ---@type Config

wezterm.on('bell', function(window, pane)
	window:toast_notification('wezterm', 'bell rung @ ' .. pane:pane_id(), nil, 4000)
end)

local is_mac = string.find(wezterm.target_triple, 'darwin')

local act = wezterm.action
local mod = is_mac and 'CMD' or 'ALT'
local mod_shift = mod .. '|SHIFT'

--- normal config
---@diagnostic disable-next-line: missing-fields
config = {
	-- colors = wezterm.color.load_base16_scheme(wezterm.config_dir .. '/base16-default-bark.yaml'),
	-- color_scheme = 'Default Dark (base16)',
	hide_tab_bar_if_only_one_tab = true,
	native_macos_fullscreen_mode = false,
	macos_fullscreen_extend_behind_notch = false,

	window_padding = {
		left = '0pt',
		right = '0pt',
		top = '16pt',
		bottom = '0pt',
	},
	audible_bell = 'SystemBeep',
	notification_handling = 'AlwaysShow',
	-- font = wezterm.font('Terminess Nerd Font Mono'),
	-- font = wezterm.font('Maple Mono NL NF'),
	-- font_size = 20.0,
	font = wezterm.font('ComicShannsMono Nerd Font'),
	font_size = 20.0,
	default_cursor_style = 'SteadyBar',
	cursor_blink_rate = 0,
	window_decorations = is_mac and 'RESIZE',
	-- default_prog = is_mac and {'/opt/homebrew/bin/fish'} or {'fish'},
	-- default_prog = { "tmux new-session -A -s main" },
}

do -- keybindings
	config.disable_default_key_bindings = true
	config.keys = {}

	--- remove all keybinds by default for tmux to take over
	local keys = "abdefghijklmnoprstuwxyz,.[]';123456789" -- no c,v,q

	for i = 1, #keys do
		local c = keys:sub(i, i)
		table.insert(config.keys, {
			key = c,
			mods = 'CMD',
			action = wezterm.action.SendKey({
				key = c,
				mods = 'META',
			}),
		})
	end

	for _, key in pairs({ -- actual keybindings
		{key = 'Backspace', mods = mod, action = act.SendKey({key = 'w', mods = 'CTRL'})},
		{key = 'Enter', mods = mod, action = act.SendKey({key = 'Enter', mods = 'META'})},
		{key = 'q', mods = mod, action = act.CloseCurrentPane({confirm = false})},
		{key = 'v', mods = mod, action = act.PasteFrom('Clipboard')},
		{key = '-', mods = mod, action = act.DecreaseFontSize},
		{key = '=', mods = mod, action = act.IncreaseFontSize},
		{key = '0', mods = mod, action = act.ResetFontSize},
		{key = 'f', mods = 'CMD|SHIFT', action = act.ToggleFullScreen},
		{key = 'l', mods = 'CMD|SHIFT', action = act.ShowDebugOverlay},

		-- {key = 'c', mods = mod, action = act.CopyTo("ClipboardAndPrimarySelection")},
	}) do
		table.insert(config.keys, key)
	end
end

---
--- multiplexer
---
if false then
	local workspace_switcher = wezterm.plugin.require('https://github.com/MLFlexer/smart_workspace_switcher.wezterm')
	for i = 1, 9 do
		table.insert(config.keys, {key = tostring(i), mods = mod, action = act.ActivateTab(i - 1)})
	end

	config.use_fancy_tab_bar = false
	config.show_new_tab_button_in_tab_bar = false
	config.colors.tab_bar = {
		background = '101010',
		inactive_tab = {bg_color = '101010', fg_color = 'b0b0b0'},
		active_tab = {bg_color = '101010', fg_color = '86c1b9', intensity = 'Bold'},
	}

	---@diagnostic disable-next-line: unused-local
	wezterm.on('update-status', function(gui_window, pane)
		local bat = ''
		for _, b in ipairs(wezterm.battery_info()) do
			bat = string.format('%.0f%%', b.state_of_charge * 100)
		end
		gui_window:set_right_status(bat .. wezterm.strftime(' | %a %h %d %H:%M'))
	end)

	local layouts = {
		bsp = function(_, pane)
			local d = pane:get_dimensions()
			local dir = d['pixel_height'] < d['pixel_width'] and 'Right' or 'Bottom'
			pane:split({direction = dir})
		end,
		bsp_reverse = function(_, pane)
			local d = pane:get_dimensions()
			local dir = d['pixel_height'] < d['pixel_width'] and 'Left' or 'Top'
			pane:split({direction = dir})
		end,
	}

	for _, key in ipairs({
		{key = 'c', mods = mod, action = act.CopyTo('Clipboard')},
		{key = 'v', mods = mod, action = act.PasteFrom('Clipboard')},
		{key = 't', mods = mod, action = act.SpawnTab('DefaultDomain')},
		{key = 'w', mods = mod, action = act.CloseCurrentPane({confirm = false})},
		{key = '/', mods = mod, action = act.ShowLauncher},
		{key = 'Enter', mods = mod, action = wezterm.action_callback(layouts.bsp)},
		{key = 'Enter', mods = mod_shift, action = wezterm.action_callback(layouts.bsp_reverse)},
		{key = 'j', mods = mod, action = act.ActivatePaneDirection('Down')},
		{key = 'k', mods = mod, action = act.ActivatePaneDirection('Up')},
		{key = 'h', mods = mod, action = act.ActivatePaneDirection('Left')},
		{key = 'l', mods = mod, action = act.ActivatePaneDirection('Right')},
		{key = 'j', mods = mod_shift, action = act.RotatePanes('CounterClockwise')},
		{key = 'k', mods = mod_shift, action = act.RotatePanes('Clockwise')},
		-- {key = 'f', mods = mod, action = wezterm.action_callback(sessionizer.toggle)},
		-- {key = 's', mods = mod, action = act.ShowLauncherArgs({flags = "FUZZY|WORKSPACES"})},
		{
			key = 's',
			mods = mod,
			action = workspace_switcher.switch_workspace({
				extra_args = ' | fd -HI ^.git$ --max-depth=3 --prune ~/projects',
			}),
		},
		{key = 'e', mods = mod, action = workspace_switcher.switch_to_prev_workspace()},
	}) do
		table.insert(config.keys, key)
	end
end

return config
