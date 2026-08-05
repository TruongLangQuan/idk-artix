# SPECIFICATION

Version: 1.0

---

# 1. Project Overview

This repository defines a complete, reproducible Artix Linux workstation built around the following principles:

* Simplicity
* Performance
* Stability
* Reproducibility
* Minimalism
* Documentation-first
* Terminal-first
* Wayland-native
* Suckless philosophy

The final result must be suitable for daily development and long-term maintenance.

---

# 2. Target Platform

Distribution

* Artix Linux
* OpenRC

Architecture

* x86_64

Firmware

* UEFI

Filesystem

* Btrfs

---

# 3. Target Hardware

CPU

Intel Core i5 11th Generation

GPU

Intel Integrated Graphics

RAM

16 GB

Storage

NVMe SSD

Networking

* Wi-Fi
* Bluetooth
* Ethernet

---

# 4. Kernel

Install both:

* linux-zen
* linux-lts

Requirements

* Both kernels must remain bootable.
* GRUB menu must always contain both entries.
* New kernel installation must never remove the other kernel.

---

# 5. Bootloader

GRUB

Requirements

* UEFI boot
* Btrfs support
* grub-btrfs integration
* Snapshot boot support
* Recovery entry
* Previous kernel fallback

---

# 6. Filesystem

Btrfs

Required subvolumes

@
@home
@cache
@log
@pkg
@tmp
@snapshots

Requirements

Compression enabled

No unnecessary CoW disable.

Swapfile configured correctly.

Snapshots supported.

---

# 7. Snapshot Strategy

Snapper

grub-btrfs

Automatic snapshots before

* System upgrade
* Kernel upgrade
* Driver changes

Retention policy

Daily

Weekly

Monthly

Cleanup automatically.

---

# 8. Desktop

Wayland only.

Window manager

dwl

Status bar

slstatus

Launcher

Fuzzel

Terminal

Foot

Lock screen

Swaylock

Clipboard

wl-clipboard

cliphist

Screenshot

grim

slurp

Wallpaper

swww

mpvpaper

Media player

mpv

VLC

---

# 9. Window Manager

Workspace count

Exactly five.

Layouts

Tile

Monocle

Floating

No additional layouts.

Community patches allowed only if

* Stable
* Small
* Widely used
* No significant performance impact

---

# 10. Status Bar

Display

Workspace

RAM used / total

Disk usage

CPU usage

CPU temperature

Network

Date

Time

Refresh interval

Optimized for minimal CPU usage.

---

# 11. Keyboard Shortcuts

Super

Open launcher

Super + T

Open terminal

Super + B

Open browser

Super + Q

Close focused window

Super + L

Lock screen

Super + Space

Toggle keyboard layout

Print

Screenshot

Super + 1..5

Switch workspace

Super + Shift + 1..5

Move window

Ctrl + Shift + Arrow

Navigate workspace

---

# 12. Input Method

fcitx5

Layouts

US

Vietnamese Telex

Default

US

Toggle

Super + Space

---

# 13. Shell

Bash

Features

Starship

Ble.sh

Bash completion

History synchronization

Persistent history

History timestamp

Reverse search

Autosuggestion

Custom aliases

Custom functions

---

# 14. Editor

Primary

Neovim

Configuration

Custom Lua configuration

No framework.

Secondary

Nano

---

# 15. Browser

Zen Browser

Requirements

Wayland enabled

Hardware acceleration

Privacy hardened

Performance optimized

---

# 16. Theme

Monochrome only.

Allowed colors

Black

Dark Grey

Grey

White

Forbidden

RGB themes

Transparency

Blur

Glass effects

---

# 17. Fonts

JetBrains Mono

Monocraft

Nerd Fonts

Font rendering optimized.

---

# 18. Audio

PipeWire

WirePlumber

pavucontrol

Requirements

Low latency

Stable Bluetooth audio

---

# 19. Networking

NetworkManager

BlueZ

seatd

Requirements

Automatic Wi-Fi

Automatic Ethernet priority

Bluetooth enabled

---

# 20. Security

UFW

Fail2Ban

Secure default configuration.

---

# 21. Performance Goals

Boot

Fast

Idle RAM

As low as reasonably achievable while maintaining functionality (typically around 300–500 MB on the target hardware, excluding normal kernel cache).

CPU

Near zero idle usage.

Storage

Optimized for NVMe.

Intel graphics

Hardware acceleration enabled.

---

# 22. Development Environment

Languages

C

C++

Rust

Go

Java

Python

JavaScript

TypeScript

Lua

Zig

Build tools

GCC

LLVM

Clang

CMake

Meson

Ninja

Make

Utilities

Git

LazyGit

tmux

ripgrep

fd

bat

jq

yq

fzf

zoxide

eza

btop

fastfetch

---

# 23. Scripts

Every script must be

Idempotent

Documented

Safe

Restartable

Logged

Error checked

---

# 24. Documentation

Every configuration must explain

Purpose

Reason

Trade-offs

Alternatives

---

# 25. AI Compatibility

Every decision must be deterministic.

Every package must have justification.

Every optimization must include rationale.

Every script must validate success.

Never introduce unnecessary complexity.

Never sacrifice maintainability for cleverness.

---

# 26. Out of Scope

Desktop environments

Display managers

Notification daemons

Heavy GUI utilities

Unnecessary background services

Unused dependencies

---

# 27. Success Criteria

A successful installation must provide

* Stable daily workstation
* Fast boot
* Low resource usage
* Fully documented configuration
* Reproducible installation
* Easy maintenance
* Consistent monochrome appearance
* Complete Wayland workflow
* Excellent developer experience
* Faithful adherence to the Suckless philosophy
