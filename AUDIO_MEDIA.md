# AUDIO MEDIA GUIDE

Version: 1.0

Project: Artix Suckless Workstation

---

# 1. Overview

Media stack:

```text id="7y8z6k"
Applications

      |
      v

PipeWire

      |
      +----------------+
      |                |
WirePlumber      PulseAudio API

      |
      v

ALSA

      |
      v

Hardware
```

---

# 2. Design Goals

Requirements:

* Low latency.
* Low CPU usage.
* Bluetooth support.
* Desktop compatibility.
* Hardware acceleration.

Avoid:

* PulseAudio daemon.
* Heavy audio managers.
* Unnecessary GUI tools.

---

# 3. Install Audio Packages

Install:

```bash id="1g3n9x"
sudo pacman -S \
pipewire \
pipewire-audio \
pipewire-pulse \
wireplumber \
pipewire-alsa \
alsa-utils
```

---

# 4. Enable PipeWire

User services:

```bash id="9h7v2k"
systemctl --user enable --now pipewire

systemctl --user enable --now pipewire-pulse

systemctl --user enable --now wireplumber
```

Note:

On Artix OpenRC, user services are handled differently depending on setup.

Recommended:

Start through user session:

```bash id="x5m8q1"
~/.dwl/startup.sh
```

---

# 5. Verify PipeWire

Check:

```bash id="r8q3m5"
wpctl status
```

Expected:

```text id="p4s8k0"
Audio
 ├── Sink
 ├── Source
 └── Bluetooth Device
```

---

# 6. ALSA Configuration

Install tools:

```bash id="6v0k2w"
sudo pacman -S alsa-utils
```

Test:

```bash id="q1z8m4"
speaker-test
```

Mixer:

```bash id="7j5p3n"
alsamixer
```

---

# 7. pavucontrol

Purpose:

Graphical audio controller.

Install:

```bash id="h9m3c7"
sudo pacman -S pavucontrol
```

Features:

* Output selection.
* Input selection.
* Application volume.
* Bluetooth switching.

Launch:

```bash
pavucontrol
```

---

# 8. Bluetooth Audio

Packages:

```bash id="3s7k1p"
sudo pacman -S \
bluez \
bluez-utils \
pipewire-pulse
```

---

Enable OpenRC:

```bash id="5k9n2x"
sudo rc-update add bluetooth default
```

Start:

```bash id="8q4m6v"
sudo rc-service bluetooth start
```

---

# 9. Bluetooth Management

Install:

```bash id="2m7x9a"
sudo pacman -S bluez-utils
```

Open:

```bash id="9q1w5e"
bluetoothctl
```

Commands:

```text id="n4v8z2"
power on

agent on

scan on

pair MAC

connect MAC

trust MAC
```

---

# 10. PipeWire Bluetooth Codecs

Recommended:

```text id="w3k8p6"
SBC

AAC

LDAC (optional)
```

Avoid unnecessary codecs.

Reason:

More codecs:

* More CPU.
* More complexity.

---

# 11. Volume Control Shortcuts

Use:

```text id="6d9q3k"
pamixer
```

Install:

```bash
sudo pacman -S pamixer
```

---

Commands:

Increase:

```bash
pamixer -i 5
```

Decrease:

```bash
pamixer -d 5
```

Mute:

```bash
pamixer -t
```

---

# 12. Media Keys

dwl bindings:

```text id="z6x1n8"
XF86AudioRaiseVolume

XF86AudioLowerVolume

XF86AudioMute
```

---

# 13. Player Control

Install:

```bash
sudo pacman -S playerctl
```

Commands:

Play:

```bash
playerctl play-pause
```

Next:

```bash
playerctl next
```

Previous:

```bash
playerctl previous
```

---

# 14. mpv Configuration

Install:

```bash
sudo pacman -S mpv
```

---

Config:

```text id="4r8n2k"
~/.config/mpv/mpv.conf
```

---

# 15. Intel Hardware Acceleration

Intel iGPU:

Enable VAAPI.

Install:

```bash
sudo pacman -S \
intel-media-driver \
libva-utils
```

---

Test:

```bash
vainfo
```

---

mpv:

```conf id="9s3k7m"
hwdec=vaapi

vo=gpu

gpu-api=vulkan
```

---

# 16. mpv Performance

Recommended:

```conf id="2f8w6j"
cache=yes

demuxer-max-bytes=150MiB

video-sync=display-resample
```

---

# 17. VLC

Install:

```bash
sudo pacman -S vlc
```

---

Enable:

Settings:

```text id="1x6z8p"
Input/Codecs

Hardware acceleration:
VA-API
```

---

# 18. mpvpaper

Purpose:

Video wallpaper.

Install:

Build from source if unavailable.

Dependencies:

```bash
sudo pacman -S mpv
```

---

Usage:

Example:

```bash
mpvpaper '*' video.mp4
```

---

# 19. Static Wallpaper

Tool:

```text id="7z2m5q"
swww
```

Install:

```bash
sudo pacman -S swww
```

---

Start:

```bash
swww-daemon &
```

Set:

```bash
swww img ~/Pictures/wallpaper.png
```

---

# 20. Wallpaper Switching

Script:

```text id="0p9x4v"
~/.config/swww/wallpaper.sh
```

Logic:

```text
if image:
    use swww

if video:
    use mpvpaper
```

---

# 21. Hardware Acceleration Check

GPU:

```bash
glxinfo | grep renderer
```

Video:

```bash
vainfo
```

Audio:

```bash
wpctl status
```

---

# 22. Resource Optimization

Disable:

* Desktop sound effects.
* Audio visualizers.
* Background media services.

Keep:

* PipeWire.
* WirePlumber.
* Bluetooth only when needed.

---

# 23. Debugging

PipeWire:

```bash
pw-top
```

Devices:

```bash
wpctl status
```

Logs:

```bash
journalctl --user -u wireplumber
```

---

# 24. Startup Integration

Add:

```bash
#!/usr/bin/env bash

pipewire &
wireplumber &

swww-daemon &
```

Do not start duplicate instances.

---

# 25. Final Media Stack

Result:

```text id="q9h3k7"
Artix OpenRC

       +

dwl Wayland

       +

PipeWire

       +

Bluetooth

       +

VAAPI Intel

       +

mpv/VLC

       +

swww/mpvpaper
```

---

# Completion Checklist

Audio:

* [ ] PipeWire working
* [ ] pavucontrol working
* [ ] Bluetooth audio working
* [ ] Volume keys working

Video:

* [ ] mpv hardware acceleration
* [ ] VLC VAAPI
* [ ] Static wallpaper
* [ ] Dynamic wallpaper

Performance:

* [ ] Low CPU usage
* [ ] No unnecessary daemons
