-- Initial migration from ZackMelza/hyprland legacy JaKooLit .conf.
-- Generated for compatibility testing with Hyprland 0.57.
-- Keep original .conf files as the authoritative reference until verified.
-- Read generated Wallust palette without treating the legacy .conf as Lua.
local home = assert(os.getenv("HOME"))
local palette = {}
local path = (os.getenv("XDG_CONFIG_HOME") or (home .. "/.config"))
  .. "/hypr/wallust/wallust-hyprland.conf"
local f = io.open(path, "r")
if f then
  for line in f:lines() do
    local name, value = line:match("^%s*%$(color%d+)%s*=%s*(%S+)")
    if name and value and value:match("^rgba?%([%x]+%)$") then
      palette[name] = value
    end
  end
  f:close()
end
local active = palette.color12 or "rgb(89b4fa)"
local inactive = palette.color10 or "rgb(a6e3a1)"
hl.config({
  general = {
    border_size = 2, gaps_in = 2, gaps_out = 4,
    col = { active_border = active, inactive_border = inactive },
  },
  decoration = {
    rounding = 10, active_opacity = 0.97, inactive_opacity = 0.8,
    fullscreen_opacity = 1, dim_inactive = true, dim_strength = 0.1,
    dim_special = 0.8,
    shadow = { enabled = true, range = 3, render_power = 1,
      color = active, color_inactive = inactive },
    blur = { enabled = true, size = 6, passes = 2,
      ignore_opacity = true, special = true, popups = true },
  },
  group = {
    col = { border_active = palette.color15 or active },
    groupbar = { col = { active = palette.color0 or "rgb(1e1e2e)" } },
  },
})
