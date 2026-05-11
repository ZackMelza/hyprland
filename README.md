# Personal scripts and Hyprland profile repo

This repo keeps my local scripts and Hyprland dotfiles reproducible across
machines. The main project is `jakoolithyprl/`, a small profile layer around a
shared JaKooLit Hyprland configuration.

The goal is simple: keep the common config in one place, keep laptop/desktop
differences explicit, and make it obvious what is generated local state versus
what should be committed.

## Quick Start

```bash
# Preview what would change
./jakoolithyprl/set-hypr-profile.sh --symlink --dry-run

# Detect this machine and link ~/.config/hypr to the generated active tree
./jakoolithyprl/set-hypr-profile.sh --symlink

# Force a specific profile
./jakoolithyprl/set-hypr-profile.sh --profile laptop --symlink --force

# Reload Hyprland after config edits
hyprctl reload
hyprctl configerrors
```

## Project Map

`jakoolithyprl/common/`
: Shared Hyprland config, scripts, keybinds, user settings, animations, lock
screen config, and other files that should apply to every machine.

`jakoolithyprl/profiles/`
: Tiny profile selector files sourced by generated `Host.conf` files. These
decide what extra laptop-only or desktop-only config gets loaded.

`jakoolithyprl/laptop/` and `jakoolithyprl/desktop/`
: Machine-profile overrides. These should stay small and contain only real
profile differences, such as wallpaper rotation scripts or host templates.

`jakoolithyprl/active/`
: Generated working tree built by `set-hypr-profile.sh`. On this machine,
`~/.config/hypr` can be symlinked here. Do not edit this as the source of truth.

`PROJECT_JOURNAL.md`
: Human and LLM-friendly project memory: current status, completed changes,
known tasks, and version notes.

## How The Profile Setup Works

`jakoolithyprl/set-hypr-profile.sh` detects whether the machine is a laptop or
desktop, writes `HYPR_PROFILE` to:

```text
~/.config/environment.d/99-hypr.conf
```

It then builds `jakoolithyprl/active/` from symlinks to `common/`, adds the
selected profile, and can symlink:

```text
~/.config/hypr -> ~/projects/scripts/jakoolithyprl/active
```

Generated files such as `active/`, `Host.conf`, monitor/workspace overrides,
current wallpaper state, wallust output, and initial-startup markers are ignored
by git on purpose.

## Editing Rules

- Edit shared Hyprland behavior in `jakoolithyprl/common/`.
- Edit laptop/desktop differences only in the matching profile directory.
- Treat `jakoolithyprl/active/` as generated output.
- Run `hyprctl reload` and `hyprctl configerrors` after Hyprland config edits.
- Add noteworthy fixes, migrations, and open tasks to `PROJECT_JOURNAL.md`.

## Current Notes

- The current setup has been adjusted for Hyprland `0.55.x` compatibility.
- The PlayStation Link USB adapter is recognized as USB audio once the running
  kernel matches installed modules and `snd-usb-audio` is available.
