# INSTALLATION GUIDE

Version: 1.0

Project: Artix Suckless Workstation

---

# 1. Installation Overview

Installation flow:

```text
Live ISO
   |
   v
Network Setup
   |
   v
Disk Partition
   |
   v
Btrfs Setup
   |
   v
Base System
   |
   v
Kernel Installation
   |
   v
OpenRC Configuration
   |
   v
GRUB Installation
   |
   v
User Setup
   |
   v
Desktop Stack
   |
   v
DWL Environment
   |
   v
Optimization
```

---

# 2. Pre-installation Checklist

Before installation:

## Hardware

Verify:

```bash
lscpu
lspci
lsblk
```

Expected:

* Intel CPU
* NVMe storage
* UEFI firmware

---

## Backup

Before modifying disks:

Backup:

* Documents
* SSH keys
* Projects
* Browser data

Never continue without backup.

---

# 3. Boot Live Environment

Boot Artix Linux ISO.

Verify UEFI mode:

```bash
ls /sys/firmware/efi
```

Expected:

```text
EFI
```

If empty:

You booted Legacy mode.

---

# 4. Network Setup

## Ethernet

Usually automatic.

Test:

```bash
ping -c 3 archlinux.org
```

---

## Wi-Fi

Start iwd:

```bash
iwctl
```

Example:

```bash
device list

station wlan0 scan

station wlan0 get-networks

station wlan0 connect SSID
```

Test:

```bash
ping -c 3 google.com
```

---

# 5. Disk Layout

Target:

2TB NVMe SSD

Recommended:

```text
/dev/nvme0n1

├── p1
│   EFI System Partition
│   1GB
│   FAT32
│
└── p2
    Btrfs
    Remaining space
```

---

# 6. Partition Disk

Example:

```bash
cfdisk /dev/nvme0n1
```

Create:

EFI:

```
Type:
EFI System
Size:
1G
```

Root:

```
Type:
Linux filesystem
Size:
Remaining
```

Write changes.

---

# 7. Format Partitions

EFI:

```bash
mkfs.fat -F32 /dev/nvme0n1p1
```

Btrfs:

```bash
mkfs.btrfs -f /dev/nvme0n1p2
```

---

# 8. Create Btrfs Subvolumes

Mount temporary:

```bash
mount /dev/nvme0n1p2 /mnt
```

Create:

```bash
btrfs subvolume create /mnt/@

btrfs subvolume create /mnt/@home

btrfs subvolume create /mnt/@cache

btrfs subvolume create /mnt/@log

btrfs subvolume create /mnt/@pkg

btrfs subvolume create /mnt/@tmp

btrfs subvolume create /mnt/@snapshots
```

Unmount:

```bash
umount /mnt
```

---

# 9. Mount System

Root:

```bash
mount -o noatime,compress=zstd,subvol=@ \
/dev/nvme0n1p2 /mnt
```

Create directories:

```bash
mkdir -p /mnt/{home,var/cache,var/log,var/pkg,tmp,.snapshots,boot/efi}
```

Mount others:

```bash
mount -o noatime,compress=zstd,subvol=@home \
/dev/nvme0n1p2 /mnt/home


mount -o noatime,compress=zstd,subvol=@cache \
/dev/nvme0n1p2 /mnt/var/cache


mount -o noatime,compress=zstd,subvol=@log \
/dev/nvme0n1p2 /mnt/var/log


mount -o noatime,compress=zstd,subvol=@snapshots \
/dev/nvme0n1p2 /mnt/.snapshots
```

EFI:

```bash
mount /dev/nvme0n1p1 /mnt/boot/efi
```

---

# 10. Install Base System

Install base:

```bash
basestrap /mnt base base-devel openrc elogind linux-firmware
```

Install kernels:

```bash
basestrap /mnt linux-zen linux-lts
```

Install firmware:

```bash
basestrap /mnt intel-ucode
```

---

# 11. Generate Fstab

```bash
fstabgen -U /mnt >> /mnt/etc/fstab
```

Review:

```bash
nano /mnt/etc/fstab
```

Verify:

* UUID correct
* Btrfs options correct

---

# 12. Enter System

```bash
artix-chroot /mnt
```

---

# 13. Timezone

```bash
ln -sf \
/usr/share/zoneinfo/Asia/Ho_Chi_Minh \
/etc/localtime
```

Hardware clock:

```bash
hwclock --systohc
```

---

# 14. Locale

Edit:

```bash
nano /etc/locale.gen
```

Enable:

```text
en_US.UTF-8 UTF-8
vi_VN.UTF-8 UTF-8
```

Generate:

```bash
locale-gen
```

Create:

```bash
echo "LANG=en_US.UTF-8" > /etc/locale.conf
```

---

# 15. Hostname

Example:

```bash
echo "artix-suckless" > /etc/hostname
```

Hosts:

```bash
nano /etc/hosts
```

Add:

```text
127.0.0.1 localhost
::1 localhost
127.0.1.1 artix-suckless.localdomain artix-suckless
```

---

# 16. Root Password

```bash
passwd
```

---

# 17. Install Essential Packages

```bash
pacman -S \
grub \
efibootmgr \
networkmanager \
bluez \
bluez-utils \
seatd \
dbus \
sudo
```

---

# 18. Enable OpenRC Services

Network:

```bash
rc-update add NetworkManager default
```

Bluetooth:

```bash
rc-update add bluetooth default
```

DBus:

```bash
rc-update add dbus default
```

Seatd:

```bash
rc-update add seatd default
```

---

# 19. Install GRUB

```bash
grub-install \
--target=x86_64-efi \
--efi-directory=/boot/efi \
--bootloader-id=Artix
```

Generate config:

```bash
grub-mkconfig -o /boot/grub/grub.cfg
```

---

# 20. Create User

Install sudo:

```bash
pacman -S sudo
```

Create:

```bash
useradd -m -G wheel,audio,video,input tlquan
```

Password:

```bash
passwd tlquan
```

Enable sudo:

```bash
EDITOR=nano visudo
```

Uncomment:

```text
%wheel ALL=(ALL:ALL) ALL
```

---

# 21. Enable Seat Access

Add user:

```bash
usermod -aG seat tlquan
```

---

# 22. Exit Installation

```bash
exit
```

Unmount:

```bash
umount -R /mnt
```

Reboot:

```bash
reboot
```

Remove USB.

---

# 23. First Boot Checklist

Verify:

## Kernel

```bash
uname -r
```

---

## OpenRC

```bash
rc-status
```

---

## Network

```bash
nmcli device
```

---

## Disk

```bash
lsblk
```

---

# Installation Completed

Next steps:

1. Install Wayland stack.
2. Build dwl.
3. Configure slstatus.
4. Setup Foot/Fuzzel/Bash.
5. Configure Neovim.
6. Apply monochrome theme.
7. Optimize system.
