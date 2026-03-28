#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: set-hypr-profile.sh [--profile laptop|desktop] [--symlink] [--dry-run] [--force]

Detects the machine type and writes HYPR_PROFILE to:
  ~/.config/environment.d/99-hypr.conf
Also updates UserConfigs/Host.conf to point at the active profile.
Builds a local active/ tree that combines the shared common/ base with
machine-local runtime files.
Optionally symlinks ~/.config/hypr to the generated active/ tree.

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
active_dir="$repo_root/active"
legacy_host_conf="$profile_dir/UserConfigs/Host.conf"
active_userconfigs_dir="$active_dir/UserConfigs"
active_host_conf="$active_userconfigs_dir/Host.conf"

link_managed_path() {
  local target="$1"
  local link_path="$2"

  rm -rf "$link_path"
  ln -s "$target" "$link_path"
}

write_host_conf() {
  local host_conf="$1"

  mkdir -p "$(dirname "$host_conf")"
  cat > "$host_conf" <<EOF
# Host profile selector (local to this machine).
# set-hypr-profile.sh rewrites this file to point at the active profile.
\$RepoRoot = $repo_root
source = \$RepoRoot/profiles/$profile.conf
EOF
}

build_active_tree() {
  local rel=""
  local source_path=""
  local target_path=""
  local name=""

  mkdir -p "$active_dir" "$active_userconfigs_dir" \
    "$active_dir/wallpaper_effects" "$active_dir/wallust"

  for rel in \
    Monitor_Profiles \
    animations \
    configs \
    scripts \
    application-style.conf \
    hypridle.conf \
    hyprland.conf \
    hyprlock-2k.conf \
    hyprlock.conf \
    initial-boot.sh \
    v2.3.17
  do
    source_path="$repo_root/common/$rel"
    target_path="$active_dir/$rel"
    link_managed_path "$source_path" "$target_path"
  done

  rm -rf "$active_dir/UserScripts"
  mkdir -p "$active_dir/UserScripts"
  for source_path in "$repo_root/common/UserScripts/"*; do
    [[ -e "$source_path" ]] || continue
    link_managed_path "$source_path" "$active_dir/UserScripts/$(basename "$source_path")"
  done

  for source_path in "$profile_dir/UserScripts/"*; do
    [[ -e "$source_path" ]] || continue
    name="$(basename "$source_path")"
    if [[ ! -e "$repo_root/common/UserScripts/$name" || "$name" == "WallpaperAutoChange.sh" || "$name" == "WallpaperRandom.sh" ]]; then
      link_managed_path "$source_path" "$active_dir/UserScripts/$name"
    fi
  done

  for source_path in "$repo_root/common/UserConfigs/"*; do
    [[ -e "$source_path" ]] || continue
    link_managed_path "$source_path" "$active_userconfigs_dir/$(basename "$source_path")"
  done

  if [[ -f "$profile_dir/UserConfigs/Host.conf.example" ]]; then
    link_managed_path \
      "$profile_dir/UserConfigs/Host.conf.example" \
      "$active_userconfigs_dir/Host.conf.example"
  fi

  write_host_conf "$active_host_conf"

  if [[ ! -e "$active_dir/monitors.conf" && -f "$profile_dir/monitors.conf" ]]; then
    cp "$profile_dir/monitors.conf" "$active_dir/monitors.conf"
  fi

  if [[ ! -e "$active_dir/workspaces.conf" && -f "$profile_dir/workspaces.conf" ]]; then
    cp "$profile_dir/workspaces.conf" "$active_dir/workspaces.conf"
  fi

  if [[ ! -e "$active_dir/monitors.conf" ]]; then
    printf '# Local monitor layout overrides.\n' > "$active_dir/monitors.conf"
  fi

  if [[ ! -e "$active_dir/workspaces.conf" ]]; then
    printf '# Local workspace rules.\n' > "$active_dir/workspaces.conf"
  fi

  if [[ ! -e "$active_dir/wallpaper_effects/.wallpaper_current" && -f "$profile_dir/wallpaper_effects/.wallpaper_current" ]]; then
    cp "$profile_dir/wallpaper_effects/.wallpaper_current" "$active_dir/wallpaper_effects/.wallpaper_current"
  fi

  if [[ ! -e "$active_dir/wallust/wallust-hyprland.conf" && -f "$profile_dir/wallust/wallust-hyprland.conf" ]]; then
    cp "$profile_dir/wallust/wallust-hyprland.conf" "$active_dir/wallust/wallust-hyprland.conf"
  fi
}

if [[ $dry_run -eq 1 ]]; then
  echo "Would write: $env_file"
  echo "$new_line"
  echo "Would build: $active_dir"
  echo "Would write: $active_host_conf"
  echo "source = $repo_root/profiles/$profile.conf"
  echo "Would write: $legacy_host_conf"
  echo "source = $repo_root/profiles/$profile.conf"
  if [[ $do_symlink -eq 1 ]]; then
    echo "Would symlink: $HOME/.config/hypr -> $active_dir"
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

build_active_tree
echo "Built $active_dir"

write_host_conf "$legacy_host_conf"
echo "Wrote $legacy_host_conf"
echo "Wrote $active_host_conf"

if [[ $do_symlink -eq 1 ]]; then
  if [[ ! -d "$active_dir" ]]; then
    echo "Active directory not found: $active_dir" >&2
    exit 1
  fi

  hypr_dir="$HOME/.config/hypr"
  if [[ -L "$hypr_dir" ]]; then
    current_target="$(readlink -f "$hypr_dir" || true)"
    if [[ "$current_target" == "$active_dir" ]]; then
      echo "Symlink already points to $active_dir"
    elif [[ $force -ne 1 ]]; then
      echo "Refusing to repoint $hypr_dir without --force" >&2
      exit 1
    else
      rm "$hypr_dir"
      ln -s "$active_dir" "$hypr_dir"
      echo "Re-linked $hypr_dir -> $active_dir"
    fi
  elif [[ -e "$hypr_dir" && $force -ne 1 ]]; then
    echo "Refusing to overwrite $hypr_dir without --force" >&2
    exit 1
  else
    if [[ -e "$hypr_dir" ]]; then
      backup="${hypr_dir}.bak.$(date +%Y%m%d%H%M%S)"
      mv "$hypr_dir" "$backup"
      echo "Backed up $hypr_dir to $backup"
    fi
    ln -s "$active_dir" "$hypr_dir"
    echo "Linked $hypr_dir -> $active_dir"
  fi
fi
