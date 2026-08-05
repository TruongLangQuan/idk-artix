# SCRIPT USAGE & INSTALLATION WORKFLOW GUIDE

Version: 1.0

Project: Artix Linux OpenRC Suckless Workstation

---

# 1. Installation Workflow Overview

The system setup flows from booting an official Artix Linux OpenRC Live ISO to a fully configured, optimized dwl Wayland developer workstation.

```text
Artix Linux TTY ISO
        |
        v
1. Prepare ISO Environment & Permissions
        |
        v
2. Verify Hardware (CPU, GPU, RAM, Storage)
        |
        v
3. Partition NVMe SSD
        |
        v
4. Setup Btrfs Filesystem & Subvolumes
        |
        v
5. Bootstrap Base Operating System
        |
        v
6. Enter Chroot Environment
        |
        v
7. Install Package Repositories
        |
        v
8. Configure OpenRC Init System
        |
        v
9. Install Kernels (Zen & LTS)
        |
        v
10. Install & Configure GRUB UEFI
        |
        v
11. Configure User & Groups
        |
        v
12. Build dwl & slstatus Compositor / Bar
        |
        v
13. Deploy User Dotfiles
        |
        v
14. Optimize System & Memory (zram)
        |
        v
15. First Boot Validation & Healthcheck
```

---

# 2. Official Artix Wiki Live ISO NVMe Setup (2TB NVMe SSD: /dev/nvme0n1)

