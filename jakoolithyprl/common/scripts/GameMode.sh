#!/usr/bin/env bash
# /* ---- 💫 https://github.com/JaKooLit 💫 ---- */  ##
# Game Mode. Turning off all animations

notif="$HOME/.config/swaync/images/ja.png"
SCRIPTSDIR="$HOME/.config/hypr/scripts"

if command -v swww >/dev/null 2>&1; then
    wallpaper_cmd="swww"
    wallpaper_daemon="swww-daemon"
elif command -v awww >/dev/null 2>&1; then
    wallpaper_cmd="awww"
    wallpaper_daemon="awww-daemon"
else
    wallpaper_cmd=""
    wallpaper_daemon=""
fi

HYPRGAMEMODE=$(hyprctl getoption animations:enabled | awk 'NR==1{print $2}')
if [ "$HYPRGAMEMODE" = 1 ] ; then
    hyprctl --batch "\
        keyword animations:enabled 0;\
        keyword decoration:shadow:enabled 0;\
        keyword decoration:blur:enabled 0;\
        keyword general:gaps_in 0;\
        keyword general:gaps_out 0;\
        keyword general:border_size 1;\
        keyword decoration:rounding 0"
	
	hyprctl keyword "windowrule opacity 1 override 1 override 1 override, ^(.*)$"
	    if [ -n "$wallpaper_cmd" ]; then
	        "$wallpaper_cmd" kill
	    fi
    notify-send -e -u low -i "$notif" " Gamemode:" " enabled"
    sleep 0.1
    exit
else
		if [ -n "$wallpaper_cmd" ]; then
			if [ "$wallpaper_daemon" = "swww-daemon" ]; then
				swww-daemon --format xrgb >/dev/null 2>&1 &
			else
				awww-daemon >/dev/null 2>&1 &
			fi
			sleep 0.5
			"$wallpaper_cmd" img "$HOME/.config/rofi/.current_wallpaper"
		fi
	sleep 0.1
	${SCRIPTSDIR}/WallustSwww.sh
	sleep 0.5
  hyprctl reload
	${SCRIPTSDIR}/Refresh.sh	 
    notify-send -e -u normal -i "$notif" " Gamemode:" " disabled"
    exit
fi
hyprctl reload
