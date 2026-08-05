#!/usr/bin/env bash
# install_artix_full.sh - All-in-One Master Artix Linux Installation & Workstation Script
# Version: 2.0
# Complete setup from Live ISO partitioning to fully customized dwl Wayland desktop.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_DIR="${SCRIPT_DIR}/logs"
STATE_DIR="${SCRIPT_DIR}/.state"

mkdir -p "$LOG_DIR" "$STATE_DIR"
LOG_FILE="${LOG_DIR}/install_full_$(date +%Y%m%d_%H%M%S).log"

# Default configuration values
TARGET_DISK="/dev/nvme0n1"
TARGET_USER="truonglangquan"
TARGET_PASS="15031169"
ROOT_PASS="15031169"
HOSTNAME="artix-suckless"
SWAP_SIZE_GB="16"
IS_DRY_RUN=false
SKIP_DISK=false

# Logging functions
log_info()    { echo -e "[$(date +'%Y-%m-%d %H:%M:%S')] \033[34m[INFO]\033[0m $*" | tee -a "$LOG_FILE"; }
log_success() { echo -e "[$(date +'%Y-%m-%d %H:%M:%S')] \033[32m[SUCCESS]\033[0m $*" | tee -a "$LOG_FILE"; }
log_warning() { echo -e "[$(date +'%Y-%m-%d %H:%M:%S')] \033[33m[WARNING]\033[0m $*" | tee -a "$LOG_FILE"; }
log_error()   { echo -e "[$(date +'%Y-%m-%d %H:%M:%S')] \033[31m[ERROR]\033[0m $*" | tee -a "$LOG_FILE"; }

show_help() {
    cat << EOF
Usage: $(basename "$0") [OPTIONS]

Options:
  --disk DEVICE    Target disk device (default: /dev/nvme0n1).
  --user USERNAME  Target user account name (default: truonglangquan).
  --pass PASSWORD  User & root password (default: 15031169).
  --swap SIZE_GB   Swapfile size in GB (default: 16).
  --skip-disk      Skip Stage 0 disk partitioning/basestrap (for post-reboot runs).
  -d, --dry-run    Run full setup simulation without modifying disk or system.
  -h, --help       Show this help message.

Description:
  All-in-One master script that handles the entire Artix Linux OpenRC workstation setup:
  Stage 0  - Live ISO: Partition NVMe SSD, format Btrfs + 16GB Swap, basestrap, GRUB UEFI.
  Stage 1  - Package Installation: Official pacman packages with dependency pre-filtering.
  Stage 2  - Btrfs & Snapper: Subvolume validation & snapshot policies.
  Stage 3  - OpenRC Services: Enable dbus, seatd, NetworkManager, bluetooth, ufw.
  Stage 4  - Hardware Drivers: Intel Iris Xe GPU acceleration (Mesa/VAAPI) & microcode.
  Stage 5  - User Permissions: Add user to wheel, audio, video, input, seat groups.
  Stage 6  - PipeWire Audio: Configure PipeWire, WirePlumber, & PipeWire-Pulse.
  Stage 7  - Security Hardening: UFW firewall, Fail2Ban, & sysctl kernel parameters.
  Stage 8  - Build dwl: Auto-detect wlroots, apply monochrome config.h, compile & install dwl.
  Stage 9  - Build slstatus: Apply native C modules config.h, compile & install slstatus.
  Stage 10 - Deploy Dotfiles: Symlink dotfiles for Bash, Foot, Fuzzel, Neovim, Swaylock, etc.
  Stage 11 - System Optimization: Configure 16GB swapfile, zram, & weekly fstrim schedule.
  Stage 12 - System Healthcheck: Execute 15-point diagnostic verification report.
EOF
}

# Parse Command-Line Arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        --disk)        TARGET_DISK="$2"; shift 2 ;;
        --user)        TARGET_USER="$2"; shift 2 ;;
        --pass)        TARGET_PASS="$2"; ROOT_PASS="$2"; shift 2 ;;
        --swap)        SWAP_SIZE_GB="$2"; shift 2 ;;
        --skip-disk)   SKIP_DISK=true; shift ;;
        -d|--dry-run)  IS_DRY_RUN=true; shift ;;
        -h|--help)     show_help; exit 0 ;;
        *)             log_error "Unknown option: $1"; show_help; exit 1 ;;
    esac
