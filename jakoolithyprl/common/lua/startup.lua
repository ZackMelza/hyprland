-- Migrated from common/UserConfigs/Startup_Apps.conf.
-- Startup is registered for a *new* Hyprland session, not repeated on reload.
local h = assert(os.getenv("HOME"))
local scripts = h .. "/.config/hypr/scripts/"
local user = h .. "/.config/hypr/UserScripts/"
local cmds = {
  h .. "/.config/hypr/initial-boot.sh",
  "awww-daemon",
  user .. "WallpaperAutoChange.sh " .. h .. "/Pictures/wallpapers",
  "dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP",
  "systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP",
  "systemctl --user start hypr-graphical-session.service",
  "systemctl --user start swaync.service",
  scripts .. "Dropterminal.sh kitty",
  scripts .. "Polkit.sh",
  "nm-applet --indicator",
  scripts .. "WaybarLaunch.sh",
  "qs",
  "wl-paste --type text --watch cliphist store",
  "wl-paste --type image --watch cliphist store",
  user .. "RainbowBorders.sh",
  "hypridle",
}
hl.on("hyprland.start", function()
  for _, cmd in ipairs(cmds) do hl.dispatch(hl.dsp.exec_cmd(cmd)) end
end)
