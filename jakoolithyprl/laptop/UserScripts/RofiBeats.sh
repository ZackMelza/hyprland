#!/usr/bin/env bash
# /* ---- 💫 https://github.com/JaKooLit 💫 ---- */
# Player-style Rofi music launcher for local files + YouTube.

set -u

mDIR="$HOME/Music"
iDIR="$HOME/.config/swaync/icons"
rofi_theme="$HOME/.config/rofi/config-rofi-Beats.rasi"
rofi_theme_menu="$HOME/.config/rofi/config-rofi-Beats-menu.rasi"
MPV_SOCKET="${XDG_RUNTIME_DIR:-/tmp}/rofibeats-mpv.sock"
rofi_size_override='window { width: 88%; } listview { lines: 5; columns: 2; fixed-columns: true; dynamic: false; }'
rofi_search_override='window { width: 92%; } listview { lines: 10; columns: 1; fixed-columns: true; dynamic: false; }'

# Preset YouTube links (edit freely)
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

notification() {
  notify-send -u normal -i "$iDIR/music.png" "RofiBeats" "$*" >/dev/null 2>&1 || true
}

error_notification() {
  notify-send -u critical -i "$iDIR/music.png" "RofiBeats" "$*" >/dev/null 2>&1 || true
}

rofi_menu() {
  local prompt="$1"
  local theme="$2"
  local override="${3:-$rofi_size_override}"
  rofi -i -dmenu -p "$prompt" -config "$theme" -theme-str "$override"
}

rofi_input() {
  local prompt="$1"
  local theme="$2"
  printf "" | rofi -dmenu -p "$prompt" -config "$theme" -theme-str "$rofi_size_override"
}

music_playing() {
  pgrep -x mpv >/dev/null
}

# Avoid killing mpvpaper mpv process if present.
stop_music() {
  local mpv_pids mpvpaper_pid
  mpv_pids="$(pgrep -x mpv || true)"

  [ -z "$mpv_pids" ] && return 0

  mpvpaper_pid="$(ps aux | grep -- 'unique-wallpaper-process' | grep -v 'grep' | awk '{print $2}' || true)"

  for pid in $mpv_pids; do
    if ! echo "$mpvpaper_pid" | grep -q "$pid"; then
      kill "$pid" >/dev/null 2>&1 || true
    fi
  done

  rm -f "$MPV_SOCKET" >/dev/null 2>&1 || true
  notify-send -u low -i "$iDIR/music.png" "Music stopped" >/dev/null 2>&1 || true
}

start_mpv() {
  local desc="$1"
  shift

  stop_music
  rm -f "$MPV_SOCKET" >/dev/null 2>&1 || true

  # Launch detached so rofi can exit immediately.
  nohup mpv \
    --vid=no \
    --force-window=no \
    --input-ipc-server="$MPV_SOCKET" \
    "$@" >/dev/null 2>&1 &

  notification "Now playing: $desc"
}

mpv_ipc() {
  local payload="$1"

  if [ ! -S "$MPV_SOCKET" ]; then
    error_notification "No active player session"
    return 1
  fi

  if command -v socat >/dev/null 2>&1; then
    printf '%s\n' "$payload" | socat - "$MPV_SOCKET" >/dev/null 2>&1 || true
  elif command -v nc >/dev/null 2>&1; then
    printf '%s\n' "$payload" | nc -U "$MPV_SOCKET" >/dev/null 2>&1 || true
  else
    error_notification "Install socat or nc for playback controls"
    return 1
  fi

  return 0
}

populate_local_music() {
  local_music=()
  display_names=()

  while IFS= read -r file; do
    local_music+=("$file")
    display_names+=("${file#"$mDIR"/}")
  done < <(find -L "$mDIR" -type f \( -iname "*.mp3" -o -iname "*.flac" -o -iname "*.wav" -o -iname "*.ogg" -o -iname "*.m4a" -o -iname "*.mp4" \) | sort)
}

