-- Initial migration from ZackMelza/hyprland legacy JaKooLit .conf.
-- Generated for compatibility testing with Hyprland 0.57.
-- Keep original .conf files as the authoritative reference until verified.
-- Default from old monitor profile; runtime-specific overrides are separate.
-- Do not assume these wildcard settings reproduce the user's monitors.conf.
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = "1" })
local home = assert(os.getenv("HOME"))
local dir = (os.getenv("XDG_CONFIG_HOME") or (home .. "/.config")) .. "/hypr"
-- User-generated Lua overrides are deliberately optional and never generated
-- from .conf without an explicit, reviewed conversion.
for _, name in ipairs({ "monitors.lua", "workspaces.lua" }) do
  local path = dir .. "/UserConfigs/" .. name
  local f = io.open(path, "r")
  if f then f:close(); dofile(path) end
end
