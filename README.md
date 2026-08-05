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

# Automation Scripts & Execution Order

All automation scripts are stored in `scripts/`. They can be run all at once using the master `bootstrap.sh` orchestrator or executed individually in the strict sequence below.

## Script Execution Sequence (Thứ tự thực thi script)

| Step | Script File | Purpose |
| --- | --- | --- |
| 1 | `scripts/install_packages.sh` | Installs system packages from `packages/*.txt` |
| 2 | `scripts/setup_btrfs.sh` | Configures Btrfs subvolumes, mounts & Snapper |
| 3 | `scripts/setup_openrc.sh` | Enables required OpenRC init services |
| 4 | `scripts/setup_hardware.sh` | Sets up Intel microcode, Mesa, Vulkan & VAAPI |
| 5 | `scripts/setup_network.sh` | Configures NetworkManager, seatd & user groups |
| 6 | `scripts/setup_audio.sh` | Configures PipeWire, WirePlumber & Bluetooth audio |
| 7 | `scripts/setup_security.sh` | Configures UFW firewall, Fail2Ban & sysctl rules |
| 8 | `scripts/build_dwl.sh` | Clones, patches & compiles dwl Wayland compositor |
| 9 | `scripts/build_slstatus.sh` | Clones & compiles slstatus bar with native C modules |
| 10 | `scripts/deploy_dotfiles.sh` | Backs up existing configs & symlinks `dotfiles/` |
| 11 | `scripts/optimize_system.sh` | Configures zram, NVMe trim, power profile & ccache |
| 12 | `scripts/healthcheck.sh` | Read-only diagnostic system health audit |

---

# Usage Instructions (Hướng dẫn sử dụng)

### 1. Automated Full Setup (Recommended)
Run all 12 stages sequentially with logging and checkpointing:

```bash
# Preview changes without modifying the system
./scripts/bootstrap.sh --dry-run

# Run full workstation installation
./scripts/bootstrap.sh
```

### 2. Manual Step-by-Step Execution
Run individual scripts in the exact sequence shown in the table above:

```bash
./scripts/install_packages.sh
./scripts/setup_btrfs.sh
./scripts/setup_openrc.sh
./scripts/setup_hardware.sh
./scripts/setup_network.sh
./scripts/setup_audio.sh
./scripts/setup_security.sh
./scripts/build_dwl.sh
./scripts/build_slstatus.sh
./scripts/deploy_dotfiles.sh
./scripts/optimize_system.sh
./scripts/healthcheck.sh
```

### 3. Universal Script Flags
Every script supports the following command-line flags:

* `--dry-run` or `-d`: Simulates execution and outputs planned actions without changing system state.
* `--help` or `-h`: Displays usage instructions, purpose, and safety warnings.

### 4. Resumability & Checkpoint System
Each completed stage creates a `.state/<stage>.done` marker. If a script is interrupted or re-run, completed stages are automatically skipped to guarantee idempotency and fast recovery.

### 5. Diagnostics & Logging
Logs for every execution are generated automatically in `logs/YYYY-MM-DD-<script_name>.log`. At any time, run the read-only healthcheck tool to verify system state:

```bash
./scripts/healthcheck.sh
```

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
