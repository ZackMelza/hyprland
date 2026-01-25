#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: set-hypr-profile.sh [--profile laptop|desktop] [--symlink] [--dry-run] [--force]

Detects the machine type and writes HYPR_PROFILE to:
  ~/.config/environment.d/99-hypr.conf
Also updates UserConfigs/Host.conf to point at the active profile.
Optionally symlinks ~/.config/hypr to the selected profile in this repo.

Options:
  --profile    Force a profile ("laptop" or "desktop")
  --symlink    Symlink ~/.config/hypr to the detected profile
  --dry-run    Print what would change without writing files
  --force      Overwrite existing config even if it differs
EOF
}

profile=""
dry_run=0
force=0
do_symlink=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --profile)
      profile="${2:-}"
      shift 2
      ;;
    --dry-run)
      dry_run=1
      shift
      ;;
    --symlink)
      do_symlink=1
      shift
      ;;
    --force)
      force=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
done

detect_profile() {
  local chassis=""
  if command -v hostnamectl >/dev/null 2>&1; then
    chassis="$(hostnamectl chassis 2>/dev/null || true)"
    case "$chassis" in
      laptop|desktop)
        echo "$chassis"
        return 0
        ;;
    esac
  fi

  if compgen -G "/sys/class/power_supply/BAT*" >/dev/null; then
    echo "laptop"
  else
    echo "desktop"
  fi
}

if [[ -z "$profile" ]]; then
  profile="$(detect_profile)"
fi

if [[ "$profile" != "laptop" && "$profile" != "desktop" ]]; then
  echo "Invalid profile: $profile" >&2
  exit 1
fi

env_dir="$HOME/.config/environment.d"
env_file="$env_dir/99-hypr.conf"
new_line="HYPR_PROFILE=$profile"
repo_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
profile_dir="$repo_root/$profile"
host_conf="$profile_dir/UserConfigs/Host.conf"

if [[ $dry_run -eq 1 ]]; then
  echo "Would write: $env_file"
  echo "$new_line"
  echo "Would write: $host_conf"
  echo "source = $repo_root/profiles/$profile.conf"
  if [[ $do_symlink -eq 1 ]]; then
    echo "Would symlink: $HOME/.config/hypr -> $profile_dir"
  fi
  exit 0
fi

mkdir -p "$env_dir"

if [[ -f "$env_file" && $force -ne 1 ]]; then
  if grep -qxF "$new_line" "$env_file"; then
    echo "HYPR_PROFILE already set to '$profile' in $env_file"
    exit 0
  fi
  echo "Refusing to overwrite $env_file without --force" >&2
  exit 1
fi

printf '%s\n' "$new_line" > "$env_file"
echo "Set HYPR_PROFILE=$profile in $env_file"

if [[ ! -d "$profile_dir/UserConfigs" ]]; then
  echo "UserConfigs directory not found: $profile_dir/UserConfigs" >&2
  exit 1
fi

cat > "$host_conf" <<EOF
# Host profile selector (local to this machine).
# set-hypr-profile.sh rewrites this file to point at the active profile.
\$RepoRoot = $repo_root
source = \$RepoRoot/profiles/$profile.conf
EOF
echo "Wrote $host_conf"

if [[ $do_symlink -eq 1 ]]; then
  if [[ ! -d "$profile_dir" ]]; then
    echo "Profile directory not found: $profile_dir" >&2
    exit 1
  fi

  hypr_dir="$HOME/.config/hypr"
  if [[ -L "$hypr_dir" ]]; then
    echo "Symlink already exists: $hypr_dir"
  elif [[ -e "$hypr_dir" && $force -ne 1 ]]; then
    echo "Refusing to overwrite $hypr_dir without --force" >&2
    exit 1
  else
    if [[ -e "$hypr_dir" ]]; then
      backup="${hypr_dir}.bak.$(date +%Y%m%d%H%M%S)"
      mv "$hypr_dir" "$backup"
      echo "Backed up $hypr_dir to $backup"
    fi
    ln -s "$profile_dir" "$hypr_dir"
    echo "Linked $hypr_dir -> $profile_dir"
  fi
fi
