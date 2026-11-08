-- Initial essential rules. Port the complete legacy WindowRules.conf after
-- runtime verification; the 119 historic window/layer rules are still preserved.
local rules = {
  { match = { class = "^(pavucontrol|org.pulseaudio.pavucontrol)$" }, float = true, center = true },
  { match = { class = "^(nm-connection-editor|blueman-manager)$" }, float = true, center = true },
  { match = { class = "^(Thunar|thunar)$" }, center = true },
  { match = { title = "^(Picture-in-Picture)$" }, float = true,
    pin = true, keep_aspect_ratio = true },
  { match = { title = "^(Authentication Required)$" }, float = true, center = true },
  { match = { class = "^(code|code-oss|code-url-handler|VSCode)$" }, workspace = "3" },
  { match = { class = "^(com.obsproject.Studio)$" }, workspace = "4" },
}
for _, rule in ipairs(rules) do hl.window_rule(rule) end