play_local_music() {
  if [ ! -d "$mDIR" ]; then
    error_notification "Music directory not found: $mDIR"
    return
  fi

  populate_local_music
  if [ "${#local_music[@]}" -eq 0 ]; then
    error_notification "No local audio files found in $mDIR"
    return
  fi

  local choice i
  choice="$(printf "%s\n" "${display_names[@]}" | rofi_menu "Local Music" "$rofi_theme")"
  [ -z "$choice" ] && return

  for ((i = 0; i < ${#display_names[@]}; i++)); do
    if [ "${display_names[$i]}" = "$choice" ]; then
      start_mpv "$choice" --playlist-start="$i" --loop-playlist "${local_music[@]}"
      return
    fi
  done
}

shuffle_local_music() {
  if [ ! -d "$mDIR" ]; then
    error_notification "Music directory not found: $mDIR"
    return
  fi

  start_mpv "Local shuffle" --shuffle --loop-playlist "$mDIR"
}

play_preset_online() {
  local choice link
  choice="$({ for name in "${!online_music[@]}"; do printf "%s\n" "$name"; done; } | sort | rofi_menu "YouTube Presets" "$rofi_theme")"
  [ -z "$choice" ] && return

  link="${online_music[$choice]}"
  start_mpv "$choice" "$link"
}

play_direct_url() {
  local link
  link="$(rofi_input "Paste URL" "$rofi_theme")"
  [ -z "$link" ] && return

  start_mpv "$link" "$link"
}

search_youtube() {
  local query selection
  query="$(rofi_input "YouTube Search" "$rofi_theme")"
  [ -z "$query" ] && return

  if command -v yt-dlp >/dev/null 2>&1; then
    local results=() urls=() video_id title duration_str live_status channel uploader meta idx picked_index
    local delim=$'\x1f'

    # Method 1: flat search (fast).
    while IFS="$delim" read -r video_id title duration_str live_status channel uploader; do
      [ -z "${video_id:-}" ] && continue
      [ -z "${title:-}" ] && continue
      if [ -z "${channel:-}" ] || [ "${channel:-}" = "NA" ]; then
        channel="${uploader:-Unknown Channel}"
      fi
      if [ -z "${channel:-}" ] || [ "${channel:-}" = "NA" ]; then
        channel="Unknown Channel"
      fi
      if [ "${live_status:-}" = "is_live" ]; then
        meta="[LIVE]"
      elif [ -n "${duration_str:-}" ] && [ "${duration_str:-}" != "NA" ]; then
        meta="[$duration_str]"
      else
        meta="[--:--]"
      fi
      idx=$(( ${#results[@]} + 1 ))
      results+=("[$idx] $title  -  $channel  $meta")
      urls+=("https://www.youtube.com/watch?v=$video_id")
    done < <(yt-dlp --no-warnings --flat-playlist --print "%(id)s${delim}%(title)s${delim}%(duration_string|NA)s${delim}%(live_status|NA)s${delim}%(channel|NA)s${delim}%(uploader|NA)s" "ytsearch12:${query}" 2>/dev/null)

    # Method 2: non-flat search fallback for yt-dlp variants where flat output is empty.
    if [ "${#results[@]}" -eq 0 ]; then
      while IFS="$delim" read -r video_id title duration_str live_status channel uploader; do
        [ -z "${video_id:-}" ] && continue
        [ -z "${title:-}" ] && continue
        if [ -z "${channel:-}" ] || [ "${channel:-}" = "NA" ]; then
          channel="${uploader:-Unknown Channel}"
        fi
        if [ -z "${channel:-}" ] || [ "${channel:-}" = "NA" ]; then
          channel="Unknown Channel"
        fi
        if [ "${live_status:-}" = "is_live" ]; then
          meta="[LIVE]"
        elif [ -n "${duration_str:-}" ] && [ "${duration_str:-}" != "NA" ]; then
          meta="[$duration_str]"
        else
          meta="[--:--]"
        fi
        idx=$(( ${#results[@]} + 1 ))
        results+=("[$idx] $title  -  $channel  $meta")
        urls+=("https://www.youtube.com/watch?v=$video_id")
      done < <(yt-dlp --no-warnings --print "%(id)s${delim}%(title)s${delim}%(duration_string|NA)s${delim}%(live_status|NA)s${delim}%(channel|NA)s${delim}%(uploader|NA)s" "ytsearch12:${query}" 2>/dev/null)
    fi

    if [ "${#results[@]}" -eq 0 ]; then
      # Final fallback: let mpv/ytdl resolve the query directly.
      start_mpv "$query" "ytdl://ytsearch1:${query}"
      return
    fi

    selection="$(printf "%s\n" "${results[@]}" | rofi_menu "Select Result" "$rofi_theme" "$rofi_search_override")"
    [ -z "$selection" ] && return

    picked_index="${selection#\[}"
    picked_index="${picked_index%%]*}"
    if [[ "$picked_index" =~ ^[0-9]+$ ]] && [ "$picked_index" -ge 1 ] && [ "$picked_index" -le "${#urls[@]}" ]; then
      start_mpv "$selection" "${urls[$((picked_index - 1))]}"
      return
    fi
    error_notification "Could not parse selected result"
  else
    # Fallback: mpv + ytdl hook search syntax.
    start_mpv "$query" "ytdl://ytsearch1:${query}"
  fi
}

player_controls_menu() {
  local action
  action="$(printf "%s\n" \
    "Pause/Resume" \
    "Next" \
    "Previous" \
    "Seek +10s" \
    "Seek -10s" \
    "Volume +5" \
    "Volume -5" \
    "Mute/Unmute" \
    "Stop" \
    | rofi_menu "Player Controls" "$rofi_theme_menu")"

  case "$action" in
    "Pause/Resume")
      mpv_ipc '{"command": ["cycle", "pause"]}' && notification "Toggled pause"
      ;;
    "Next")
      mpv_ipc '{"command": ["playlist-next", "force"]}' && notification "Next track"
      ;;
    "Previous")
      mpv_ipc '{"command": ["playlist-prev", "force"]}' && notification "Previous track"
      ;;
    "Seek +10s")
      mpv_ipc '{"command": ["seek", 10, "relative"]}' && notification "Seeked +10s"
      ;;
    "Seek -10s")
      mpv_ipc '{"command": ["seek", -10, "relative"]}' && notification "Seeked -10s"
      ;;
    "Volume +5")
      mpv_ipc '{"command": ["add", "volume", 5]}' && notification "Volume +5"
      ;;
    "Volume -5")
      mpv_ipc '{"command": ["add", "volume", -5]}' && notification "Volume -5"
      ;;
    "Mute/Unmute")
      mpv_ipc '{"command": ["cycle", "mute"]}' && notification "Toggled mute"
      ;;
    "Stop")
      stop_music
      ;;
    *)
      ;;
  esac
}

main_menu() {
  local user_choice
  user_choice="$(printf "%s\n" \
    "YouTube Search" \
    "Play YouTube Presets" \
    "Play From URL" \
    "Play from Music directory" \
    "Shuffle Play from Music directory" \
    "Player Controls" \
    "Stop RofiBeats" \
    | rofi_menu "RofiBeats" "$rofi_theme_menu")"

  case "$user_choice" in
    "YouTube Search")
      search_youtube
      ;;
    "Play YouTube Presets")
      play_preset_online
      ;;
    "Play From URL")
      play_direct_url
      ;;
    "Play from Music directory")
      play_local_music
      ;;
    "Shuffle Play from Music directory")
      shuffle_local_music
      ;;
    "Player Controls")
      player_controls_menu
      ;;
    "Stop RofiBeats")
      stop_music
      ;;
    *)
      ;;
  esac
}

main_menu
