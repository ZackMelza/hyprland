-- Initial migration from ZackMelza/hyprland legacy JaKooLit .conf.
-- Generated for compatibility testing with Hyprland 0.57.
-- Keep original .conf files as the authoritative reference until verified.
hl.config({
  dwindle = { preserve_split = true },
  master = { new_status = "master", mfact = 0.5 },
  general = { resize_on_border = true, layout = "dwindle" },
  input = {
    kb_layout = "us,gr", kb_variant = "", kb_model = "", kb_options = "", kb_rules = "",
    repeat_rate = 50, repeat_delay = 300, sensitivity = 0,
    numlock_by_default = true, left_handed = false, follow_mouse = 1,
    float_switch_override_focus = false,
    touchpad = { disable_while_typing = true, natural_scroll = true,
      clickfinger_behavior = false, middle_button_emulation = false,
      tap_to_click = true, drag_lock = false },
    touchdevice = { enabled = true },
    tablet = { transform = 0, left_handed = false },
  },
  misc = {
    disable_hyprland_logo = true, disable_splash_rendering = true,
    vrr = 2, mouse_move_enables_dpms = true,
    enable_swallow = false, swallow_regex = "^(kitty)$",
    focus_on_activate = false, initial_workspace_tracking = 0,
    middle_click_paste = false, enable_anr_dialog = true,
    anr_missed_pings = 15, allow_session_lock_restore = true,
  },
  binds = {
    workspace_back_and_forth = true, allow_workspace_cycles = true,
    pass_mouse_when_bound = false,
  },
  xwayland = { enabled = true, force_zero_scaling = true },
  render = { direct_scanout = 0 },
  cursor = {
    sync_gsettings_theme = true, enable_hyprcursor = true,
    warp_on_change_workspace = 2, no_warps = true,
  },
})
-- Per-device DualSense and three-finger gestures are still under review.