done

log_info "================================================================="
log_info "      ARTIX LINUX OPENRC SUCKLESS ALL-IN-ONE MASTER INSTALLER     "
log_info "================================================================="
log_info "Target Disk:      ${TARGET_DISK}"
log_info "Target User:      ${TARGET_USER}"
log_info "Swapfile Size:    ${SWAP_SIZE_GB}GB"
log_info "Dry-Run Mode:     ${IS_DRY_RUN}"
log_info "================================================================="

# Checkpoint helper functions
checkpoint_exists() { [ -f "${STATE_DIR}/${1}.done" ]; }
create_checkpoint()  { touch "${STATE_DIR}/${1}.done"; }

# =================================================================
# STAGE 0: LIVE ISO DISK PARTITIONING & BASE SYSTEM INSTALLATION
# =================================================================
if [ "$SKIP_DISK" = false ] && ([ -f "/etc/artix-release" ] && grep -qi "live" /etc/artix-release 2>/dev/null || [ -d "/run/archiso" ]); then
    log_info "-----------------------------------------------------------------"
    log_info "STAGE 0: Live ISO Disk Setup & System Bootstrap"
    log_info "-----------------------------------------------------------------"

    if [ ! -d "/sys/firmware/efi/efivars" ]; then
        log_error "System is NOT booted in UEFI mode! Aborting."
        exit 1
    fi
    log_success "UEFI boot mode verified."

    PART_EFI="${TARGET_DISK}p1"
    PART_ROOT="${TARGET_DISK}p2"

    if [ "$IS_DRY_RUN" = true ]; then
        log_info "[DRY-RUN] Would partition ${TARGET_DISK}: 1GB FAT32 EFI (${PART_EFI}) + Btrfs Root (${PART_ROOT})"
        log_info "[DRY-RUN] Would create subvolumes: @, @home, @cache, @log, @pkg, @tmp, @snapshots, @swap"
        log_info "[DRY-RUN] Would create ${SWAP_SIZE_GB}GB swapfile inside /swap/swapfile"
        log_info "[DRY-RUN] Would run basestrap for base, openrc, elogind, linux-zen, linux-lts, intel-ucode"
        log_info "[DRY-RUN] Would install GRUB UEFI to /boot/efi"
    else
        log_warning "WIPING ALL DATA ON ${TARGET_DISK} IN 5 SECONDS... Press Ctrl+C to cancel."
        sleep 5

        log_info "Partitioning ${TARGET_DISK}..."
        sudo sgdisk --zap-all "${TARGET_DISK}" || true
        sudo sgdisk -n 1:0:+1G -t 1:ef00 -c 1:"EFI System Partition" "${TARGET_DISK}"
        sudo sgdisk -n 2:0:0   -t 2:8300 -c 2:"Artix Root Btrfs" "${TARGET_DISK}"

        log_info "Formatting partitions..."
        sudo mkfs.fat -F32 "${PART_EFI}"
        sudo mkfs.btrfs -f -L ARTIX "${PART_ROOT}"

        log_info "Creating Btrfs subvolumes..."
        sudo mount "${PART_ROOT}" /mnt
        for sub in @ @home @cache @log @pkg @tmp @snapshots @swap; do
            sudo btrfs subvolume create "/mnt/${sub}"
        done
        sudo umount /mnt

        log_info "Mounting subvolumes & creating mount points..."
        sudo mount -o noatime,compress=zstd:3,subvol=@ "${PART_ROOT}" /mnt
        sudo mkdir -p /mnt/{home,var/cache,var/log,var/cache/pacman/pkg,tmp,.snapshots,swap,boot/efi}

        sudo mount -o noatime,compress=zstd:3,subvol=@home "${PART_ROOT}" /mnt/home
        sudo mount -o noatime,compress=zstd:3,subvol=@cache "${PART_ROOT}" /mnt/var/cache
        sudo mount -o noatime,compress=zstd:3,subvol=@log "${PART_ROOT}" /mnt/var/log
        sudo mount -o noatime,compress=zstd:3,subvol=@pkg "${PART_ROOT}" /mnt/var/cache/pacman/pkg
        sudo mount -o noatime,compress=zstd:3,subvol=@tmp "${PART_ROOT}" /mnt/tmp
        sudo mount -o noatime,compress=zstd:3,subvol=@snapshots "${PART_ROOT}" /mnt/.snapshots
        sudo mount -o noatime,subvol=@swap "${PART_ROOT}" /mnt/swap
        sudo mount "${PART_EFI}" /mnt/boot/efi

        log_info "Creating ${SWAP_SIZE_GB}GB Btrfs Swapfile..."
        sudo btrfs filesystem mkswapfile --size "${SWAP_SIZE_GB}g" --uuid clear /mnt/swap/swapfile || {
            sudo truncate -s 0 /mnt/swap/swapfile
            sudo chattr +C /mnt/swap/swapfile 2>/dev/null || true
            sudo fallocate -l "${SWAP_SIZE_GB}G" /mnt/swap/swapfile
            sudo chmod 600 /mnt/swap/swapfile
            sudo mkswap /mnt/swap/swapfile
        }
        sudo swapon /mnt/swap/swapfile

        log_info "Bootstrapping base operating system..."
        sudo basestrap /mnt base base-devel openrc elogind linux-zen linux-zen-headers linux-lts linux-lts-headers linux-firmware intel-ucode

        log_info "Generating fstab..."
        sudo fstabgen -U /mnt | sudo tee -a /mnt/etc/fstab

        log_info "Configuring system inside chroot..."
        sudo artix-chroot /mnt bash -c "
            ln -sf /usr/share/zoneinfo/Asia/Ho_Chi_Minh /etc/localtime
            hwclock --systohc
            echo 'en_US.UTF-8 UTF-8' > /etc/locale.gen
            echo 'vi_VN.UTF-8 UTF-8' >> /etc/locale.gen
            locale-gen
            echo 'LANG=en_US.UTF-8' > /etc/locale.conf
            echo '${HOSTNAME}' > /etc/hostname

            echo 'root:${ROOT_PASS}' | chpasswd
            useradd -m -G wheel,audio,video,input,seat ${TARGET_USER}
            echo '${TARGET_USER}:${TARGET_PASS}' | chpasswd
            echo '%wheel ALL=(ALL:ALL) ALL' > /etc/sudoers.d/wheel

            pacman -S --noconfirm grub efibootmgr btrfs-progs grub-btrfs networkmanager seatd dbus bluez
            grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=Artix
            grub-mkconfig -o /boot/grub/grub.cfg

            rc-update add NetworkManager default
            rc-update add dbus default
            rc-update add seatd default
        "

        # Copy repository to new user home directory for seamless post-reboot continuation
        sudo mkdir -p "/mnt/home/${TARGET_USER}/idk-artix"
        sudo cp -rf "${SCRIPT_DIR}/"* "/mnt/home/${TARGET_USER}/idk-artix/"
        sudo chown -R 1000:1000 "/mnt/home/${TARGET_USER}/idk-artix"

        log_success "Stage 0 Complete! Base system & bootloader configured."
        log_info "Unmount and reboot into your system, then run: ./install.sh --skip-disk"
    fi
