#!/usr/bin/env bash
# /* ---- 💫 https://github.com/JaKooLit 💫 ---- */  ##
# Scripts for volume controls for audio and mic 

iDIR="$HOME/.config/swaync/icons"
sDIR="$HOME/.config/hypr/scripts"

get_mic_source() {
    local source

    if ! command -v pactl >/dev/null 2>&1; then
        return 1
    fi

    source=$(pactl get-default-source 2>/dev/null || true)
    if [[ -n "$source" && "$source" != *.monitor ]]; then
        printf '%s\n' "$source"
        return 0
    fi

    pactl list sources short 2>/dev/null | awk '$2 !~ /\.monitor$/ { print $2; exit }'
}

mic_pamixer() {
    local source

    source=$(get_mic_source || true)
    if [[ -n "$source" ]]; then
        pamixer --source "$source" "$@"
    else
        pamixer --default-source "$@"
    fi
}

# Get Volume
get_volume() {
    if [[ "$(pamixer --get-mute)" == "true" ]]; then
        echo "Muted"
        return
    fi

    volume=$(pamixer --get-volume)
    if [[ "$volume" -eq "0" ]]; then
        echo "Muted"
    else
        echo "$volume %"
    fi
}

# Get icons
get_icon() {
    current=$(get_volume)
    if [[ "$current" == "Muted" ]]; then
        echo "$iDIR/volume-mute.png"
    elif [[ "${current%\%}" -le 30 ]]; then
        echo "$iDIR/volume-low.png"
    elif [[ "${current%\%}" -le 60 ]]; then
        echo "$iDIR/volume-mid.png"
    else
        echo "$iDIR/volume-high.png"
    fi
}

# Notify
notify_user() {
    if [[ "$(get_volume)" == "Muted" ]]; then
        notify-send -e -h string:x-canonical-private-synchronous:volume_notif -h boolean:SWAYNC_BYPASS_DND:true -u low -i "$(get_icon)" " Volume:" " Muted"
    else
        notify-send -e -h int:value:"$(get_volume | sed 's/%//')" -h string:x-canonical-private-synchronous:volume_notif -h boolean:SWAYNC_BYPASS_DND:true -u low -i "$(get_icon)" " Volume Level:" " $(get_volume)" &&
        "$sDIR/Sounds.sh" --volume
    fi
}

# Increase Volume
inc_volume() {
    if [ "$(pamixer --get-mute)" == "true" ]; then
        toggle_mute
    else
        pamixer -i 5 --allow-boost --set-limit 150 && notify_user
    fi
}

# Decrease Volume
dec_volume() {
    if [ "$(pamixer --get-mute)" == "true" ]; then
        toggle_mute
    else
        pamixer -d 5 && notify_user
    fi
}

# Toggle Mute
toggle_mute() {
	if [ "$(pamixer --get-mute)" == "false" ]; then
		pamixer -m && notify-send -e -u low -h boolean:SWAYNC_BYPASS_DND:true -i "$iDIR/volume-mute.png" " Mute"
	elif [ "$(pamixer --get-mute)" == "true" ]; then
		pamixer -u && notify-send -e -u low -h boolean:SWAYNC_BYPASS_DND:true -i "$(get_icon)" " Volume:" " Switched ON"
	fi
}

# Toggle Mic
toggle_mic() {
	if [ "$(mic_pamixer --get-mute)" == "false" ]; then
		mic_pamixer -m && notify-send -e -u low -h boolean:SWAYNC_BYPASS_DND:true -i "$iDIR/microphone-mute.png" " Microphone:" " Switched OFF"
	elif [ "$(mic_pamixer --get-mute)" == "true" ]; then
		mic_pamixer -u && notify-send -e -u low -h boolean:SWAYNC_BYPASS_DND:true -i "$iDIR/microphone.png" " Microphone:" " Switched ON"
	fi
}
# Get Mic Icon
get_mic_icon() {
    local muted current
    muted=$(mic_pamixer --get-mute)
    current=$(mic_pamixer --get-volume)
    if [[ "$muted" == "true" || "$current" -eq "0" ]]; then
        echo "$iDIR/microphone-mute.png"
    else
        echo "$iDIR/microphone.png"
    fi
}

# Get Microphone Volume
get_mic_volume() {
    if [[ "$(mic_pamixer --get-mute)" == "true" ]]; then
        echo "Muted"
        return
    fi

    volume=$(mic_pamixer --get-volume)
    if [[ "$volume" -eq "0" ]]; then
        echo "Muted"
    else
        echo "$volume %"
    fi
}

# Notify for Microphone
notify_mic_user() {
    local volume icon value
    volume=$(get_mic_volume)
    icon=$(get_mic_icon)

    if [[ "$volume" == "Muted" ]]; then
        notify-send -e -h "string:x-canonical-private-synchronous:volume_notif" -h boolean:SWAYNC_BYPASS_DND:true -u low -i "$icon" " Mic Level:" " Muted"
    else
        value="${volume%\%}"
        notify-send -e -h int:value:"${value%% *}" -h "string:x-canonical-private-synchronous:volume_notif" -h boolean:SWAYNC_BYPASS_DND:true -u low -i "$icon" " Mic Level:" " $volume"
    fi
}

# Increase MIC Volume
inc_mic_volume() {
    if [ "$(mic_pamixer --get-mute)" == "true" ]; then
        toggle_mic
    else
        mic_pamixer -i 5 && notify_mic_user
    fi
}

# Decrease MIC Volume
dec_mic_volume() {
    if [ "$(mic_pamixer --get-mute)" == "true" ]; then
        toggle_mic
    else
        mic_pamixer -d 5 && notify_mic_user
    fi
}

# Execute accordingly
if [[ "$1" == "--get" ]]; then
	get_volume
elif [[ "$1" == "--inc" ]]; then
	inc_volume
elif [[ "$1" == "--dec" ]]; then
	dec_volume
elif [[ "$1" == "--toggle" ]]; then
	toggle_mute
elif [[ "$1" == "--toggle-mic" ]]; then
	toggle_mic
elif [[ "$1" == "--get-icon" ]]; then
	get_icon
elif [[ "$1" == "--get-mic-icon" ]]; then
	get_mic_icon
elif [[ "$1" == "--mic-inc" ]]; then
	inc_mic_volume
elif [[ "$1" == "--mic-dec" ]]; then
	dec_mic_volume
else
	get_volume
fi
