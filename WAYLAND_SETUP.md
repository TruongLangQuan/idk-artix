# WAYLAND SETUP GUIDE

Version: 1.0

Project: Artix Suckless Workstation

---

# 1. Overview

This document defines the complete Wayland stack.

Architecture:

```text
Applications

      |
      v

Wayland Protocol

      |
      v

dwl

      |
      v

wlroots

      |
      v

libinput + DRM

      |
      v

Linux Kernel

      |
      v

Intel GPU
```

---

# 2. Wayland Components

Required:

```text
wayland
wayland-protocols
wlroots
libinput
seatd
xorg-xwayland
```

Purpose:

| Component | Function                 |
| --------- | ------------------------ |
| Wayland   | Display protocol         |
| wlroots   | Compositor library       |
| dwl       | Window manager           |
| libinput  | Input handling           |
| seatd     | Device permissions       |
| XWayland  | Legacy X11 compatibility |

---

# 3. seatd Configuration

## Purpose

seatd provides access to:

* GPU
* Input devices
* DRM

Without requiring root privileges.

---

# Install

```bash
sudo pacman -S seatd
```

---

# Enable OpenRC Service

```bash
sudo rc-update add seatd default
```

Start:

```bash
sudo rc-service seatd start
```

---

# User Permissions

Add user:

```bash
sudo usermod -aG video,input,seat $USER
```

Logout and login again.

---

# Verify

```bash
loginctl seat-status seat0
```

or:

```bash
ls -l /dev/dri
```

Expected:

```text
card0
renderD128
```

---

# 4. libinput Configuration

libinput handles:

* Keyboard
* Touchpad
* Mouse
* Trackpad

---

# Test Devices

```bash
libinput list-devices
```

---

# Touchpad Options

Recommended:

* Tap-to-click enabled.
* Natural scrolling optional.
* Adaptive acceleration.

---

# 5. XWayland

Purpose:

Run older X11 applications.

Install:

```bash
sudo pacman -S xorg-xwayland
```

---

# Verify

Inside Wayland:

```bash
echo $XDG_SESSION_TYPE
```

Expected:

```text
wayland
```

---

# 6. Environment Variables

Create:

```text
~/.config/environment.d/wayland.conf
```

Example:

```bash
XDG_SESSION_TYPE=wayland

MOZ_ENABLE_WAYLAND=1

SDL_VIDEODRIVER=wayland

QT_QPA_PLATFORM=wayland
```

---

# 7. DWL Startup Pipeline

Startup order:

```text
TTY Login

 |
 v

Bash

 |
 v

dwl

 |
 +----------------+
 |                |
slstatus       wallpaper
 |
clipboard
 |
fcitx5
 |
audio services
```

---

# 8. Autostart Script

Location:

```text
~/.dwl/startup.sh
```

Example:

```bash
#!/usr/bin/env bash


# Status bar
slstatus &


# Clipboard history
wl-paste --type text --watch cliphist store &


# Wallpaper daemon
swww-daemon &


# Input method
fcitx5 -d &


# Notifications disabled intentionally
```

---

# 9. Application Launcher

## Fuzzel

Purpose:

* Application launcher.
* Clipboard selector.
* Script interface.

Install:

```bash
sudo pacman -S fuzzel
```

---

# Configuration

Location:

```text
~/.config/fuzzel/fuzzel.ini
```

Theme:

Monochrome.

Example:

```ini
[colors]

background=000000ff
text=ffffffff
selection=808080ff
border=ffffffff
```

---

# 10. Terminal

## Foot

Install:

```bash
sudo pacman -S foot
```

---

# Configuration

Location:

```text
~/.config/foot/foot.ini
```

Settings:

* JetBrains Mono
* Monocraft fallback
* Dark theme
* Low latency

---

Example:

```ini
font=JetBrains Mono:size=11

dpi-aware=yes

pad=8x8

[colors]

background=000000
foreground=ffffff
```

---

# 11. Clipboard System

Components:

```text
wl-clipboard
cliphist
fuzzel
```

Flow:

```text
Copy

 |
 v

wl-copy

 |
 v

cliphist

 |
 v

fuzzel

 |
 v

wl-paste
```

---

# Store Clipboard

Run:

```bash
wl-paste --watch cliphist store
```

---

# Restore Clipboard

Example:

```bash
cliphist list | fuzzel | cliphist decode | wl-copy
```

Shortcut:

```text
Super + V
```

---

# 12. Screenshot System

Components:

```text
grim
slurp
```

---

# Region Screenshot

Command:

```bash
grim -g "$(slurp)" ~/Pictures/screenshot.png
```

---

# Suggested Shortcut

```text
Print Screen
```

---

# 13. Screen Lock

Component:

```text
swaylock
```

Install:

```bash
sudo pacman -S swaylock
```

---

# Configuration

Location:

```text
~/.config/swaylock/config
```

Style:

* Black background.
* White text.
* No animation.

---

# Shortcut

```text
Super + L
```

---

# 14. Brightness Control

Component:

```text
brightnessctl
```

Install:

```bash
sudo pacman -S brightnessctl
```

---

# Commands

Increase:

```bash
brightnessctl set +10%
```

Decrease:

```bash
brightnessctl set 10%-
```

---

# Suggested Keys

```text
XF86MonBrightnessUp

XF86MonBrightnessDown
```

---

# 15. Input Method

## Fcitx5

Purpose:

Vietnamese Telex.

Install:

```bash
sudo pacman -S \
fcitx5 \
fcitx5-unikey \
fcitx5-configtool
```

---

# Environment

Add:

```bash
GTK_IM_MODULE=fcitx

QT_IM_MODULE=fcitx

XMODIFIERS=@im=fcitx
```

---

# Toggle

Shortcut:

```text
Super + Space
```

Layouts:

```text
US
Vietnamese Telex
```

---

# 16. Media Keys

Recommended:

```text
playerctl
pamixer
```

Functions:

Volume:

```text
XF86AudioRaiseVolume
XF86AudioLowerVolume
XF86AudioMute
```

Playback:

```text
Play/Pause
Next
Previous
```

---

# 17. Dynamic Wallpaper

## Static

Tool:

```text
swww
```

Command:

```bash
swww img wallpaper.png
```

---

## Dynamic

Tools:

```text
mpv
mpvpaper
```

Example:

```bash
mpvpaper '*' video.mp4
```

---

# 18. Notifications

Disabled intentionally.

Do not install:

```text
dunst
mako
swaync
```

Reason:

Reduce background processes.

---

# 19. Validation Checklist

## Core

* [ ] dwl starts
* [ ] seatd works
* [ ] keyboard works
* [ ] mouse works

## Applications

* [ ] foot opens
* [ ] fuzzel launches
* [ ] zen browser works

## Utilities

* [ ] Screenshot works
* [ ] Clipboard works
* [ ] Lock works
* [ ] Brightness works

## Input

* [ ] US keyboard works
* [ ] Vietnamese Telex works

---

# Final Goal

A complete minimal Wayland environment:

```text
Artix OpenRC

      +

seatd

      +

dwl

      +

Wayland tools

      +

Suckless workflow
```

No unnecessary desktop environment.

Maximum control with minimum resource usage.
