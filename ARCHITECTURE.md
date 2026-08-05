# ARCHITECTURE

Version: 1.0

Project: Artix Suckless Workstation

---

# 1. System Overview

The system is designed as a minimal Wayland workstation running on Artix Linux with OpenRC.

Architecture goals:

* Minimal background services.
* Direct user control.
* Low latency.
* Low resource usage.
* Easy debugging.
* Reproducible configuration.

High-level flow:

```
UEFI
 |
GRUB
 |
Linux Kernel
 |
OpenRC
 |
seatd + dbus
 |
DWL Wayland Compositor
 |
Applications
```

---

# 2. Boot Architecture

## Boot Flow

```
UEFI Firmware
      |
      v
GRUB
      |
      +----------------+
      |                |
 Linux Zen        Linux LTS
      |                |
      +----------------+
               |
               v
          initramfs
               |
               v
            OpenRC
               |
               v
        User Login (TTY)
               |
               v
             Bash
               |
               v
             dwl
```

---

# 3. Filesystem Architecture

Filesystem:

Btrfs

Layout:

```
/
├── @
├── @home
├── @cache
├── @log
├── @pkg
├── @tmp
└── @snapshots
```

---

## Subvolume Purpose

## @

Operating system files.

Contains:

* /usr
* /etc
* /var

---

## @home

User data.

Contains:

* Documents
* Projects
* Configurations

---

## @cache

Temporary cache.

Examples:

* Browser cache
* Build cache

---

## @log

System logs.

Separated to simplify maintenance.

---

## @pkg

Package manager cache.

---

## @tmp

Temporary files.

---

## @snapshots

Snapper snapshots.

---

# 4. Snapshot Architecture

Flow:

```
Package Update
      |
      v
Create Snapshot
      |
      v
Upgrade System
      |
      v
Validate
      |
      +------ Failure
      |
      v
Rollback
```

Components:

* Snapper
* grub-btrfs

---

# 5. Init System Architecture

OpenRC manages system services.

Startup order:

```
boot
 |
sysinit
 |
basic
 |
network
 |
default
 |
desktop
```

Required services:

```
dbus
seatd
NetworkManager
bluetooth
power-profiles-daemon
```

---

# 6. Wayland Stack

Complete stack:

```
Application

   |
   v

Wayland Protocol

   |
   v

wlroots

   |
   v

dwl

   |
   v

Linux DRM

   |
   v

Intel GPU
```

---

# 7. DWL Architecture

dwl responsibilities:

* Window management
* Input handling
* Workspace management
* Layout management
* Keyboard shortcuts

Configuration:

```
dwl source
    |
    v
config.h
    |
    v
compile
    |
    v
dwl binary
```

---

# 8. Workspace Architecture

Five workspaces:

```
1  2  3  4  5
```

Management:

Switch:

```
Super + 1-5
```

Move window:

```
Super + Shift + 1-5
```

Navigation:

```
Ctrl + Shift + Arrow
```

---

# 9. Status Architecture

slstatus runs independently.

Flow:

```
Hardware
 |
 |
 +-- RAM
 |
 +-- CPU
 |
 +-- Temperature
 |
 +-- Disk
 |
 +-- Network
 |
 v
slstatus
 |
 v
dwl bar
```

Optimization:

* Avoid unnecessary polling.
* Use reasonable update intervals.
* Fail gracefully.

---

# 10. Input Architecture

Keyboard stack:

```
Hardware Keyboard

      |
      v

libinput

      |
      v

Wayland

      |
      v

dwl

      |
      v

fcitx5

      |
      +------------+
                   |
              Vietnamese Telex
              US Keyboard
```

Toggle:

```
Super + Space
```

---

# 11. Terminal Architecture

```
Foot

 |
 v

Wayland

 |
 v

Bash

 |
 +----------------+
 |                |
Starship        Ble.sh
 |
 v
User Commands
```

---

# 12. Clipboard Architecture

```
Application

      |
      v

wl-copy

      |
      v

cliphist database

      |
      v

fuzzel selector

      |
      v

wl-paste
```

Shortcut:

```
Super + V
```

---

# 13. Wallpaper Architecture

Two modes.

---

## Static Wallpaper

```
Image

 |
 v

swww

 |
 v

Wayland Surface
```

---

## Dynamic Wallpaper

```
Video

 |
 v

mpv

 |
 v

mpvpaper

 |
 v

Wayland Background
```

Switching:

```
wallpaper-static

wallpaper-live

wallpaper-stop
```

---

# 14. Audio Architecture

```
Application

 |
 v

PipeWire

 |
 v

WirePlumber

 |
 +-------------+
               |
         Bluetooth
         Speakers
         Headphones
```

Control:

* pavucontrol
* pamixer
* playerctl

---

# 15. Graphics Architecture

Intel Graphics:

```
Application

 |
 v

Mesa

 |
 +-------------+
 |             |
OpenGL       Vulkan

 |
 v

Intel iGPU

 |
 v

DRM/i915
```

Video:

```
mpv

 |
 v

VAAPI

 |
 v

Intel Hardware Decoder
```

---

# 16. Development Architecture

Development workflow:

```
Foot

 |
 v

Neovim

 |
 +-------------+
 |             |
LSP          Git

 |
 v

Compiler

 |
 v

Binary
```

Supported:

* C/C++
* Rust
* Go
* Java
* Python
* JavaScript
* TypeScript
* Lua
* Zig

---

# 17. Security Architecture

```
Network

 |
 v

NetworkManager

 |
 v

UFW

 |
 v

Applications
```

Protection:

```
Fail2Ban

 |
 v

Block suspicious activity
```

---

# 18. Resource Management

Memory:

```
RAM
 |
 +-- Applications
 |
 +-- Cache
 |
 +-- zram
```

Storage:

```
NVMe

 |
 +-- Btrfs compression
 |
 +-- Snapshots
 |
 +-- Optimized mounts
```

---

# 19. Design Principles

The system follows:

```
Simple
  |
  v
Understandable
  |
  v
Maintainable
  |
  v
Reliable
```

Avoid:

* unnecessary layers
* hidden services
* complex automation
* dependency bloat

---

# 20. Final Architecture Goal

The final workstation should behave as:

```
Power User
      |
      v
Terminal
      |
      v
DWL
      |
      v
Minimal Linux System
      |
      v
Maximum Control
```

The system should remain understandable even years after installation.
