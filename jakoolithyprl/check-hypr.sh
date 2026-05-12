#!/usr/bin/env bash
set -u

repo_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
active_dir="$repo_root/active"
hypr_dir="$HOME/.config/hypr"
env_file="$HOME/.config/environment.d/99-hypr.conf"

failures=0
warnings=0

ok() {
  printf 'ok: %s\n' "$1"
}

warn() {
  warnings=$((warnings + 1))
  printf 'warn: %s\n' "$1"
}

fail() {
  failures=$((failures + 1))
  printf 'fail: %s\n' "$1"
}

print_block() {
  sed 's/^/  /'
}

profile_from_env_file() {
  [[ -f "$env_file" ]] || return 1
  awk -F= '$1 == "HYPR_PROFILE" { print $2; found = 1 } END { exit !found }' "$env_file"
}

check_profile() {
  local profile="${HYPR_PROFILE:-}"

  if [[ -z "$profile" ]]; then
    profile="$(profile_from_env_file 2>/dev/null || true)"
  fi

  if [[ "$profile" == "laptop" || "$profile" == "desktop" ]]; then
    ok "HYPR_PROFILE is $profile"
  elif [[ -z "$profile" ]]; then
    warn "HYPR_PROFILE is not set and $env_file has no profile"
  else
    fail "HYPR_PROFILE has unexpected value: $profile"
  fi
}

check_symlink() {
  local resolved=""

  if [[ ! -e "$hypr_dir" ]]; then
    fail "$hypr_dir does not exist"
    return
  fi

  if [[ ! -L "$hypr_dir" ]]; then
    warn "$hypr_dir exists but is not a symlink"
    return
  fi

  resolved="$(readlink -f "$hypr_dir" 2>/dev/null || true)"
  if [[ "$resolved" == "$active_dir" ]]; then
    ok "$hypr_dir points to $active_dir"
  else
    fail "$hypr_dir points to $resolved instead of $active_dir"
  fi
}

check_active_tree() {
  local path=""

  if [[ -d "$active_dir" ]]; then
    ok "active tree exists"
  else
    fail "active tree is missing: $active_dir"
    return
  fi

  for path in \
    "$active_dir/hyprland.conf" \
    "$active_dir/configs/Keybinds.conf" \
    "$active_dir/UserConfigs/UserSettings.conf" \
    "$active_dir/UserConfigs/Host.conf" \
    "$active_dir/wallust/wallust-hyprland.conf"
  do
    if [[ -e "$path" ]]; then
      ok "found ${path#$repo_root/}"
    else
      fail "missing ${path#$repo_root/}"
    fi
  done
}

check_guard() {
  local entrypoint="$active_dir/hyprland.conf"
  local guard_script="$active_dir/scripts/GuardHyprConfig.sh"

  if [[ -x "$guard_script" ]]; then
    ok "guard script is available"
  elif [[ -e "$guard_script" ]]; then
    warn "guard script exists but is not executable: ${guard_script#$repo_root/}"
  else
    warn "guard script is missing from active tree; rebuild with set-hypr-profile.sh"
  fi

  if [[ -L "$entrypoint" ]]; then
    warn "active/hyprland.conf is still a symlink; rebuild to create the managed wrapper"
    return
  fi

  if grep -qxF 'source = $RepoRoot/common/hyprland.conf' "$entrypoint" 2>/dev/null; then
    ok "active/hyprland.conf uses the managed wrapper"
  else
    warn "active/hyprland.conf is not the expected managed wrapper"
  fi
}

check_obsolete_config() {
  local matches=""

  matches="$(grep -RnsE '^[[:space:]]*pseudotile[[:space:]]*=' "$repo_root/common" 2>/dev/null || true)"
  if [[ -z "$matches" ]]; then
    ok "no obsolete pseudotile key found in common config"
  else
    fail "obsolete pseudotile key found in common config"
    printf '%s\n' "$matches" | print_block
  fi

  matches="$(
    find "$repo_root/common" -type f -name '*.conf' -print0 \
      | xargs -0 awk '
          /^[[:space:]]*misc[[:space:]]*\{/ { in_misc = 1 }
          in_misc && /^[[:space:]]*\}/ { in_misc = 0 }
          in_misc && /^[[:space:]]*vfr[[:space:]]*=/ { printf "%s:%d:%s\n", FILENAME, FNR, $0 }
        ' 2>/dev/null \
      || true
  )"
  if [[ -z "$matches" ]]; then
    ok "no obsolete misc:vfr key found in common config"
  else
    fail "obsolete misc:vfr key found in common config"
    printf '%s\n' "$matches" | print_block
  fi

  matches="$(
    grep -RnsE 'bind[[:space:]]*=.*,[[:space:]]*togglesplit([[:space:]#]|$)' "$repo_root/common" 2>/dev/null \
      | grep -vE 'layoutmsg[[:space:]]*,[[:space:]]*togglesplit([[:space:]#]|$)' \
      || true
  )"
  if [[ -z "$matches" ]]; then
    ok "no direct obsolete togglesplit dispatcher found"
  else
    fail "direct obsolete togglesplit dispatcher found"
    printf '%s\n' "$matches" | print_block
  fi
}

check_portability() {
  local matches=""

  matches="$(grep -RnsE '/home/[^[:space:]]+/.*/jakoolithyprl|/path/to/this/repo' "$repo_root/profiles" "$repo_root/common" 2>/dev/null || true)"
  if [[ -z "$matches" ]]; then
    ok "no hardcoded checkout paths in sourced profile/common config"
  else
    fail "hardcoded checkout path found in sourced profile/common config"
    printf '%s\n' "$matches" | print_block
  fi
}

check_hyprctl() {
  local output=""

  if ! command -v hyprctl >/dev/null 2>&1; then
    warn "hyprctl is not installed or not on PATH"
    return
  fi

  output="$(hyprctl configerrors 2>&1)"
  case "$output" in
    ""|*"no errors"*)
      ok "hyprctl configerrors reports no errors"
      ;;
    *"Couldn't set socket timeout"*|*"HYPRLAND_INSTANCE_SIGNATURE"*)
      warn "hyprctl could not reach the running Hyprland session"
      printf '%s\n' "$output" | print_block
      ;;
    *)
      fail "hyprctl configerrors reported problems"
      printf '%s\n' "$output" | print_block
      ;;
  esac
}

main() {
  printf 'Hyprland profile check\n'
  printf 'repo: %s\n\n' "$repo_root"

  check_profile
  check_symlink
  check_active_tree
  check_guard
  check_obsolete_config
  check_portability
  check_hyprctl

  printf '\n'
  if [[ $failures -eq 0 ]]; then
    printf 'Done: %s failure(s), %s warning(s)\n' "$failures" "$warnings"
    exit 0
  fi

  printf 'Done: %s failure(s), %s warning(s)\n' "$failures" "$warnings"
  exit 1
}

main "$@"
