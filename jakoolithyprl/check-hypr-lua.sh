#!/usr/bin/env bash
# Read-only runtime health audit for the managed Hyprland 0.57+ Lua profile.
# No reload, restart, profile rebuild, installation, or file modification.
set -uo pipefail

root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
hypr_dir="${XDG_CONFIG_HOME:-$HOME/.config}/hypr"
profile_file="$HOME/.config/environment.d/99-hypr.conf"
errors=0
warnings=0
passes=0
pass() { passes=$((passes + 1)); printf '[PASS] %s\n' "$*"; }
warn() { warnings=$((warnings + 1)); printf '[WARN] %s\n' "$*"; }
fail() { errors=$((errors + 1)); printf '[FAIL] %s\n' "$*"; }
info() { printf '       %s\n' "$*"; }
section() { printf '\n== %s ==\n' "$*"; }
running() { pgrep -x "$1" >/dev/null 2>&1; }

section 'Managed profile'
if [[ -L "$hypr_dir" && "$(readlink -f -- "$hypr_dir")" == "$root/active" ]]; then
  pass 'Hyprland config directory resolves to this repository/active'
else
  fail 'Hyprland config is not linked to the expected managed active directory'
fi
if [[ -r "$profile_file" ]]; then
  profile="$(sed -n 's/^HYPR_PROFILE=//p' "$profile_file" | tail -n 1)"
  case "$profile" in
    desktop|laptop) pass "Profile selected: $profile" ;;
    *) warn "Unexpected profile: ${profile:-unset}" ;;
  esac
else
  warn 'Profile environment file is missing'
fi
if command -v git >/dev/null 2>&1; then
  info "Branch: $(git -C "$root" branch --show-current 2>/dev/null || echo unknown)"
  if [[ -z "$(git -C "$root" status --porcelain --untracked-files=no 2>/dev/null)" ]]; then
    pass 'No uncommitted tracked changes'
  else
    warn 'Repository contains uncommitted tracked changes'
  fi
fi

section 'Lua sources and syntax'
if [[ -L "$hypr_dir/hyprland.lua" &&
      "$(readlink -f -- "$hypr_dir/hyprland.lua")" == "$root/common/hyprland.lua" ]]; then
  pass 'Active Lua entrypoint points to managed source'
else
  fail 'Active Lua entrypoint is not linked to managed source'
fi
if [[ -L "$hypr_dir/lua" &&
      "$(readlink -f -- "$hypr_dir/lua")" == "$root/common/lua" ]]; then
  pass 'Active Lua modules point to managed source'
else
  fail 'Active Lua module directory is not linked to managed source'
fi
if [[ -f "$root/common/hyprland.lua" && -d "$root/common/lua" ]] &&
   command -v luac >/dev/null 2>&1; then
  files=("$root/common/hyprland.lua")
  while IFS= read -r -d '' file; do files+=("$file"); done < <(
    find "$root/common/lua" -type f -name '*.lua' -print0
  )
  for file in "$hypr_dir/UserConfigs/monitors.lua" "$hypr_dir/UserConfigs/workspaces.lua"; do
    [[ -f "$file" ]] && files+=("$file")
  done
  syntax_error="$(luac -p "${files[@]}" 2>&1)"
  if [[ $? -eq 0 ]]; then pass "Lua syntax valid in ${#files[@]} source/override files"
  else fail "Lua syntax error: $syntax_error"; fi
else
  fail 'Managed Lua sources or luac are missing'
fi

section 'Compositor and displays'
if command -v hyprctl >/dev/null 2>&1 && hyprctl version >/dev/null 2>&1; then
  info "$(hyprctl version | head -n 1)"
  pass 'Hyprland session is reachable'
  config_errors="$(hyprctl configerrors 2>&1)"
  status=$?
  if [[ "$status" -eq 0 && -z "$(printf '%s' "$config_errors" | tr -d '[:space:]')" ]]; then
    pass 'No configuration errors reported'
  else
    fail "hyprctl configerrors returned: ${config_errors:-command failed}"
  fi
  layout="$(hyprctl getoption general.layout 2>/dev/null |
    sed -n 's/^str: //p' | head -n 1)"
  if [[ "$layout" == dwindle ]]; then pass 'Dwindle tiling layout active'
  else warn "Live tiling layout: ${layout:-unknown} (expected dwindle)"; fi
else
  fail 'Cannot connect to Hyprland; run within a graphical Hyprland session'
fi
if command -v jq >/dev/null 2>&1 && command -v hyprctl >/dev/null 2>&1; then
  monitors="$(hyprctl monitors -j 2>/dev/null || true)"
  if jq -e 'type == "array" and length > 0' >/dev/null 2>&1 <<<"$monitors"; then
    pass "$(jq length <<<"$monitors") connected monitor(s) recognized"
    jq -r '.[] | "       \(.name): \(.width)x\(.height) scale \(.scale)"' <<<"$monitors"
  else
    fail 'Connected monitor inventory is not readable'
  fi
  clients="$(hyprctl clients -j 2>/dev/null || true)"
  if jq -e 'type == "array"' >/dev/null 2>&1 <<<"$clients"; then
    pass 'Window inventory is readable'
    kitty="$(jq '[.[] | select(.class == "kitty")] | length' <<<"$clients")"
    info "Kitty windows currently open: $kitty"
    info 'Current fullscreen/maximized states may be intentional; test NEW Kitty tiling manually.'
  else
    warn 'Window inventory is not readable'
  fi
