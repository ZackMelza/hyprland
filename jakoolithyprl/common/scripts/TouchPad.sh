#!/usr/bin/env bash
# /* ---- 💫 https://github.com/JaKooLit 💫 ---- */  ##
# For disabling touchpad.
# Edit the Touchpad_Device on ~/.config/hypr/UserConfigs/Laptops.conf according to your system
# use hyprctl devices to get your system touchpad device name
# source https://github.com/hyprwm/Hyprland/discussions/4283?sort=new#discussioncomment-8648109

notif="$HOME/.config/swaync/images/ja.png"
config_file="$HOME/.config/hypr/UserConfigs/Laptops.conf"

export STATUS_FILE="$XDG_RUNTIME_DIR/touchpad.status"

enable_touchpad() {
    printf "true" >"$STATUS_FILE"
    notify-send -u low -i "$notif" " Enabling" " touchpad"
    hyprctl keyword "$touchpad_enabled" "true" -r
}

disable_touchpad() {
    printf "false" >"$STATUS_FILE"
    notify-send -u low -i "$notif" " Disabling" " touchpad"
    hyprctl keyword "$touchpad_enabled" "false" -r
}

if [[ -f "$config_file" ]]; then
  # Read the resolved Hyprland keyword from the laptop config.
  touchpad_enabled=$(sed -n 's/^\$TOUCHPAD_ENABLED[[:space:]]*=[[:space:]]*//p' "$config_file" | head -n1)
fi

if [[ -z "${touchpad_enabled:-}" ]]; then
  notify-send -u critical -i "$notif" " Touchpad toggle" "TOUCHPAD_ENABLED not configured in Laptops.conf"
  exit 1
fi

if ! [ -f "$STATUS_FILE" ]; then
  enable_touchpad
else
  if [ "$(cat "$STATUS_FILE")" = "true" ]; then
    disable_touchpad
  elif [ "$(cat "$STATUS_FILE")" = "false" ]; then
    enable_touchpad
  fi
fi
