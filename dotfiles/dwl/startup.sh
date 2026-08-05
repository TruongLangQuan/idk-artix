#!/usr/bin/env bash
# ~/.dwl/startup.sh - dwl Autostart Script
# Version: 1.0

set -euo pipefail

# Start Status Bar
if ! pgrep -x slstatus >/dev/null; then
    slstatus &
fi

# Start Clipboard History Storage
if ! pgrep -x cliphist >/dev/null; then
    wl-paste --type text --watch cliphist store &
    wl-paste --type image --watch cliphist store &
fi

# Start Wallpaper Daemon
if ! pgrep -x swww-daemon >/dev/null; then
    swww-daemon &
fi

# Start Input Method Daemon
if ! pgrep -x fcitx5 >/dev/null; then
    fcitx5 -d &
fi

# Start PipeWire & WirePlumber if not managed by OpenRC user session
if ! pgrep -x pipewire >/dev/null; then
    pipewire &
fi
if ! pgrep -x wireplumber >/dev/null; then
    wireplumber &
fi
