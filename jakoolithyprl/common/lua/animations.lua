-- Initial migration from ZackMelza/hyprland legacy JaKooLit .conf.
-- Generated for compatibility testing with Hyprland 0.57.
-- Keep original .conf files as the authoritative reference until verified.
hl.config({ animations = { enabled = true } })
local curves = {
  wind = { {0.05,0.9}, {0.1,1.05} },
  winIn = { {0.1,1.1}, {0.1,1.1} },
  winOut = { {0.3,-0.3}, {0,1} },
  liner = { {1,1}, {1,1} },
  overshot = { {0.05,0.9}, {0.1,1.05} },
  smoothOut = { {0.5,0}, {0.99,0.99} },
  smoothIn = { {0.5,-0.5}, {0.68,1.5} },
}
for name, points in pairs(curves) do
  hl.curve(name, { type = "bezier", points = points })
end
local animations = {
  {"windows",6,"wind","slide"}, {"windowsIn",5,"winIn","slide"},
  {"windowsOut",3,"smoothOut","slide"}, {"windowsMove",5,"wind","slide"},
  {"border",1,"liner"}, {"borderangle",180,"liner","loop"},
  {"fade",3,"smoothOut"}, {"workspaces",5,"overshot"},
  {"workspacesIn",5,"winIn","slide"},
  {"workspacesOut",5,"winOut","slide"},
}
for _, a in ipairs(animations) do
  hl.animation({ leaf = a[1], enabled = true,
    speed = a[2], bezier = a[3], style = a[4] })
end
