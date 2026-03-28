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

focused_monitor=$(hyprctl monitors -j | jq -r '.[] | select(.focused) | .name')

PICS=($(find -L ${wallDIR} -type f \( -name "*.jpg" -o -name "*.jpeg" -o -name "*.png" -o -name "*.pnm" -o -name "*.tga" -o -name "*.tiff" -o -name "*.webp" -o -name "*.bmp" -o -name "*.farbfeld" -o -name "*.gif" \)))
RANDOMPICS=${PICS[ $RANDOM % ${#PICS[@]} ]}


# Transition config
FPS=30
TYPE="random"
DURATION=1
BEZIER=".43,1.19,1,.4"
SWWW_PARAMS="--transition-fps $FPS --transition-type $TYPE --transition-duration $DURATION --transition-bezier $BEZIER"


if ! "$wallpaper_cmd" query >/dev/null 2>&1; then
  if [[ "$wallpaper_daemon" == "swww-daemon" ]]; then
    swww-daemon --format xrgb
  else
    awww-daemon
  fi
fi

"$wallpaper_cmd" img -o $focused_monitor ${RANDOMPICS} $SWWW_PARAMS

wait $!
"$SCRIPTSDIR/WallustSwww.sh" "${RANDOMPICS}" &&

wait $!
sleep 2
"$SCRIPTSDIR/Refresh.sh"
