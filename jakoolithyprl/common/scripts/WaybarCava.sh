#!/usr/bin/env bash
# WaybarCava.sh — safer single-instance handling, cleanup, and robustness
# Original concept by JaKooLit; this variant focuses on lifecycle hardening.

set -euo pipefail

# The login locale may temporarily be unavailable after an Arch/glibc update.
# Force a UTF-8 locale so Bash slices the bar glyphs as characters, not bytes.
export LC_ALL=C.UTF-8

# Ensure cava exists
if ! command -v cava >/dev/null 2>&1; then
  echo "cava not found in PATH" >&2
  exit 1
fi

# 0..7 → ▁▂▃▄▅▆▇█
bars=("▁" "▂" "▃" "▄" "▅" "▆" "▇" "█")

# Single-instance guard (only kill our previous instance if it’s still alive)
RUNTIME_DIR="${XDG_RUNTIME_DIR:-/tmp}"
pidfile="$RUNTIME_DIR/waybar-cava.pid"
if [[ -f "$pidfile" ]]; then
  oldpid="$(cat "$pidfile" || true)"
  if [[ -n "$oldpid" ]] && kill -0 "$oldpid" 2>/dev/null; then
    kill "$oldpid" 2>/dev/null || true
    sleep 0.1 || true
  fi
fi
printf '%d' $$ >"$pidfile"

# Unique runtime directory + explicit child cleanup. A plain pipeline can leave
# Cava orphaned when Waybar restarts, so keep and terminate its PID ourselves.
temp_dir="$(mktemp -d "$RUNTIME_DIR/waybar-cava.XXXXXX")"
config_file="$temp_dir/config"
output_fifo="$temp_dir/output"
cava_pid=""

cleanup() {
  if [[ -n "$cava_pid" ]] && kill -0 "$cava_pid" 2>/dev/null; then
    kill "$cava_pid" 2>/dev/null || true
    wait "$cava_pid" 2>/dev/null || true
  fi
  rm -f "$output_fifo" "$config_file"
  rmdir "$temp_dir" 2>/dev/null || true
  if [[ "$(cat "$pidfile" 2>/dev/null || true)" == "$$" ]]; then
    rm -f "$pidfile"
  fi
}
trap cleanup EXIT INT TERM

cat >"$config_file" <<EOF
[general]
framerate = 30
bars = 10

[input]
method = pulse
source = auto

[output]
method = raw
raw_target = /dev/stdout
data_format = ascii
ascii_max_range = 7
EOF

mkfifo "$output_fifo"
cava -p "$config_file" >"$output_fifo" &
cava_pid=$!

# Stream Cava output and translate its semicolon-delimited 0..7 values.
while IFS=';' read -r -a values; do
  output=""
  for value in "${values[@]}"; do
    if [[ "$value" =~ ^[0-7]$ ]]; then
      output+="${bars[value]}"
    fi
  done
  printf '%s\n' "$output"
done <"$output_fifo"

wait "$cava_pid" 2>/dev/null || true
