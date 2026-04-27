#!/bin/bash
# /* ---- 💫 https://github.com/JaKooLit 💫 ---- */  ##
# Script for Random Wallpaper ( CTRL ALT W)

wallDIR="$HOME/Pictures/wallpapers"
SCRIPTSDIR="$HOME/.config/hypr/scripts"

if command -v swww >/dev/null 2>&1; then
  wallpaper_cmd="swww"
  wallpaper_daemon="swww-daemon"
elif command -v awww >/dev/null 2>&1; then
  wallpaper_cmd="awww"
  wallpaper_daemon="awww-daemon"
else
  echo "No supported wallpaper backend found (need swww or awww)." >&2
  exit 1
fi

get_focused_monitor() {
  if command -v jq >/dev/null 2>&1; then
    hyprctl monitors -j | jq -r '.[] | select(.focused) | .name'
  else
    hyprctl monitors | awk '/^Monitor/{name=$2} /focused: yes/{print name}'
  fi
}

focused_monitor="$(get_focused_monitor)"
if [[ -z "$focused_monitor" ]]; then
  echo "Could not determine focused monitor" >&2
  exit 1
fi

mapfile -d '' PICS < <(find -L "$wallDIR" -type f \( -name "*.jpg" -o -name "*.jpeg" -o -name "*.png" -o -name "*.pnm" -o -name "*.tga" -o -name "*.tiff" -o -name "*.webp" -o -name "*.bmp" -o -name "*.farbfeld" -o -name "*.gif" \) -print0)

if [[ ${#PICS[@]} -eq 0 ]]; then
  echo "No wallpapers found in $wallDIR" >&2
  exit 1
fi

RANDOMPICS="${PICS[RANDOM % ${#PICS[@]}]}"


# Transition config
FPS=30
TYPE="random"
DURATION=1
BEZIER=".43,1.19,1,.4"
SWWW_PARAMS="--transition-fps $FPS --transition-type $TYPE --transition-duration $DURATION --transition-bezier $BEZIER"


if ! "$wallpaper_cmd" query >/dev/null 2>&1; then
  if [[ "$wallpaper_daemon" == "swww-daemon" ]]; then
    swww-daemon --format xrgb >/dev/null 2>&1 &
  else
    awww-daemon >/dev/null 2>&1 &
  fi
  sleep 0.5
fi

"$wallpaper_cmd" img -o "$focused_monitor" "${RANDOMPICS}" $SWWW_PARAMS

"$SCRIPTSDIR/WallustSwww.sh" "${RANDOMPICS}" &&

sleep 2
"$SCRIPTSDIR/Refresh.sh"
