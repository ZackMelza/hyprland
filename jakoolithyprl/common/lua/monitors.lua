-- Safe default while per-host monitors.conf is converted to Lua.
-- Original monitor/workspace overrides are still preserved as .conf backups.
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = "1" })
local path = (os.getenv("XDG_CONFIG_HOME") or ((os.getenv("HOME") or "") .. "/.config"))
  .. "/hypr/UserConfigs/monitors.lua"
local f = io.open(path, "r")
if f then f:close(); dofile(path) end
local workspaces = (os.getenv("XDG_CONFIG_HOME") or ((os.getenv("HOME") or "") .. "/.config"))
  .. "/hypr/UserConfigs/workspaces.lua"
local w = io.open(workspaces, "r")
if w then w:close(); dofile(workspaces) end
