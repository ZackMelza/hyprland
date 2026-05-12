# Project Journal

This file is the repo memory for both humans and LLMs. Keep it short, factual,
and easy to scan before making changes.

## Current Status

- Main focus: managed Hyprland profile setup in `jakoolithyprl/`.
- Source of truth: `jakoolithyprl/common/` plus small profile overrides.
- Generated runtime tree: `jakoolithyprl/active/`.
- Active machine can symlink `~/.config/hypr` to `jakoolithyprl/active/`.
- Current known Hyprland target: `0.55.x`.

## Done

### 2026-05-12

- Merged laptop-side guard work with local README, journal, and health-check
  changes.
- Preserved `GuardHyprConfig.sh` and `--install-guard` support from the laptop
  branch.
- Extended `check-hypr.sh` to report whether the guard script and managed
  `active/hyprland.conf` wrapper are in place.
- Fixed desktop login loop after guard/profile setup. Root cause: old generated
  `active/hyprland.conf` could still be a symlink to `common/hyprland.conf`;
  writing the generated wrapper followed the symlink and corrupted the shared
  config. `set-hypr-profile.sh` now removes stale generated symlinks before
  writing active files.
- Made `set-hypr-profile.sh` a one-command setup: auto-detect profile, build
  `active/`, link `~/.config/hypr`, install the guard, and back up replaced
  paths.
- Added generated fallback `wallust/wallust-hyprland.conf` so fresh desktop
  installs do not fail while sourcing decoration colors before wallust runs.
- Removed hardcoded checkout path from `profiles/laptop.conf`; generated
  wrappers now provide `$RepoRoot`.

### 2026-05-11

- Confirmed PlayStation Link USB adapter is recognized after rebooting into the
  installed kernel version.
- Confirmed `snd-usb-audio` binds to the adapter and ALSA lists it as
  `PlayStation Link Adapter`.
- Fixed Hyprland config errors caused by newer Hyprland syntax:
  - Changed dwindle split keybind to use `layoutmsg, togglesplit`.
  - Removed obsolete `dwindle:pseudotile`.
  - Removed obsolete `misc:vfr`.
- Reworked `README.md` into a clearer project overview.
- Added this journal for tasks, completed work, and version notes.
- Added `jakoolithyprl/check-hypr.sh` for quick profile and Hyprland config
  sanity checks.

## Open Tasks

- Review remaining JaKooLit config against current Hyprland docs after major
  Hyprland updates.
- Decide whether `PROJECT_JOURNAL.md` should grow into a changelog, or whether a
  separate `CHANGELOG.md` is worth adding later.
- Document any machine-specific audio routing steps if PlayStation Link needs
  PipeWire/WirePlumber profile tweaks.
- After pulling setup changes on another machine, run
  `./jakoolithyprl/set-hypr-profile.sh`.

## Version Notes

- Hyprland `0.55.x`: some older JaKooLit config keys and dispatchers are no
  longer accepted. Prefer checking `hyprctl configerrors` immediately after
  updates.
- Arch kernel updates: if modules appear missing after `pacman -Syu`, reboot
  before debugging hardware drivers. The running kernel must match
  `/lib/modules/<kernel-version>`.

## LLM Notes

- Do not edit `jakoolithyprl/active/` as the source of truth.
- Prefer changes in `jakoolithyprl/common/` unless the behavior is genuinely
  laptop-only or desktop-only.
- Preserve ignored local state. Do not add generated monitor, workspace,
  wallpaper, wallust, or initial-startup files unless the ignore rules change
  intentionally.
- Before changing setup behavior, inspect `jakoolithyprl/set-hypr-profile.sh`
  and `.gitignore` together.
- After guard-related changes, run `./jakoolithyprl/check-hypr.sh`; a warning
  about `active/hyprland.conf` being a symlink means the active tree needs a
  rebuild with `set-hypr-profile.sh`.
- Generated active files must be unlinked before writing them; otherwise a stale
  symlink can redirect writes into source-controlled `common/` files.
