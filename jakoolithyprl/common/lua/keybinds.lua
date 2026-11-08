-- Native Hyprland 0.57 keybind essentials from existing Keybinds.conf
-- and UserKeybinds.conf. Remaining specialized binds await individual testing.
local h = assert(os.getenv("HOME"))
local scripts = h .. "/.config/hypr/scripts/"
local user = h .. "/.config/hypr/UserScripts/"
local function exec(chord, cmd, flags)
  hl.bind(chord, hl.dsp.exec_cmd(cmd), flags)
end
local function action(chord, factory)
  hl.bind(chord, function() hl.dispatch(factory()) end)
end
-- Daily workflow: preserve these even if optional components fail.
exec("SUPER + Return", "kitty")
exec("SUPER + E", "thunar")
exec("SUPER + R", scripts .. "RofiLauncher.sh")
exec("SUPER + B", "xdg-open https://")
exec("SUPER + D", "discord")
exec("SUPER + C", "code")
exec("SUPER + W", user .. "WallpaperSelect.sh")
exec("SUPER + SHIFT + W", user .. "WallpaperEffects.sh")
exec("CTRL + ALT + W", user .. "WallpaperRandom.sh")
exec("SUPER + S", scripts .. "RofiSearch.sh")
exec("SUPER + H", scripts .. "KeyHints.sh")
exec("SUPER + ALT + E", scripts .. "RofiEmoji.sh")
exec("SUPER + ALT + V", scripts .. "ClipManager.sh")
exec("SUPER + CTRL + R", scripts .. "RofiThemeSelector.sh")
exec("SUPER + CTRL + B", scripts .. "WaybarStyles.sh")
exec("SUPER + ALT + B", scripts .. "WaybarLayout.sh")
exec("SUPER + N", scripts .. "Hyprsunset.sh toggle")
exec("SUPER + SHIFT + S", scripts .. "ScreenShot.sh --swappy")
exec("SUPER + Print", scripts .. "ScreenShot.sh --now")
exec("SUPER + SHIFT + Print", scripts .. "ScreenShot.sh --area")
exec("CTRL + ALT + L", scripts .. "LockScreen.sh")
exec("CTRL + ALT + P", scripts .. "Wlogout.sh")
exec("SUPER + SHIFT + Q", scripts .. "KillActiveProcess.sh")
exec("SUPER + ALT + R", scripts .. "Refresh.sh")
exec("SUPER + SHIFT + K", scripts .. "KeyBinds.sh")
exec("SUPER + SHIFT + A", scripts .. "Animations.sh")
exec("SUPER + ALT + C", user .. "RofiCalc.sh")
exec("SUPER + SHIFT + M", user .. "RofiBeats.sh")
exec("SUPER + SHIFT + Return", scripts .. "Dropterminal.sh kitty")
exec("SUPER + CTRL + S", "rofi -show window")
-- Window management uses Lua dispatchers, not legacy 'hyprctl dispatch ...' strings.
action("SUPER + Q", function() return hl.dsp.window.close() end)
action("SUPER + SPACE", function() return hl.dsp.window.float({ action = "toggle" }) end)
action("SUPER + SHIFT + F", function() return hl.dsp.window.fullscreen({ mode = "fullscreen" }) end)
action("SUPER + CTRL + F", function() return hl.dsp.window.fullscreen({ mode = "maximized" }) end)
for _, dir in ipairs({ "left", "right", "up", "down" }) do
  action("SUPER + " .. dir, function() return hl.dsp.focus({ direction = dir }) end)
  action("SUPER + CTRL + " .. dir,
    function() return hl.dsp.window.move({ direction = dir }) end)
end
for i = 1, 10 do
  local key = i == 10 and "0" or tostring(i)
  action("SUPER + " .. key, function() return hl.dsp.focus({ workspace = tostring(i) }) end)
  action("SUPER + SHIFT + " .. key,
    function() return hl.dsp.window.move({ workspace = tostring(i) }) end)
  action("SUPER + CTRL + " .. key,
    function() return hl.dsp.window.move({ workspace = tostring(i), follow = false }) end)
end
-- Audio shortcuts are available even when a screen lock is active.
exec("XF86AudioRaiseVolume", scripts .. "Volume.sh --inc", { locked = true, repeating = true })
exec("XF86AudioLowerVolume", scripts .. "Volume.sh --dec", { locked = true, repeating = true })
exec("XF86AudioMute", scripts .. "Volume.sh --toggle", { locked = true })
exec("XF86AudioMicMute", scripts .. "Volume.sh --toggle-mic", { locked = true })
exec("XF86AudioPlay", scripts .. "MediaCtrl.sh --pause", { locked = true })
exec("XF86AudioPause", scripts .. "MediaCtrl.sh --pause", { locked = true })
exec("XF86AudioPlayPause", scripts .. "MediaCtrl.sh --pause", { locked = true })
exec("XF86AudioNext", scripts .. "MediaCtrl.sh --nxt", { locked = true })
exec("XF86AudioPrev", scripts .. "MediaCtrl.sh --prv", { locked = true })