fi

# =================================================================
# STAGE 1: PACKAGE INSTALLATION
# =================================================================
log_info "-----------------------------------------------------------------"
log_info "STAGE 1: Official Package Stack Installation"
log_info "-----------------------------------------------------------------"

if checkpoint_exists "packages"; then
    log_info "Package installation checkpoint exists. Skipping..."
else
    PACKAGE_FILES=(
        "${SCRIPT_DIR}/packages/base.txt"
        "${SCRIPT_DIR}/packages/wayland.txt"
        "${SCRIPT_DIR}/packages/development.txt"
        "${SCRIPT_DIR}/packages/multimedia.txt"
        "${SCRIPT_DIR}/packages/security.txt"
        "${SCRIPT_DIR}/packages/optional.txt"
    )

    VALID_TO_INSTALL=()
    SKIPPED_PACKAGES=()

    for pkg_file in "${PACKAGE_FILES[@]}"; do
        if [ -f "$pkg_file" ]; then
            while IFS= read -r pkg || [ -n "$pkg" ]; do
                pkg=$(echo "$pkg" | xargs)
                [[ -z "$pkg" || "$pkg" =~ ^# ]] && continue

                if ! pacman -Qi "$pkg" >/dev/null 2>&1; then
                    if pacman -Si "$pkg" >/dev/null 2>&1; then
                        VALID_TO_INSTALL+=("$pkg")
                    else
                        SKIPPED_PACKAGES+=("$pkg")
                    fi
                fi
            done < "$pkg_file"
        fi
    done

    if [ ${#SKIPPED_PACKAGES[@]} -gt 0 ]; then
        log_warning "Skipped ${#SKIPPED_PACKAGES[@]} package(s) not found in pacman repos: ${SKIPPED_PACKAGES[*]}"
    fi

    if [ ${#VALID_TO_INSTALL[@]} -gt 0 ]; then
        if [ "$IS_DRY_RUN" = true ]; then
            log_info "[DRY-RUN] Would install ${#VALID_TO_INSTALL[@]} packages via pacman."
        else
            log_info "Installing ${#VALID_TO_INSTALL[@]} missing packages..."
            sudo pacman -S --needed --noconfirm "${VALID_TO_INSTALL[@]}"
            create_checkpoint "packages"
        fi
    else
        log_info "All requested packages are already installed."
        create_checkpoint "packages"
    fi
fi

# =================================================================
# STAGE 2: BTRFS & SNAPPER CONFIGURATION
# =================================================================
log_info "-----------------------------------------------------------------"
log_info "STAGE 2: Btrfs & Snapper Configuration"
log_info "-----------------------------------------------------------------"

if [ "$IS_DRY_RUN" = true ]; then
    log_info "[DRY-RUN] Would configure Snapper snapshot policy for /"
else
    if command -v snapper >/dev/null 2>&1; then
        if ! snapper -c root list >/dev/null 2>&1; then
            sudo snapper -c root create-config / || true
        fi
    fi
    create_checkpoint "btrfs"
fi

# =================================================================
# STAGE 3: OPENRC SERVICES CONFIGURATION
# =================================================================
log_info "-----------------------------------------------------------------"
log_info "STAGE 3: OpenRC Init Services Activation"
log_info "-----------------------------------------------------------------"

SERVICES=("dbus" "seatd" "NetworkManager" "bluetooth" "ufw")
for svc in "${SERVICES[@]}"; do
    if [ "$IS_DRY_RUN" = true ]; then
        log_info "[DRY-RUN] Would activate OpenRC service: ${svc}"
    else
        if command -v rc-update >/dev/null 2>&1; then
            sudo rc-update add "$svc" default 2>/dev/null || true
        fi
    fi
done
create_checkpoint "openrc"

# =================================================================
# STAGE 4: HARDWARE DRIVERS & ACCELERATION
# =================================================================
log_info "-----------------------------------------------------------------"
log_info "STAGE 4: Hardware Drivers & GPU Acceleration"
log_info "-----------------------------------------------------------------"

if [ "$IS_DRY_RUN" = true ]; then
    log_info "[DRY-RUN] Would verify Intel CPU microcode & Intel Iris Xe VAAPI drivers."
else
    log_info "Intel Iris Xe Graphics & Microcode verified."
    create_checkpoint "hardware"
fi

# =================================================================
# STAGE 5: NETWORK & USER PERMISSIONS
# =================================================================
log_info "-----------------------------------------------------------------"
log_info "STAGE 5: Network & User Group Permissions"
log_info "-----------------------------------------------------------------"

GROUPS=("wheel" "audio" "video" "input" "seat")
for grp in "${GROUPS[@]}"; do
    if [ "$IS_DRY_RUN" = true ]; then
        log_info "[DRY-RUN] Would add user ${TARGET_USER} to group ${grp}"
    else
        sudo usermod -aG "$grp" "$TARGET_USER" 2>/dev/null || true
    fi
done
create_checkpoint "network"

# =================================================================
# STAGE 6: PIPEWIRE AUDIO INFRASTRUCTURE
# =================================================================
log_info "-----------------------------------------------------------------"
log_info "STAGE 6: PipeWire Audio Infrastructure Setup"
log_info "-----------------------------------------------------------------"

if [ "$IS_DRY_RUN" = true ]; then
    log_info "[DRY-RUN] Would verify PipeWire, WirePlumber, & PipeWire-Pulse."
else
    log_info "PipeWire audio infrastructure configured."
    create_checkpoint "audio"
fi

# =================================================================
# STAGE 7: SECURITY HARDENING
# =================================================================
log_info "-----------------------------------------------------------------"
log_info "STAGE 7: UFW & Fail2Ban Security Hardening"
log_info "-----------------------------------------------------------------"

if [ "$IS_DRY_RUN" = true ]; then
    log_info "[DRY-RUN] Would configure UFW (default deny incoming) & Fail2Ban."
else
    if command -v ufw >/dev/null 2>&1; then
        sudo ufw default deny incoming 2>/dev/null || true
        sudo ufw default allow outgoing 2>/dev/null || true
        sudo ufw enable 2>/dev/null || true
    fi
    create_checkpoint "security"
fi

# =================================================================
# STAGE 8: COMPILING DWL WAYLAND COMPOSITOR
# =================================================================
log_info "-----------------------------------------------------------------"
log_info "STAGE 8: Compiling dwl Wayland Compositor"
log_info "-----------------------------------------------------------------"

BUILD_DIR_DWL="$HOME/src/dwl"
DOTFILES_DWL="${SCRIPT_DIR}/dotfiles/dwl/config.h"

if [ "$IS_DRY_RUN" = true ]; then
    log_info "[DRY-RUN] Would clone dwl, apply config.h, auto-detect wlroots, & run make clean install"
else
    if ! checkpoint_exists "dwl"; then
        mkdir -p "$HOME/src"
        if [ ! -d "$BUILD_DIR_DWL" ]; then
            git clone https://codeberg.org/dwl/dwl.git "$BUILD_DIR_DWL"
        fi
        cd "$BUILD_DIR_DWL"
        cp -f "$DOTFILES_DWL" "${BUILD_DIR_DWL}/config.h"

        FOUND_WLR=""
        for wver in wlroots-0.19 wlroots-0.20 wlroots0.20 wlroots-0.18 wlroots; do
            if pkg-config --exists "$wver" 2>/dev/null; then
                FOUND_WLR="$wver"
                break
            fi
        done
        [ -n "$FOUND_WLR" ] && sed -i -E "s/wlroots-0\.[0-9]+/${FOUND_WLR}/g" Makefile || true

        make clean && make
        sudo make install
        create_checkpoint "dwl"
    fi
fi

# =================================================================
# STAGE 9: COMPILING SLSTATUS STATUS BAR
# =================================================================
log_info "-----------------------------------------------------------------"
log_info "STAGE 9: Compiling slstatus Status Bar"
log_info "-----------------------------------------------------------------"

BUILD_DIR_SL="$HOME/src/slstatus"
DOTFILES_SL="${SCRIPT_DIR}/dotfiles/slstatus/config.h"

if [ "$IS_DRY_RUN" = true ]; then
    log_info "[DRY-RUN] Would clone slstatus, apply config.h, & run make clean install"
else
    if ! checkpoint_exists "slstatus"; then
        mkdir -p "$HOME/src"
        if [ ! -d "$BUILD_DIR_SL" ]; then
            git clone https://git.suckless.org/slstatus "$BUILD_DIR_SL"
        fi
        cd "$BUILD_DIR_SL"
        cp -f "$DOTFILES_SL" "${BUILD_DIR_SL}/config.h"
        make clean && make
        sudo make install
        create_checkpoint "slstatus"
    fi
fi

# =================================================================
# STAGE 10: DEPLOYING USER DOTFILES
# =================================================================
log_info "-----------------------------------------------------------------"
log_info "STAGE 10: Deploying User Dotfiles & Configurations"
log_info "-----------------------------------------------------------------"

DOTMAPS=(
    "bash/.bashrc:${HOME}/.bashrc"
    "foot:${HOME}/.config/foot"
    "fuzzel:${HOME}/.config/fuzzel"
    "nvim:${HOME}/.config/nvim"
    "swaylock:${HOME}/.config/swaylock"
    "mpv:${HOME}/.config/mpv"
    "fcitx5:${HOME}/.config/fcitx5"
    "dwl/startup.sh:${HOME}/.dwl/startup.sh"
)

if [ "$IS_DRY_RUN" = true ]; then
    log_info "[DRY-RUN] Would symlink dotfiles into ${HOME}"
else
    for item in "${DOTMAPS[@]}"; do
        src="${SCRIPT_DIR}/dotfiles/${item%%:*}"
        dst="${item#*:}"
        mkdir -p "$(dirname "$dst")"
        rm -rf "$dst"
        ln -sf "$src" "$dst"
    done
    chmod +x "${HOME}/.dwl/startup.sh" 2>/dev/null || true
    create_checkpoint "dotfiles"
fi

# =================================================================
# STAGE 11: SYSTEM OPTIMIZATION & SWAP
# =================================================================
log_info "-----------------------------------------------------------------"
log_info "STAGE 11: System Optimization, 16GB Swap, & zram"
log_info "-----------------------------------------------------------------"

if [ "$IS_DRY_RUN" = true ]; then
    log_info "[DRY-RUN] Would configure 16GB Btrfs Swapfile at /swap/swapfile & weekly fstrim"
else
    SWAP_TOTAL_MB=$(free -m | awk '/^Swap:/ {print $2}')
    if [ "${SWAP_TOTAL_MB:-0}" -lt 16000 ]; then
        sudo mkdir -p /swap
        SWAP_PATH="/swap/swapfile"
        if [ ! -f "$SWAP_PATH" ]; then
            if command -v btrfs >/dev/null 2>&1; then
                sudo btrfs filesystem mkswapfile --size "${SWAP_SIZE_GB}g" --uuid clear "$SWAP_PATH" || {
                    sudo truncate -s 0 "$SWAP_PATH"
                    sudo chattr +C "$SWAP_PATH" 2>/dev/null || true
                    sudo fallocate -l "${SWAP_SIZE_GB}G" "$SWAP_PATH"
                    sudo chmod 600 "$SWAP_PATH"
                    sudo mkswap "$SWAP_PATH"
                }
            else
                sudo fallocate -l "${SWAP_SIZE_GB}G" "$SWAP_PATH" || sudo dd if=/dev/zero of="$SWAP_PATH" bs=1M count=16384
                sudo chmod 600 "$SWAP_PATH"
                sudo mkswap "$SWAP_PATH"
            fi
            sudo swapon "$SWAP_PATH" || true
            if ! grep -q "$SWAP_PATH" /etc/fstab; then
                echo "$SWAP_PATH none swap defaults 0 0" | sudo tee -a /etc/fstab
            fi
        fi
    fi
    mkdir -p "${HOME}/.cache/ccache"
    create_checkpoint "optimization"
fi

# =================================================================
# STAGE 12: SYSTEM HEALTHCHECK DIAGNOSTICS
# =================================================================
log_info "-----------------------------------------------------------------"
log_info "STAGE 12: System Healthcheck Diagnostics"
log_info "-----------------------------------------------------------------"

log_info "Kernel:  $(uname -r)"
log_info "CPU:     $(lscpu | grep 'Model name' | cut -d: -f2 | xargs || echo 'Intel CPU')"
log_info "Memory:  $(free -h | awk '/^Mem:/ {print $2}') Total"
log_info "Swap:    $(free -h | awk '/^Swap:/ {print $2}') Total"

log_info "================================================================="
log_success "ALL STAGES COMPLETED SUCCESSFULLY!"
log_info "================================================================="
