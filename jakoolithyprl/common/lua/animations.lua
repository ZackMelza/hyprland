-- Migrated from common/UserConfigs/UserAnimations.conf.
hl.config({ animations = { enabled = true } })
local curves = {
  wind = { {0.05, 0.9}, {0.1, 1.05} },
  winIn = { {0.1, 1.1}, {0.1, 1.1} },
  winOut = { {0.3, -0.3}, {0, 1} },
  liner = { {1, 1}, {1, 1} },
  overshot = { {0.05, 0.9}, {0.1, 1.05} },
  smoothOut = { {0.5, 0}, {0.99, 0.99} },
  smoothIn = { {0.5, -0.5}, {0.68, 1.5} },
}
for name, points in pairs(curves) do
  hl.curve(name, { type = "bezier", points = points })
end
for _, a in ipairs({
  {"windows",6,"wind","slide"},
  {"windowsIn",5,"winIn","slide"},
  {"windowsOut",3,"smoothOut","slide"},
  {"windowsMove",5,"wind","slide"},
  {"border",1,"liner"},
  {"borderangle",180,"liner","loop"},
  {"fade",3,"smoothOut"},
  {"workspaces",5,"overshot"},
  {"workspacesIn",5,"winIn","slide"},
  {"workspacesOut",5,"winOut","slide"},
}) do
  hl.animation({ leaf = a[1], enabled = true, speed = a[2],
    bezier = a[3], style = a[4] })
end
