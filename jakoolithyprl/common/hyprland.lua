-- Managed JaKooLit Lua config entrypoint for Hyprland 0.57+.
-- Experimental until live verification. Original .conf files are preserved.
local home = assert(os.getenv("HOME"), "HOME environment variable is required")
local hyprDir = (os.getenv("XDG_CONFIG_HOME") or (home .. "/.config")) .. "/hypr"
local function load(name)
  local path = hyprDir .. "/lua/" .. name .. ".lua"
  local chunk, err = loadfile(path)
  if not chunk then error("JaKooLit: cannot load " .. path .. ": " .. tostring(err)) end
  return chunk()
end
load("env")
load("settings")
load("decorations")
load("animations")
load("monitors")
load("keybinds")
load("window_rules")
load("startup")
