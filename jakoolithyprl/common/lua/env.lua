-- Initial migration from ZackMelza/hyprland legacy JaKooLit .conf.
-- Generated for compatibility testing with Hyprland 0.57.
-- Keep original .conf files as the authoritative reference until verified.
local values = {
  GDK_BACKEND = "wayland,x11,*", QT_QPA_PLATFORM = "wayland;xcb",
  CLUTTER_BACKEND = "wayland", XDG_CURRENT_DESKTOP = "Hyprland",
  XDG_SESSION_DESKTOP = "Hyprland", XDG_SESSION_TYPE = "wayland",
  QT_AUTO_SCREEN_SCALE_FACTOR = "1", QT_WAYLAND_DISABLE_WINDOWDECORATION = "1",
  QT_QPA_PLATFORMTHEME = "qt6ct", QT_STYLE_OVERRIDE = "kvantum",
  QT_QUICK_CONTROLS_STYLE = "org.hyprland.style",
  GDK_SCALE = "1", QT_SCALE_FACTOR = "1",
  HYPRCURSOR_THEME = "Bibata-Modern-Ice", HYPRCURSOR_SIZE = "24",
  MOZ_ENABLE_WAYLAND = "1", ELECTRON_OZONE_PLATFORM_HINT = "auto",
  EDITOR = "vim",
}
for name, value in pairs(values) do hl.env(name, value) end
