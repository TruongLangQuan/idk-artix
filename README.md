# Artix Suckless Workstation

> A reproducible, minimal, terminal-first, power-user workstation for Artix Linux (OpenRC).

## Overview

This project provides a complete and reproducible Artix Linux setup designed around the Suckless philosophy while remaining practical for daily software development.

The goal is **not** to build the smallest possible system, but to build a system that is:

* Fast
* Stable
* Lightweight
* Easy to maintain
* Easy to reproduce
* Developer-friendly
* Terminal-first
* Wayland-native

Every configuration, package selection, patch, optimization, and script has a clear purpose. Anything that does not improve usability, reliability, or performance is intentionally excluded.

---

# Design Goals

* Artix Linux (OpenRC)
* Wayland only
* dwl window manager
* slstatus status bar
* Foot terminal
* Bash shell
* Neovim
* Monochrome UI
* Intel hardware optimized
* Minimal RAM usage
* Low CPU usage
* Fast boot
* Reproducible installation
* Idempotent installation scripts
* Documentation-first

---

# Hardware Target

Primary development target:

* Intel Core i5 11th Generation
* Intel Integrated Graphics
* 16 GB RAM
* NVMe SSD
* UEFI
* Bluetooth
* Wi-Fi

The project should remain portable to other x86_64 systems whenever possible.

---

# Software Stack

## Operating System

* Artix Linux
* OpenRC
* Linux Zen
* Linux LTS

---

## Filesystem

Btrfs

Subvolumes

* @
* @home
* @cache
* @log
* @pkg
* @tmp
* @snapshots

Features

* Compression
* Snapper
* grub-btrfs
* zram
* swapfile

---

## Desktop

Wayland

* dwl
* slstatus
* foot
* fuzzel
* swaylock

Utilities

* grim
* slurp
* wl-clipboard
* cliphist
* brightnessctl

Wallpaper

* swww
* mpvpaper
* mpv

---

## Audio

* PipeWire
* WirePlumber
* pavucontrol

---

## Networking

* NetworkManager
* BlueZ
* seatd
* fcitx5
* Vietnamese Telex
* US Keyboard

---

## Security

* UFW
* Fail2Ban

---

## Development

Editors

* Neovim
* Nano

Languages

* C
* C++
* Rust
* Go
* Java
* Python
* JavaScript
* TypeScript
* Lua
* Zig

Toolchains

* GCC
* LLVM
* Clang
* Ninja
* Meson
* CMake
* Make

Utilities

* Git
* LazyGit
* tmux
* ripgrep
* fd
* bat
* eza
* jq
* yq
* zoxide
* fzf
* btop
* fastfetch

---

## Browser

Zen Browser

Configured for

* Privacy
* Performance
* Wayland
* Hardware acceleration

---

# UI Philosophy

Monochrome only.

Allowed colors:

* Black
* Dark Grey
* Grey
* White

No RGB themes.

No transparency.

No blur.

No unnecessary animations.

No desktop environment.

No display manager.

No notification daemon.

---

# Window Manager

dwl

Five fixed workspaces.

Default layouts

* Tile
* Monocle
* Floating

Patched only when:

* Stable
* Minimal
* Community-tested
* Low overhead

---

# Status Bar

slstatus

Displays

* Current workspace
* RAM usage
* Disk usage
* CPU usage
* CPU temperature
* Network status
* Date
* Time

Refresh intervals should be optimized to minimize CPU usage.

---

# Keyboard Shortcuts

| Shortcut             | Action                       |
| -------------------- | ---------------------------- |
| Super                | Open Fuzzel                  |
| Super + T            | Open Foot                    |
| Super + B            | Open Zen Browser             |
| Super + Q            | Close focused window         |
| Super + L            | Lock screen                  |
| Super + Space        | Toggle US ↔ Vietnamese Telex |
| Print                | Screenshot (grim + slurp)    |
| Super + 1..5         | Switch workspace             |
| Super + Shift + 1..5 | Move window to workspace     |
| Ctrl + Shift + Arrow | Navigate workspaces          |

---

# Repository Layout

```text
artix-suckless/

docs/
configs/
scripts/
patches/
packages/
assets/
fonts/
wallpapers/
benchmark/
healthcheck/
ai-agent/

README.md
LICENSE
SPEC.md
RULES.md
STYLE_GUIDE.md
TASKS.md
CHANGELOG.md
```

---

# Installation Philosophy

The installation must be:

* Idempotent
* Safe
* Restartable
* Logged
* Validated

Every major step must verify success before continuing.

---

# Performance Goals

Target idle usage

* RAM: approximately 300–500 MB (excluding normal kernel cache)
* CPU: near 0% when idle
* Fast boot
* Fast resume
* Low latency

---

# Documentation

Every configuration file must explain:

* Why it exists
* Why the selected values were chosen
* Alternative configurations
* Trade-offs

Nothing should be treated as "magic."

---

# AI Agent Compatibility

This repository is designed to be maintained by AI coding agents.

An AI agent must:

* Read SPEC.md before making changes.
* Follow RULES.md.
* Follow STYLE_GUIDE.md.
* Complete TASKS.md incrementally.
* Produce deterministic output.
* Keep scripts idempotent.
* Avoid unnecessary dependencies.
* Explain every non-trivial decision.
* Never sacrifice simplicity for unnecessary features.

---

# License

MIT License

---

# Project Status

Work in progress.

The long-term goal is to provide a complete, reproducible, minimal, and well-documented Artix Linux workstation suitable for both developers and advanced users while remaining faithful to the Suckless philosophy.
