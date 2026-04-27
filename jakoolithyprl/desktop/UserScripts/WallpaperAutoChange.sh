#!/bin/bash
# /* ---- 💫 https://github.com/JaKooLit 💫 ---- */  ##
# source https://wiki.archlinux.org/title/Hyprland#Using_a_script_to_change_wallpaper_every_X_minutes

# This script will randomly go through the files of a directory, setting it
# up as the wallpaper at regular intervals
#
# NOTE: this script uses bash (not POSIX shell) for the RANDOM variable

wallust_refresh=$HOME/.config/hypr/scripts/RefreshNoWaybar.sh

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

if [[ $# -lt 1 ]] || [[ ! -d $1   ]]; then
	echo "Usage:
	$0 <dir containing images>"
	exit 1
fi

wall_dir="$1"

# Edit below to control the images transition
export SWWW_TRANSITION_FPS=60
export SWWW_TRANSITION_TYPE=simple
export AWWW_TRANSITION_FPS=60
export AWWW_TRANSITION=simple

# This controls (in seconds) when to switch to the next image
INTERVAL=1800

get_focused_monitor() {
	hyprctl monitors | awk '/^Monitor/{name=$2} /focused: yes/{print name}'
}

set_wallpaper() {
	local img="$1"
	local focused_monitor

	[[ -f "$img" ]] || return 1

	focused_monitor="$(get_focused_monitor)"
	[[ -n "$focused_monitor" ]] || return 1

	"$wallpaper_cmd" img -o "$focused_monitor" "$img" || return 1
	"$wallust_refresh" "$img"
}

if ! "$wallpaper_cmd" query >/dev/null 2>&1; then
	if [[ "$wallpaper_daemon" == "swww-daemon" ]]; then
		swww-daemon --format xrgb >/dev/null 2>&1 &
	else
		awww-daemon >/dev/null 2>&1 &
	fi
	sleep 1
fi

while true; do
	find "$wall_dir" -type f \( \
		-iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.gif" -o \
		-iname "*.bmp" -o -iname "*.tiff" -o -iname "*.webp" -o -iname "*.pnm" -o \
		-iname "*.tga" -o -iname "*.farbfeld" \) \
		| while read -r img; do
			echo "$((RANDOM % 1000)):$img"
		done \
		| sort -n | cut -d':' -f2- \
		| while read -r img; do
			set_wallpaper "$img"
			sleep $INTERVAL
			
		done
done
