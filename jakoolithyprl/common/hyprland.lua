-- JaKooLit managed Hyprland 0.57+ Lua entry point.
-- The original hyprland.conf tree remains untouched for rollback/reference.
local home = assert(os.getenv("HOME"), "HOME is required")
local root = (os.getenv("XDG_CONFIG_HOME") or (home .. "/.config")) .. "/hypr"
local function load(name)
  local path = root .. "/lua/" .. name .. ".lua"
  local fn, err = loadfile(path)
  if not fn then error("JaKooLit Lua: cannot load " .. path .. ": " .. tostring(err)) end
  return fn()
end
load("env")
load("settings")
load("decorations")
load("animations")
load("monitors")
load("keybinds")
load("window_rules")
load("startup")
