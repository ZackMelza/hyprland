# This is my reposetory for personal scripts that I will be adding over time

## Hyprland profile helper

`jakoolithyprl/set-hypr-profile.sh` detects whether the machine is a laptop or
desktop and writes `HYPR_PROFILE` to `~/.config/environment.d/99-hypr.conf`.
It also rewrites `UserConfigs/Host.conf` to point at the active profile and can
symlink `~/.config/hypr` to the selected profile in this repo.

Examples:

```bash
# Preview changes without writing files
./jakoolithyprl/set-hypr-profile.sh --symlink --dry-run

# Apply changes and link ~/.config/hypr to the detected profile
./jakoolithyprl/set-hypr-profile.sh --symlink

# Force a profile (overwrites existing config if needed)
./jakoolithyprl/set-hypr-profile.sh --profile laptop --symlink --force
```
