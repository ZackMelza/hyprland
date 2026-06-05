#!/usr/bin/env bash
# /* ---- 💫 https://github.com/JaKooLit 💫 ---- */
# Player-style Rofi music launcher for local files + YouTube.

set -u

mDIR="$HOME/Music"
iDIR="$HOME/.config/swaync/icons"
rofi_theme="$HOME/.config/rofi/config-rofi-Beats.rasi"
rofi_theme_menu="$HOME/.config/rofi/config-rofi-Beats-menu.rasi"
MPV_SOCKET="${XDG_RUNTIME_DIR:-/tmp}/rofibeats-mpv.sock"
rofi_input_override='window { width: 50%; } listview { lines: 0; }'
startup_config="$HOME/.config/hypr/UserConfigs/Startup_Apps.conf"
startup_command='exec-once = $UserScripts/RofiBeats.sh --startup-loop'

# Preset YouTube links (edit freely)
playlist_id="PL6NdkXsPL07Il2hEQGcLI4dg_LTg7xA2L"

online_music_names=(
  "lofi hip hop radio 📚 beats to relax/study to"
  "synthwave radio 🌌 beats to chill/game to"
  "lofi hip hop radio 💤 beats to sleep/chill to"
  "jazz lofi radio 🎷 beats to chill/study to"
  "sleep ambient music 💤 relaxing radio to fall asleep to"
  "bossa lofi radio 🌴 chill music for relaxing days"
  "relaxing piano radio 🎹 calm music to focus to"
  "relaxing jazz music 🌹 cozy radio to study/chill to"
  "classical music radio 🎻 relaxing songs to read/study to"
  "chill guitar radio 🎸 music to study/relax to"
  "dark ambient radio 🌃 music to escape/dream to"
  "medieval lofi radio 🏰 - beats to scribe manuscripts to"
  "christmas lofi music🎄cozy radio to get festive to"
  "Halloween lofi radio  🧟‍♀️ - spooky beats to get chills to"
  "gentle rain ambience 🌧 cozy sound to chill to"
  "fireplace ambience 🔥 cozy sound to chill to"
)

declare -A online_music=(
  ["lofi hip hop radio 📚 beats to relax/study to"]="https://www.youtube.com/watch?v=X4VbdwhkE10"
  ["synthwave radio 🌌 beats to chill/game to"]="https://www.youtube.com/watch?v=4xDzrJKXOOY&list=$playlist_id&index=2"
  ["lofi hip hop radio 💤 beats to sleep/chill to"]="https://www.youtube.com/watch?v=JD-kMIpDfnY&list=$playlist_id&index=3"
  ["jazz lofi radio 🎷 beats to chill/study to"]="https://www.youtube.com/watch?v=E2vONfzoyRI&list=$playlist_id&index=4"
  ["sleep ambient music 💤 relaxing radio to fall asleep to"]="https://www.youtube.com/watch?v=xORCbIptqcc&list=$playlist_id&index=5"
  ["bossa lofi radio 🌴 chill music for relaxing days"]="https://www.youtube.com/watch?v=56llPN9tS88&list=$playlist_id&index=6"
  ["relaxing piano radio 🎹 calm music to focus to"]="https://www.youtube.com/watch?v=N0snMcR6aaA&list=$playlist_id&index=7"
  ["relaxing jazz music 🌹 cozy radio to study/chill to"]="https://www.youtube.com/watch?v=A8jDx9TLMQc&list=$playlist_id&index=8"
  ["classical music radio 🎻 relaxing songs to read/study to"]="https://www.youtube.com/watch?v=jXAEIWcGXwE&list=$playlist_id&index=9"
  ["chill guitar radio 🎸 music to study/relax to"]="https://www.youtube.com/watch?v=E_XmwjgRLz8&list=$playlist_id&index=10"
  ["dark ambient radio 🌃 music to escape/dream to"]="https://www.youtube.com/watch?v=S_MOd40zlYU&list=$playlist_id&index=11"
  ["medieval lofi radio 🏰 - beats to scribe manuscripts to"]="https://www.youtube.com/watch?v=IxPANmjPaek&list=$playlist_id&index=12"
  ["christmas lofi music🎄cozy radio to get festive to"]="https://www.youtube.com/watch?v=XSXEaikz0Bc&list=$playlist_id&index=13"
  ["Halloween lofi radio  🧟‍♀️ - spooky beats to get chills to"]="https://www.youtube.com/watch?v=3GQY80jyysQ&list=$playlist_id&index=14"
  ["gentle rain ambience 🌧 cozy sound to chill to"]="https://www.youtube.com/watch?v=-OekvEFm1lo&list=$playlist_id&index=15"
  ["fireplace ambience 🔥 cozy sound to chill to"]="https://www.youtube.com/watch?v=q_4KI-ChIIs&list=$playlist_id&index=16"
)

