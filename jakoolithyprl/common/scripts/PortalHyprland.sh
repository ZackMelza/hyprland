#!/usr/bin/env bash
# /* ---- 💫 https://github.com/JaKooLit 💫 ---- */  ##
# For manually starting xdg-desktop-portal-hyprland

sleep 1
killall xdg-desktop-portal-hyprland 2>/dev/null || true
killall xdg-desktop-portal-wlr 2>/dev/null || true
killall xdg-desktop-portal-gnome 2>/dev/null || true
killall xdg-desktop-portal 2>/dev/null || true
sleep 1
if [[ -x /usr/lib/xdg-desktop-portal-hyprland ]]; then
  /usr/lib/xdg-desktop-portal-hyprland &
elif [[ -x /usr/libexec/xdg-desktop-portal-hyprland ]]; then
  /usr/libexec/xdg-desktop-portal-hyprland &
fi
sleep 2
if [[ -x /usr/lib/xdg-desktop-portal ]]; then
  /usr/lib/xdg-desktop-portal &
elif [[ -x /usr/libexec/xdg-desktop-portal ]]; then
  /usr/libexec/xdg-desktop-portal &
fi
