-- Initial migration from ZackMelza/hyprland legacy JaKooLit .conf.
-- Generated for compatibility testing with Hyprland 0.57.
-- Keep original .conf files as the authoritative reference until verified.
-- Based on common/UserConfigs/Startup_Apps.conf, run only on session start.
local commands = {
  "$HOME/.config/hypr/initial-boot.sh",
  "awww-daemon",
  "$HOME/.config/hypr/UserScripts/WallpaperAutoChange.sh $HOME/Pictures/wallpapers",
  "dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP",
  "systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP",
  "systemctl --user start hypr-graphical-session.service",
  "systemctl --user start swaync.service",
  "$HOME/.config/hypr/scripts/Dropterminal.sh kitty",
  "$HOME/.config/hypr/scripts/Polkit.sh",
  "nm-applet --indicator",
  "$HOME/.config/hypr/scripts/WaybarLaunch.sh",
  "qs",
  "wl-paste --type text --watch cliphist store",
  "wl-paste --type image --watch cliphist store",
  "$HOME/.config/hypr/UserScripts/RainbowBorders.sh",
  "hypridle",
}
hl.on("hyprland.start", function()
  for _, command in ipairs(commands) do
    hl.dispatch(hl.dsp.exec_cmd(command))
  end
end)