declare -A online_music_fallback_queries=(
  ["lofi hip hop radio 📚 beats to relax/study to"]="Lofi Girl lofi hip hop radio beats to relax study to live"
  ["synthwave radio 🌌 beats to chill/game to"]="Lofi Girl synthwave radio beats to chill game to live"
  ["lofi hip hop radio 💤 beats to sleep/chill to"]="Lofi Girl lofi hip hop radio beats to sleep chill to live"
  ["jazz lofi radio 🎷 beats to chill/study to"]="Lofi Girl jazz lofi radio beats to chill study to live"
)

loop_track_names=(
  "Bloody Tears - V rising Adaptation - DLC Legacy Of Castlevania Premium Soundtrack"
)

declare -A loop_tracks=(
  ["Bloody Tears - V rising Adaptation - DLC Legacy Of Castlevania Premium Soundtrack"]="https://www.youtube.com/watch?v=7etjdosXsSs"
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
  local override="${3:-$(rofi_dynamic_override 6 40 1 1 8)}"
  rofi -i -dmenu -p "$prompt" -config "$theme" -theme-str "$override"
}

rofi_dynamic_override() {
  local count="$1"
  local longest="$2"
  local columns="$3"
  local min_lines="$4"
  local max_lines="$5"
  local lines width

  [ "$count" -lt 1 ] && count=1
  [ "$columns" -lt 1 ] && columns=1

  lines=$(((count + columns - 1) / columns))
  [ "$lines" -lt "$min_lines" ] && lines="$min_lines"
  [ "$lines" -gt "$max_lines" ] && lines="$max_lines"

  if [ "$columns" -gt 1 ]; then
    width=$((42 + (columns * 14)))
  else
    width=42
  fi

  if [ "$longest" -gt 42 ]; then
    width=$((width + 10))
  fi
  if [ "$longest" -gt 72 ]; then
    width=$((width + 14))
  fi

  [ "$width" -lt 38 ] && width=38
  [ "$width" -gt 92 ] && width=92

  printf 'window { width: %s%%; } listview { lines: %s; columns: %s; fixed-columns: true; dynamic: true; }' "$width" "$lines" "$columns"
}

longest_entry_length() {
  local max=0 entry

  for entry in "$@"; do
    if [ "${#entry}" -gt "$max" ]; then
      max="${#entry}"
    fi
  done

  printf '%s' "$max"
}

rofi_array_menu() {
  local prompt="$1"
  local theme="$2"
  local columns="$3"
  local min_lines="$4"
  local max_lines="$5"
  shift 5

  local override
  override="$(rofi_dynamic_override "$#" "$(longest_entry_length "$@")" "$columns" "$min_lines" "$max_lines")"
  printf "%s\n" "$@" | rofi_menu "$prompt" "$theme" "$override"
}

