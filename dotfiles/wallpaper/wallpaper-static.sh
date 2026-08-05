#!/usr/bin/env bash
# wallpaper-static.sh - Set static wallpaper with swww
# Version: 1.0

set -euo pipefail

WALLPAPER="${1:-$HOME/wallpapers/static/default.png}"

if [ ! -f "$WALLPAPER" ]; then
    echo "[ERROR] Wallpaper file not found: $WALLPAPER"
    exit 1
fi

if ! pgrep -x swww-daemon >/dev/null; then
    swww-daemon &
    sleep 1
fi

swww img "$WALLPAPER" --transition-type fade --transition-step 90