else
  warn 'jq or hyprctl missing; cannot inspect displays/windows'
fi
if [[ -f "$hypr_dir/UserConfigs/monitors.lua" ]]; then
  pass 'Machine-specific monitor Lua override exists'
else
  warn 'No machine-specific monitor Lua override found'
fi

section 'Bindings and window rules'
binds_file="$root/common/lua/keybinds.lua"
rules_file="$root/common/lua/window_rules.lua"
if [[ -f "$binds_file" ]]; then
  for shortcut in 'hl.bind("SUPER + Return"' 'hl.bind("SUPER + R"' 'hl.bind("SUPER + E"'; do
    if grep -Fq "$shortcut" "$binds_file"; then
      pass "Declared: $shortcut"
    else
      fail "Missing keybinding declaration: $shortcut"
    fi
  done
  declared="$(awk '/^if profile == "laptop" then/{exit}
    /^[[:space:]]*hl.bind\(/ {n++} END {print n+0}' "$binds_file")"
  info "Desktop Lua bind declarations: $declared"
  if command -v jq >/dev/null 2>&1 && command -v hyprctl >/dev/null 2>&1; then
    live_json="$(hyprctl binds -j 2>/dev/null || true)"
    if jq -e 'type == "array"' >/dev/null 2>&1 <<<"$live_json"; then
      live="$(jq length <<<"$live_json")"
      info "Runtime bindings reported: $live"
      if (( live >= declared / 2 )); then pass 'Substantial runtime binding table present'
      else warn 'Very few runtime bindings; verify shortcuts manually'; fi
    else warn 'Unable to read runtime binding table'; fi
  fi
  omitted="$(grep -c '^-- TODO migrate ' "$binds_file" || true)"
  if (( omitted > 0 )); then
    warn "$omitted legacy shortcuts are still marked for migration"
  else
    pass 'No explicitly deferred shortcuts'
  fi
else
  fail 'Lua keybind file is missing'
fi
if [[ -f "$rules_file" ]]; then
  info "Window rule declarations: $(grep -c '^hl.window_rule(' "$rules_file" || true)"
  info "Layer rule declarations: $(grep -c '^hl.layer_rule(' "$rules_file" || true)"
  if grep -Fq 'name = "kitty-start-tiled"' "$rules_file"; then
    pass 'Kitty tile/maximize suppression rule exists'
  else
    fail 'Kitty tile/maximize suppression rule is missing'
  fi
else
  fail 'Lua window rules file is missing'
fi

section 'Session programs'
if running waybar; then pass 'Waybar running'; else fail 'Waybar not running'; fi
if running swaync ||
   { command -v systemctl >/dev/null 2>&1 &&
     systemctl --user is-active --quiet swaync.service 2>/dev/null; }; then
  pass 'SwayNC notifications running'
else
  warn 'SwayNC notifications not detected'
fi
if running hypridle; then pass 'hypridle running'
else warn 'hypridle not detected; lock/idle behavior unverified'; fi
if running nm-applet; then pass 'NetworkManager applet running'
else warn 'NetworkManager applet not detected'; fi
if running wl-paste; then pass 'Clipboard watcher running'
else warn 'Clipboard watcher not detected'; fi
if command -v swww >/dev/null 2>&1 && swww query >/dev/null 2>&1; then
  pass 'swww wallpaper daemon responding'
elif command -v awww >/dev/null 2>&1 && awww query >/dev/null 2>&1; then
  pass 'awww wallpaper daemon responding'
else
  warn 'Wallpaper daemon is not responding via swww/awww'
fi
if [[ -s "$hypr_dir/wallpaper_effects/.wallpaper_current" ]]; then
  pass 'Saved wallpaper file present'
else
  warn 'Saved wallpaper file missing/empty'
fi
if running qs || running quickshell; then pass 'Quickshell is running'
else info 'Quickshell not running (optional if you do not use its overview)'; fi

section 'Logout and remaining migration gaps'
logout_file="$HOME/.config/wlogout/layout"
if [[ -r "$logout_file" ]] &&
   grep -Fq "hyprctl dispatch 'hl.dsp.exit()'" "$logout_file"; then
  pass 'wlogout action uses Lua dispatch syntax'
elif [[ -r "$logout_file" ]] &&
     grep -Eq 'hyprctl[[:space:]]+dispatch[[:space:]]+exit' "$logout_file"; then
  fail 'wlogout still uses legacy dispatch exit syntax'
else
  warn 'Cannot validate wlogout layout automatically'
fi
if command -v systemctl >/dev/null 2>&1 &&
   systemctl --user is-active --quiet hypr-config-guard.path 2>/dev/null; then
  warn 'Legacy guard is active but watches .conf, not hyprland.lua'
fi
warn 'Profile installer remains legacy: do not run set-hypr-profile.sh yet'
warn 'App-specific rules, gestures, device overrides and shell scripts need parity testing'

section 'Summary'
printf 'PASS=%d WARN=%d FAIL=%d\n' "$passes" "$warnings" "$errors"
if (( errors > 0 )); then
  echo 'RESULT: FAIL — address failures before merging'
  exit 1
fi
if (( warnings > 0 )); then
  echo 'RESULT: PARTIAL — runtime is healthy in checked areas, migration not fully verified'
else
  echo 'RESULT: PASS — automatic checks passed; manual interaction testing still needed'
fi
exit 0
