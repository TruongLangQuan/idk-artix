#!/usr/bin/env bash
# wallpaper-live.sh - Set dynamic video wallpaper with mpvpaper
# Version: 1.0

set -euo pipefail

VIDEO="${1:-$HOME/wallpapers/dynamic/default.mp4}"

if [ ! -f "$VIDEO" ]; then
    echo "[ERROR] Video wallpaper file not found: $VIDEO"
    exit 1
fi

pkill -x mpvpaper || true
mpvpaper '*' "$VIDEO" -o "no-audio --loop" &
