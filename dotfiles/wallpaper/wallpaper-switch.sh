#!/usr/bin/env bash
# wallpaper-switch.sh - Toggle/Switch between static and live wallpapers
# Version: 1.0

set -euo pipefail

MODE="${1:-static}"

if [ "$MODE" = "live" ]; then
    pkill -x swww-daemon || true
    ~/dotfiles/wallpaper/wallpaper-live.sh "${2:-}"
else
    pkill -x mpvpaper || true
    ~/dotfiles/wallpaper/wallpaper-static.sh "${2:-}"
fi
