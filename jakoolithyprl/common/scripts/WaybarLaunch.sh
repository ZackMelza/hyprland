#!/usr/bin/env bash
set -u

# Keep Waybar usable while the configured login locale is temporarily missing.
requested_locale="${LC_ALL:-${LC_CTYPE:-${LANG:-C.UTF-8}}}"
normalized_requested="$(
  printf '%s' "$requested_locale" |
    tr '[:upper:]' '[:lower:]' |
    tr -d '._-'
)"

locale_available=false
while IFS= read -r available_locale; do
  normalized_available="$(
    printf '%s' "$available_locale" |
      tr '[:upper:]' '[:lower:]' |
      tr -d '._-'
  )"
  if [[ "$normalized_available" == "$normalized_requested" ]]; then
    locale_available=true
    break
  fi
done < <(locale -a 2>/dev/null)

if [[ "$locale_available" != true ]]; then
  export LANG=C.UTF-8
  export LC_ALL=C.UTF-8
fi

state_dir="${XDG_STATE_HOME:-$HOME/.local/state}/hypr"
mkdir -p "$state_dir"
log_file="$state_dir/waybar.log"

exec waybar -l warning >>"$log_file" 2>&1
