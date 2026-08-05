# FINAL CHECKLIST

Version: 1.0

Project: Artix Suckless Workstation

---

# 1. Hardware Verification

## CPU

Target:

```text id="x9wq3m"
Intel Core i5 Gen 11
```

Check:

```bash
lscpu
```

Verify:

* [ ] CPU detected correctly
* [ ] Microcode loaded

Check:

```bash
dmesg | grep microcode
```

---

## GPU

Target:

```text id="9y7n2k"
Intel Integrated Graphics
```

Check:

```bash
lspci | grep VGA
```

Verify:

* [ ] Mesa installed
* [ ] Vulkan working
* [ ] VAAPI working

Commands:

```bash
glxinfo | grep renderer

vainfo
```

---

## Memory

Target:

```text id="7m3x8v"
16GB RAM
```

Check:

```bash
free -h
```

Verify:

* [ ] Correct RAM amount
* [ ] zram active

---

## Storage

Target:

```text id="1k5m8a"
2TB NVMe SSD
```

Check:

```bash
lsblk
```

Verify:

* [ ] EFI partition
* [ ] Btrfs root
* [ ] Correct subvolumes

---

# 2. Boot System

## UEFI

Check:

```bash
ls /sys/firmware/efi
```

Verify:

* [ ] UEFI boot enabled

---

## Bootloader

Check:

```bash
grub-install --version
```

Verify:

* [ ] GRUB installed
* [ ] Kernel entries exist

---

# 3. Filesystem

## Btrfs

Check:

```bash
btrfs filesystem show
```

Verify:

* [ ] Compression enabled
* [ ] Subvolumes mounted

---

Subvolume list:

```bash
btrfs subvolume list /
```

Expected:

```text id="5gq4m8"
@
@home
@cache
@log
@snapshots
```

---

## TRIM

Check:

```bash
sudo fstrim -av
```

Verify:

* [ ] NVMe trim working

---

# 4. OpenRC

Check:

```bash
rc-status
```

Required services:

```text id="8z3q1n"
dbus

seatd

NetworkManager

bluetooth

power-profiles-daemon
```

Verify:

* [ ] All running
* [ ] No unnecessary services

---

# 5. Network

## NetworkManager

Check:

```bash
nmcli device
```

Verify:

* [ ] Wi-Fi works
* [ ] Ethernet works

---

# 6. Bluetooth

Check:

```bash
bluetoothctl
```

Verify:

* [ ] Adapter detected
* [ ] Devices can pair
* [ ] Audio works

---

# 7. Audio

## PipeWire

Check:

```bash
wpctl status
```

Verify:

* [ ] PipeWire running
* [ ] WirePlumber running

---

## pavucontrol

Check:

```bash
pavucontrol
```

Verify:

* [ ] Output selection works
* [ ] Input works

---

# 8. Wayland Environment

## Session

Check:

```bash
echo $XDG_SESSION_TYPE
```

Expected:

```text
wayland
```

---

# 9. seatd

Check:

```bash
ls -l /dev/dri
```

Verify:

* [ ] User can access GPU
* [ ] No root required

---

# 10. dwl

Verify:

* [ ] dwl starts
* [ ] Windows open
* [ ] Keyboard works
* [ ] Mouse works

---

# 11. Keybindings

Required:

## Applications

| Shortcut  | Function          |
| --------- | ----------------- |
| Super + Q | Close application |
| Super + T | Terminal          |
| Super     | Fuzzel            |
| Super + B | Zen Browser       |

---

## Workspace

Verify:

```text id="5q1z9f"
Workspace 1-5
```

Keys:

```text
Ctrl + Shift + Arrow
```

---

## Input

Verify:

```text id="3x7a5b"
Super + Space
```

Switch:

```text
US

Vietnamese Telex
```

---

# 12. Applications

## Terminal

Foot:

```bash
foot
```

Verify:

* [ ] JetBrains Mono
* [ ] Monochrome theme

---

## Browser

Zen:

Verify:

* [ ] Wayland mode
* [ ] Hardware acceleration

---

## File Manager

Superfile:

Check:

```bash
superfile
```

---

## Editor

Neovim:

```bash
nvim
```

Verify:

* [ ] Plugins load
* [ ] LSP works

---

Nano:

```bash
nano
```

Verify:

* [ ] Syntax highlighting

---

# 13. Clipboard

Check:

```bash
cliphist list
```

Verify:

* [ ] Copy works
* [ ] History works
* [ ] Paste works

---

# 14. Screenshot

Check:

```bash
grim -g "$(slurp)"
```

Verify:

* [ ] Region selection works
* [ ] Image saved

---

# 15. Lock Screen

Check:

```bash
swaylock
```

Verify:

* [ ] Locks screen
* [ ] Unlock works

---

# 16. Wallpaper

Static:

```bash
swww img wallpaper.png
```

Verify:

* [ ] Image wallpaper works

---

Dynamic:

```bash
mpvpaper '*' video.mp4
```

Verify:

* [ ] Video wallpaper works

---

# 17. Status Bar

slstatus:

Verify:

Displayed:

```text
Workspace

RAM used/total

Disk %

CPU %

Temperature

Network

Date/time
```

---

# 18. Security

## Firewall

Check:

```bash
sudo ufw status
```

Verify:

* [ ] Enabled
* [ ] Incoming denied

---

## Fail2Ban

Check:

```bash
fail2ban-client status
```

Verify:

* [ ] Running

---

# 19. Performance

## Idle RAM

Check:

```bash
free -h
```

Target:

```text
< 1.5GB
```

---

## CPU Idle

Check:

```bash
btop
```

Target:

```text
< 2%
```

---

## Temperature

Check:

```bash
sensors
```

Verify:

* [ ] Normal temperature

---

# 20. Development Tools

Verify:

## Git

```bash
git --version
```

---

## LazyGit

```bash
lazygit
```

---

## Compilers

```bash
gcc --version

python --version

node --version

rustc --version
```

---

# 21. Backup

Verify:

* [ ] Dotfiles backed up
* [ ] Btrfs snapshots available
* [ ] Important data stored safely

---

# 22. Daily Workflow Test

Simulate normal usage:

## Boot

* [ ] Login
* [ ] dwl starts

## Work

* [ ] Open terminal
* [ ] Code in Neovim
* [ ] Git commit
* [ ] Browse web
* [ ] Play media

## Power

* [ ] Suspend/resume
* [ ] Bluetooth reconnect
* [ ] Wi-Fi reconnect

---

# 23. Final System State

Expected:

```text
Artix Linux

+

OpenRC

+

Btrfs

+

dwl

+

slstatus

+

Wayland

+

PipeWire

+

Minimal Services

+

Security

+

Development Environment
```

---

# Completion Status

When every checkbox passes:

```text
SYSTEM READY
```

The machine is ready for daily use.