rofi_input() {
  local prompt="$1"
  local theme="$2"
  printf "" | rofi -dmenu -p "$prompt" -config "$theme" -theme-str "$rofi_input_override"
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

start_online_music() {
  local desc="$1"
  local link="$2"
  local fallback_query="${online_music_fallback_queries[$desc]:-}"

  if [ -n "$fallback_query" ]; then
    start_mpv "$desc" "$link" "ytdl://ytsearch1:${fallback_query}"
  else
    start_mpv "$desc" "$link"
  fi
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
  elif command -v python3 >/dev/null 2>&1; then
    MPV_SOCKET_PATH="$MPV_SOCKET" MPV_IPC_PAYLOAD="$payload" python3 - <<'PY' >/dev/null 2>&1 || true
import os
import socket

sock = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
sock.connect(os.environ["MPV_SOCKET_PATH"])
sock.sendall((os.environ["MPV_IPC_PAYLOAD"] + "\n").encode())
sock.close()
PY
  else
    error_notification "Install socat, nc, or python3 for playback controls"
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
  choice="$(rofi_array_menu "Local Music" "$rofi_theme" 1 4 12 "${display_names[@]}")"
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
  choice="$(rofi_array_menu "Lofi Girl Radio" "$rofi_theme" 1 4 12 "${online_music_names[@]}")"
  [ -z "$choice" ] && return

  link="${online_music[$choice]}"
  start_online_music "$choice" "$link"
}

play_loop_track() {
  local choice link
  choice="$(rofi_array_menu "Looping Tracks" "$rofi_theme" 1 1 6 "${loop_track_names[@]}")"
  [ -z "$choice" ] && return

  link="${loop_tracks[$choice]}"
  start_mpv "$choice" --loop-file=inf "$link"
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

    selection="$(rofi_array_menu "Select Result" "$rofi_theme" 1 5 12 "${results[@]}")"
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
  local actions=(
    "Pause/Resume"
    "Next"
    "Previous"
    "Seek +10s"
    "Seek -10s"
    "Volume +5"
    "Volume -5"
    "Mute/Unmute"
    "Stop"
  )
  action="$(rofi_array_menu "Player Controls" "$rofi_theme_menu" 2 3 6 "${actions[@]}")"

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

startup_loop_enabled() {
  grep -Fxq "$startup_command" "$startup_config" 2>/dev/null
}

set_startup_loop() {
  local state="$1"
  local disabled_startup_command="#$startup_command"
  local tmp

  if [ ! -f "$startup_config" ]; then
    error_notification "Startup config not found: $startup_config"
    return 1
  fi

  tmp="${startup_config}.tmp.$$"

  if [ "$state" = "on" ]; then
    if grep -Fxq "$startup_command" "$startup_config"; then
      notification "Boot loop already enabled"
      return 0
    fi

    if grep -Fxq "$disabled_startup_command" "$startup_config"; then
      awk -v disabled="$disabled_startup_command" -v enabled="$startup_command" '
        $0 == disabled { print enabled; next }
        { print }
      ' "$startup_config" > "$tmp" && mv "$tmp" "$startup_config"
    else
      {
        printf "\n# RofiBeats optional startup loops\n"
        printf "%s\n" "$startup_command"
      } >> "$startup_config"
    fi

    notification "Boot loop enabled"
  else
    if ! grep -Fxq "$startup_command" "$startup_config"; then
      notification "Boot loop already disabled"
      return 0
    fi

    awk -v enabled="$startup_command" -v disabled="$disabled_startup_command" '
      $0 == enabled { print disabled; next }
      { print }
    ' "$startup_config" > "$tmp" && mv "$tmp" "$startup_config"
    notification "Boot loop disabled"
  fi

  rm -f "$tmp" >/dev/null 2>&1 || true
}

toggle_startup_loop() {
  if startup_loop_enabled; then
    set_startup_loop off
  else
    set_startup_loop on
  fi
}

main_menu() {
  local user_choice startup_action
  if startup_loop_enabled; then
    startup_action="Disable Boot Loop"
  else
    startup_action="Enable Boot Loop"
  fi

  local actions=(
    "YouTube Search"
    "Play Lofi Girl Radio"
    "Play Looping Track"
    "$startup_action"
    "Play From URL"
    "Play from Music directory"
    "Shuffle Play from Music directory"
    "Player Controls"
    "Stop RofiBeats"
  )
  user_choice="$(rofi_array_menu "RofiBeats" "$rofi_theme_menu" 2 3 5 "${actions[@]}")"

  case "$user_choice" in
    "YouTube Search")
      search_youtube
      ;;
    "Play Lofi Girl Radio")
      play_preset_online
      ;;
    "Play Looping Track")
      play_loop_track
      ;;
    "$startup_action")
      toggle_startup_loop
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

case "${1:-}" in
  --bloody-tears | --castlevania-loop | --startup-loop)
    start_mpv "${loop_track_names[0]}" --loop-file=inf "${loop_tracks[${loop_track_names[0]}]}"
    ;;
  --lofi-girl | --lofi-radio)
    start_online_music "${online_music_names[0]}" "${online_music[${online_music_names[0]}]}"
    ;;
  --stop)
    stop_music
    ;;
  *)
    main_menu
    ;;
esac
