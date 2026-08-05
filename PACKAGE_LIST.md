# PACKAGE LIST

Version: 1.0

Project: Artix Suckless Workstation

---

# Package Philosophy

Package selection follows these rules:

Priority:

1. Required functionality
2. Stability
3. Performance
4. Maintainability
5. Convenience

Avoid:

* Duplicate tools
* Heavy GUI replacements
* Unused services
* Background daemons

---

# 1. Base System

## Required

```text
base
base-devel
linux-zen
linux-lts
linux-firmware
intel-ucode
```

Purpose:

* Core system
* Kernel
* Firmware
* Intel CPU microcode

---

# 2. Bootloader

```text
grub
efibootmgr
os-prober
btrfs-progs
grub-btrfs
```

Purpose:

* UEFI boot
* Btrfs integration
* Snapshot boot

---

# 3. Filesystem

```text
btrfs-progs
snapper
snap-pac
zram-generator
```

Purpose:

* Btrfs management
* Snapshots
* Compression
* Memory optimization

---

# 4. OpenRC

```text
openrc
openrc-base
elogind
dbus
```

Purpose:

* Init system
* Session management
* IPC

---

# 5. Hardware

## Intel Graphics

```text
mesa
lib32-mesa
vulkan-intel
intel-media-driver
libva
libva-utils
```

Purpose:

* OpenGL
* Vulkan
* Hardware video decoding

---

## Sensors

```text
lm_sensors
smartmontools
nvme-cli
```

Purpose:

* Temperature
* SSD health
* Hardware monitoring

---

# 6. Wayland

```text
wayland
wayland-protocols
wlroots
libinput
seatd
xorg-xwayland
```

Purpose:

* Wayland environment
* Input handling
* Hardware access

---

# 7. Window Manager

## Build From Source

```text
dwl
slstatus
```

Reason:

Suckless software is configured through source.

---

Required build tools:

```text
git
make
gcc
pkgconf
wayland
wayland-protocols
wlroots
libinput
pixman
cairo
pango
```

---

# 8. Terminal

```text
foot
bash
bash-completion
```

Purpose:

* Terminal
* Shell
* Completion

---

# 9. Launcher

```text
fuzzel
```

Purpose:

* Application launcher
* Clipboard integration
* Scripts

---

# 10. Lock Screen

```text
swaylock
```

Purpose:

* Wayland screen locking

---

# 11. Screenshot

```text
grim
slurp
```

Purpose:

* Screenshot selection
* Region capture

---

# 12. Clipboard

```text
wl-clipboard
cliphist
```

Purpose:

* Wayland clipboard
* Clipboard history

---

# 13. Brightness

```text
brightnessctl
```

Purpose:

* Laptop brightness control

---

# 14. Wallpaper

## Static

```text
swww
```

## Dynamic

```text
mpv
mpvpaper
```

Purpose:

* Image wallpaper
* Video wallpaper

---

# 15. Audio

```text
pipewire
pipewire-pulse
wireplumber
pavucontrol
alsa-utils
```

Purpose:

* Modern Linux audio
* Bluetooth audio
* GUI mixer

---

# 16. Bluetooth

```text
bluez
bluez-utils
```

Service:

```text
bluetooth
```

Purpose:

* Wireless devices
* Audio devices

---

# 17. Network

```text
networkmanager
network-manager-applet
```

Purpose:

* Wi-Fi
* Ethernet
* VPN support

---

# 18. Input Method

```text
fcitx5
fcitx5-unikey
fcitx5-configtool
```

Purpose:

* Vietnamese Telex
* Keyboard switching

---

# 19. Browser

```text
zen-browser
```

Configuration:

* Wayland
* Hardware acceleration
* Privacy settings

---

# 20. Editors

```text
neovim
nano
```

Purpose:

Primary:

Neovim

Emergency:

Nano

---

# 21. Development Tools

## Compiler

```text
gcc
clang
llvm
lldb
gdb
```

---

## Build Systems

```text
make
cmake
meson
ninja
pkgconf
```

---

## Languages

```text
python
python-pip
rust
cargo
go
jdk-openjdk
nodejs
npm
zig
lua
```

---

# 22. Git

```text
git
lazygit
openssh
```

Purpose:

* Version control
* Repository management
* SSH

---

# 23. CLI Utilities

```text
ripgrep
fd
bat
eza
fzf
zoxide
jq
yq
tree
file
less
rsync
tmux
htop
btop
fastfetch
```

Purpose:

Modern terminal workflow.

---

# 24. Archive Support

```text
zip
unzip
p7zip
tar
gzip
xz
zstd
```

---

# 25. Security

```text
ufw
fail2ban
sudo
polkit
```

Purpose:

* Firewall
* Attack protection
* Privilege management

---

# 26. Power Management

```text
power-profiles-daemon
tlp
powertop
```

Note:

Only one power manager should actively control hardware.

Recommended:

power-profiles-daemon

---

# 27. Fonts

```text
ttf-jetbrains-mono
nerd-fonts
```

Additional:

```text
Monocraft
```

Installed manually if unavailable.

---

# 28. Media

```text
mpv
vlc
playerctl
pamixer
```

---

# 29. Optional Tools

## File Manager

```text
superfile
```

---

## Monitoring

```text
iotop
iftop
nvtop
```

---

## Documentation

```text
man-db
man-pages
texinfo
```

---

# 30. Build From Source

Allowed:

```text
dwl
slstatus
superfile (if required)
```

Reason:

* Customization
* Latest version
* Patch support

---

# 31. Packages Explicitly Avoided

Do not install:

```text
KDE Plasma
GNOME
XFCE
Cinnamon
LightDM
GDM
SDDM
systemd
PulseAudio
Conky
Compositors
Notification daemons
```

Reason:

Unnecessary resource usage or architecture conflict.

---

# 32. Package Validation

Before adding a package:

Check:

* Is it required?
* Is it maintained?
* Does it add a daemon?
* Does it duplicate existing functionality?
* Does it increase boot time?

---

# Final Package Goal

The final installation should provide:

* Complete Wayland desktop
* Professional development environment
* Strong security
* Full multimedia support
* Minimal background processes
* Low memory footprint
* Easy maintenance