Following the [Official Artix Linux Wiki Installation Guide](https://wiki.artixlinux.org/Main/Installation):

### 1. Verify UEFI Boot Mode
```bash
ls /sys/firmware/efi/efivars
```

### 2. Partition 2TB NVMe SSD (`/dev/nvme0n1`)
```bash
cfdisk /dev/nvme0n1
# Create p1: 1G (EFI System, Fat32)
# Create p2: Remaining space (~2TB, Linux filesystem Btrfs)
```

### 3. Format Partitions & Create Btrfs Subvolumes
```bash
mkfs.fat -F32 /dev/nvme0n1p1
mkfs.btrfs -f -L ARTIX /dev/nvme0n1p2

mount /dev/nvme0n1p2 /mnt
btrfs subvolume create /mnt/@
btrfs subvolume create /mnt/@home
btrfs subvolume create /mnt/@cache
btrfs subvolume create /mnt/@log
btrfs subvolume create /mnt/@pkg
btrfs subvolume create /mnt/@tmp
btrfs subvolume create /mnt/@snapshots
btrfs subvolume create /mnt/@swap
umount /mnt
```

### 4. Mount System Subvolumes & Setup 16GB Swapfile
```bash
mount -o noatime,compress=zstd:3,subvol=@ /dev/nvme0n1p2 /mnt
mkdir -p /mnt/{home,var/cache,var/log,var/cache/pacman/pkg,tmp,.snapshots,swap,boot/efi}

mount -o noatime,compress=zstd:3,subvol=@home /dev/nvme0n1p2 /mnt/home
mount -o noatime,compress=zstd:3,subvol=@cache /dev/nvme0n1p2 /mnt/var/cache
mount -o noatime,compress=zstd:3,subvol=@log /dev/nvme0n1p2 /mnt/var/log
mount -o noatime,compress=zstd:3,subvol=@pkg /dev/nvme0n1p2 /mnt/var/cache/pacman/pkg
mount -o noatime,compress=zstd:3,subvol=@tmp /dev/nvme0n1p2 /mnt/tmp
mount -o noatime,compress=zstd:3,subvol=@snapshots /dev/nvme0n1p2 /mnt/.snapshots
mount -o noatime,subvol=@swap /dev/nvme0n1p2 /mnt/swap

# Create 16GB Btrfs Swapfile inside @swap
btrfs filesystem mkswapfile --size 16g --uuid clear /mnt/swap/swapfile
swapon /mnt/swap/swapfile

mount /dev/nvme0n1p1 /mnt/boot/efi
```

### 5. Basestrap & Chroot
```bash
basestrap /mnt base base-devel openrc elogind
basestrap /mnt linux-zen linux-zen-headers linux-lts linux-lts-headers linux-firmware intel-ucode
fstabgen -U /mnt >> /mnt/etc/fstab
artix-chroot /mnt
```

---

# 3. Universal Script Command Options

Every automation script in `scripts/` supports standardized command-line flags:

| Flag | Long Option | Description |
| --- | --- | --- |
| `-h` | `--help` | Displays usage instructions, purpose, options, and warnings. |
| `-d` | `--dry-run` | Simulates execution and outputs actions without changing system state. |
| `-r` | `--resume` | Resumes execution from existing state checkpoints. |
| `-f` | `--force` | Overrides existing checkpoints and forces re-execution (requires confirmation). |
| `-c` | `--clean` | Performs a clean rebuild (supported in `build_dwl.sh` and `build_slstatus.sh`). |

---

# 3. Stage-by-Stage Script Execution Order

All automation scripts reside in `scripts/`. Below is the complete execution guide.

## Stage 0 — ISO Preparation

Prepare permissions and run initial environment inspection:

```bash
chmod +x scripts/*.sh scripts/lib/*.sh
./scripts/healthcheck.sh
```

**Purpose**: Verify network connectivity, UEFI mode, and hardware detection on the installation media.  
**Permissions**: Standard user or root in Live TTY.

---

## Stage 1 — Hardware Diagnostics

Run hardware inspection:

```bash
./scripts/setup_hardware.sh --dry-run
```

**Purpose**: Detect Intel Gen 11 i5 CPU, iGPU, 16GB RAM, and NVMe SSD.  
**Required Permissions**: Standard user / root.  
**Expected Output**: System hardware summary logging to `logs/`.

---

## Stage 2 — Filesystem & Disk Preparation

Run Btrfs subvolume verification:

```bash
./scripts/setup_btrfs.sh
```

**Purpose**: Create and verify Btrfs subvolumes (`@`, `@home`, `@cache`, `@log`, `@pkg`, `@tmp`, `@snapshots`), configure mount options (`noatime,compress=zstd`), and set up Snapper.  
**Safety Rule**: NEVER automatically formats disks without explicit interactive user confirmation.  
**Required Permissions**: Root / Sudo.

---

## Stage 3 — Base System Installation

Execute base installation:

```bash
./scripts/install_packages.sh
```

**Purpose**: Installs base packages from `packages/base.txt` (`base`, `base-devel`, `openrc`, `elogind`, `linux-zen`, `linux-lts`, `intel-ucode`, `btrfs-progs`, `grub`, `efibootmgr`).  
**Required Permissions**: Root / Sudo.

---

## Stage 4 — OpenRC Service Setup

Configure system init daemons:

```bash
./scripts/setup_openrc.sh
```

**Purpose**: Enables required OpenRC services in default runlevel (`dbus`, `seatd`, `NetworkManager`, `bluetooth`, `power-profiles-daemon`, `ufw`, `fail2ban`).  
**Required Permissions**: Root / Sudo.

---

## Stage 5 — Network & User Group Setup

Configure network & seat permissions:

```bash
./scripts/setup_network.sh
```

**Purpose**: Adds target user (`truonglangquan`) to `wheel`, `video`, `input`, `seat`, and `audio` groups.  
**Required Permissions**: Root / Sudo.

---

## Stage 6 — Audio System Setup

Configure PipeWire audio infrastructure:

```bash
./scripts/setup_audio.sh
```

**Purpose**: Sets up PipeWire, WirePlumber, pavucontrol, and Bluetooth audio. Terminates standalone PulseAudio daemons if present.  
**Required Permissions**: User / Sudo.

---

## Stage 7 — Security Hardening

Apply system security rules:

```bash
./scripts/setup_security.sh
```

**Purpose**: Configures UFW firewall (default deny incoming, allow outgoing), Fail2Ban SSH protection, sysctl security rules, and SSH directory permissions (`700`).  
**Required Permissions**: Root / Sudo.

---

## Stage 8 — Build Wayland Compositor (dwl)

Compile dwl from source:

```bash
./scripts/build_dwl.sh
```

**Purpose**: Clones dwl into `~/src/dwl`, applies custom monochrome `config.h` (Super modifier, 5 tags, custom shortcuts), compiles, and installs binary to `/usr/local/bin/dwl`.  
**Clean Rebuild**: `./scripts/build_dwl.sh --clean`  
**Required Permissions**: User / Sudo for `make install`.

---

## Stage 9 — Build Status Bar (slstatus)

Compile slstatus from source:

```bash
./scripts/build_slstatus.sh
```

**Purpose**: Clones slstatus into `~/src/slstatus`, applies custom native C modules (workspace, RAM, disk, CPU %, CPU temp, network, date/time), compiles, and installs binary to `/usr/local/bin/slstatus`.  
**Required Permissions**: User / Sudo for `make install`.

---

## Stage 10 — Deploy User Dotfiles

Deploy configuration symlinks:

```bash
./scripts/deploy_dotfiles.sh
```

**Purpose**: Creates safety backups of existing configurations in `backup/YYYYMMDD_HHMMSS/` and symlinks configuration files from `dotfiles/` to `~/.config/` (`foot`, `fuzzel`, `nvim`, `swaylock`, `mpv`, `fcitx5`, `dwl/startup.sh`, `.bashrc`).  
**Required Permissions**: Standard user.

---

## Stage 11 — System Optimization

Apply performance tuning:

```bash
./scripts/optimize_system.sh
```

**Purpose**: Configures 8GB zram compressed swap, schedules weekly NVMe `fstrim`, sets balanced power profile, and configures `ccache`.  
**Required Permissions**: Root / Sudo.

---

## Stage 12 — Final Healthcheck Validation

Run read-only system validation audit:

```bash
./scripts/healthcheck.sh
```

**Expected Output**:
```text
Hardware:    PASS
Filesystem:  PASS
OpenRC:      PASS
Wayland:     PASS
Audio:       PASS
Network:     PASS
Security:    PASS
```

---

# 4. Troubleshooting & Resumability

If any script is interrupted, fix the underlying issue and resume:

```bash
# Resume full setup
./scripts/bootstrap.sh --resume

# Force re-running a specific stage
./scripts/build_dwl.sh --force
```
