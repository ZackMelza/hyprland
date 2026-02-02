#!/bin/bash
# /* ---- 💫 https://github.com/JaKooLit 💫 ---- */  ##
# For Rofi Beats to play online Music or Locally saved media files

# Variables
mDIR="$HOME/Music/"
iDIR="$HOME/.config/swaync/icons"
rofi_theme="$HOME/.config/rofi/config-rofi-Beats.rasi"
rofi_theme_1="$HOME/.config/rofi/config-rofi-Beats-menu.rasi"

# Online Stations. Edit as required
declare -A online_music=(
  ["lofi hip hop radio 📚 beats to relax/study to"]="https://www.youtube.com/watch?v=jfKfPfyJRdk&list=PL6NdkXsPL07Il2hEQGcLI4dg_LTg7xA2L&index=1"
  ["synthwave radio 🌌 beats to chill/game to"]="https://www.youtube.com/watch?v=4xDzrJKXOOY&list=PL6NdkXsPL07Il2hEQGcLI4dg_LTg7xA2L&index=2" 
  ["jazz lofi radio 🎷 beats to chill/study to"]="https://www.youtube.com/watch?v=HuFYqnbVbzY&list=PL6NdkXsPL07Il2hEQGcLI4dg_LTg7xA2L&index=4"
  ["lofi hip hop radio 💤 beats to sleep/chill to"]="https://www.youtube.com/watch?v=28KRPhVzCus&list=PL6NdkXsPL07Il2hEQGcLI4dg_LTg7xA2L&index=5"
  ["sleep ambient radio 💤 relaxing music to fall asleep to"]="https://www.youtube.com/watch?v=28KRPhVzCus&list=PL6NdkXsPL07Il2hEQGcLI4dg_LTg7xA2L&index=6"
  ["Study With Me 📚 Pomodoro"]="https://www.youtube.com/watch?v=1oDrJba2PSs&list=PL6NdkXsPL07Il2hEQGcLI4dg_LTg7xA2L&index=8"
  ["chill guitar radio 🎸 music to study/relax to"]="https://www.youtube.com/watch?v=E_XmwjgRLz8&list=PL6NdkXsPL07Il2hEQGcLI4dg_LTg7xA2L&index=10"
  ["bossa lofi radio 🌴 chill music for relaxing days"]="https://www.youtube.com/watch?v=Zq9-4INDsvY&list=PL6NdkXsPL07Il2hEQGcLI4dg_LTg7xA2L&index=11"
  ["peaceful piano radio 🎹 music to focus/study to"]="https://www.youtube.com/watch?v=TtkFsfOP9QI&list=PL6NdkXsPL07Il2hEQGcLI4dg_LTg7xA2L&index=12"
  ["dark ambient radio 🌃 music to escape/dream to"]="https://www.youtube.com/watch?v=S_MOd40zlYU&list=PL6NdkXsPL07Il2hEQGcLI4dg_LTg7xA2L&index=13"
  ["sad lofi radio ☔ beats for rainy days"]="https://www.youtube.com/watch?v=P6Segk8cr-c&list=PL6NdkXsPL07Il2hEQGcLI4dg_LTg7xA2L&index=15"
  ["gentle rain ambience 🌧 cozy sound to chill to"]="https://www.youtube.com/watch?v=-OekvEFm1lo&list=PL6NdkXsPL07Il2hEQGcLI4dg_LTg7xA2L&index=16"
  ["fireplace ambience 🔥 cozy sound to chill to"]="https://www.youtube.com/watch?v=q_4KI-ChIIs&list=PL6NdkXsPL07Il2hEQGcLI4dg_LTg7xA2L&index=17"
)

# Populate local_music array with files from music directory and subdirectories
populate_local_music() {
  local_music=()
  filenames=()
  while IFS= read -r file; do
    local_music+=("$file")
    filenames+=("$(basename "$file")")
  done < <(find -L "$mDIR" -type f \( -iname "*.mp3" -o -iname "*.flac" -o -iname "*.wav" -o -iname "*.ogg" -o -iname "*.mp4" \))
}

# Function for displaying notifications
notification() {
  notify-send -u normal -i "$iDIR/music.png" "Now Playing:" "$@"
}

# Main function for playing local music
play_local_music() {
  populate_local_music

  # Prompt the user to select a song
  choice=$(printf "%s\n" "${filenames[@]}" | rofi -i -dmenu -config $rofi_theme)

  if [ -z "$choice" ]; then
    exit 1
  fi

  # Find the corresponding file path based on user's choice and set that to play the song then continue on the list
  for (( i=0; i<"${#filenames[@]}"; ++i )); do
    if [ "${filenames[$i]}" = "$choice" ]; then

      if music_playing; then
        stop_music
      fi
	    notification "$choice"
      mpv --playlist-start="$i" --loop-playlist --vid=no  "${local_music[@]}"

      break
    fi
  done
}

# Main function for shuffling local music
shuffle_local_music() {
  if music_playing; then
    stop_music
  fi
  notification "Shuffle Play local music"

  # Play music in $mDIR on shuffle
  mpv --shuffle --loop-playlist --vid=no "$mDIR"
}

# Main function for playing online music
play_online_music() {
  choice=$(for online in "${!online_music[@]}"; do
      echo "$online"
    done | sort | rofi -i -dmenu -config "$rofi_theme")

  if [ -z "$choice" ]; then
    exit 1
  fi

  link="${online_music[$choice]}"

  if music_playing; then
    stop_music
  fi
  notification "$choice"
  
  # Play the selected online music using mpv
  mpv --shuffle --vid=no "$link"
}

# Function to check if music is already playing
music_playing() {
  pgrep -x "mpv" > /dev/null
}

# Function to stop music and kill mpv processes
stop_music() {
  mpv_pids=$(pgrep -x mpv)

  if [ -n "$mpv_pids" ]; then
    # Get the PID of the mpv process used by mpvpaper (using the unique argument added)
    mpvpaper_pid=$(ps aux | grep -- 'unique-wallpaper-process' | grep -v 'grep' | awk '{print $2}')

    for pid in $mpv_pids; do
      if ! echo "$mpvpaper_pid" | grep -q "$pid"; then
        kill -9 $pid || true 
      fi
    done
    notify-send -u low -i "$iDIR/music.png" "Music stopped" || true
  fi
}

user_choice=$(printf "%s\n" \
  "Play from Online Stations" \
  "Play from Music directory" \
  "Shuffle Play from Music directory" \
  "Stop RofiBeats" \
  | rofi -dmenu -config $rofi_theme_1)

echo "User choice: $user_choice"

case "$user_choice" in
  "Play from Online Stations")
    play_online_music
    ;;
  "Play from Music directory")
    play_local_music
    ;;
  "Shuffle Play from Music directory")
    shuffle_local_music
    ;;
  "Stop RofiBeats")
    if music_playing; then
      stop_music
    fi
    ;;
  *)
    ;;
esac
