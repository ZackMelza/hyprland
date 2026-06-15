#!/usr/bin/env bash
# /* ---- https://github.com/JaKooLit ---- */  ##
# Refresh Waybar, Rofi, SwayNC, and generated desktop colors.

UserScripts="$HOME/.config/hypr/UserScripts"

pkill rofi 2>/dev/null || true

if command -v waybar-msg >/dev/null 2>&1 && pidof waybar >/dev/null; then
  waybar-msg cmd reload >/dev/null 2>&1 || true
else
  pkill waybar 2>/dev/null || true
  sleep 0.2
  waybar >/dev/null 2>&1 &
fi

if command -v swaync-client >/dev/null 2>&1; then
  if ! swaync-client --reload-config >/dev/null 2>&1 ||
     ! swaync-client --reload-css >/dev/null 2>&1; then
    systemctl --user restart swaync.service >/dev/null 2>&1 ||
      swaync >/dev/null 2>&1 &
  fi
fi

if [[ -x "$UserScripts/RainbowBorders.sh" ]]; then
  "$UserScripts/RainbowBorders.sh" &
fi

exit 0
