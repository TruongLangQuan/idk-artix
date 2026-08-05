#!/usr/bin/env bash
# scripts/setup_disk.sh - Artix Linux Live ISO Disk Partitioning & Base Installer
# Version: 1.0
# Target: 2TB NVMe SSD (/dev/nvme0n1) with Btrfs & 16GB Swapfile

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

source "${SCRIPT_DIR}/lib/logging.sh"
source "${SCRIPT_DIR}/lib/validation.sh"

TARGET_DISK="/dev/nvme0n1"
TARGET_USER="truonglangquan"
TARGET_PASS="15031169"
HOSTNAME="artix-suckless"
SWAP_SIZE_GB="16"

show_help() {
    cat << EOF
Usage: $(basename "$0") [OPTIONS]

Options:
  --disk DEVICE   Target disk device (default: /dev/nvme0n1).
  --swap SIZE     Swapfile size in GB (default: 16).
  -d, --dry-run   Show disk partitioning & basestrap steps without modifying disk.
  -h, --help      Show this help message.

Description:
  Automates Stage 0 installation from Artix Live ISO:
  1. Verifies UEFI boot mode.
  2. Partitions target NVMe disk (1GB EFI FAT32 + Btrfs root).
  3. Formats Btrfs subvolumes (@, @home, @cache, @log, @pkg, @tmp, @snapshots, @swap).
  4. Mounts subvolumes with zstd:3 compression & creates 16GB swapfile.
  5. Runs basestrap for base, openrc, elogind, kernels (zen/lts), & intel-ucode.
  6. Generates /etc/fstab and configures GRUB UEFI bootloader.
EOF
}

check_dry_run_flag "$@"

for arg in "$@"; do
    if [ "$arg" = "--help" ] || [ "$arg" = "-h" ]; then
        show_help
        exit 0
    fi
done

log_info "Starting Artix Linux Live ISO Disk Setup..."

# Verify UEFI Mode
if [ ! -d "/sys/firmware/efi/efivars" ]; then
    log_error "System is NOT booted in UEFI mode! Aborting installation."
    exit 1
fi
log_success "UEFI boot mode verified."

PART_EFI="${TARGET_DISK}p1"
PART_ROOT="${TARGET_DISK}p2"

if [ "$IS_DRY_RUN" = true ]; then
    log_info "[DRY-RUN] Target disk: ${TARGET_DISK}"
    log_info "[DRY-RUN] Partition 1: ${PART_EFI} (1GB FAT32 EFI)"
    log_info "[DRY-RUN] Partition 2: ${PART_ROOT} (Btrfs Root)"
    log_info "[DRY-RUN] Btrfs subvolumes: @, @home, @cache, @log, @pkg, @tmp, @snapshots, @swap"
    log_info "[DRY-RUN] Swapfile: 16GB inside /swap/swapfile"
    log_info "[DRY-RUN] Basestrap packages: base base-devel openrc elogind linux-zen linux-zen-headers linux-lts linux-lts-headers linux-firmware intel-ucode"
    log_info "[DRY-RUN] GRUB target: x86_64-efi to /boot/efi"
    exit 0
fi

log_warning "ATTENTION: All data on ${TARGET_DISK} will be WIPED!"
if ! ask_confirmation "Proceed with partitioning and formatting ${TARGET_DISK}?"; then
    log_info "Aborted disk setup."
    exit 0
fi

log_info "Wiping existing partition table on ${TARGET_DISK}..."
sudo sgdisk --zap-all "${TARGET_DISK}" || true

log_info "Creating GPT partitions on ${TARGET_DISK}..."
sudo sgdisk -n 1:0:+1G -t 1:ef00 -c 1:"EFI System Partition" "${TARGET_DISK}"
sudo sgdisk -n 2:0:0   -t 2:8300 -c 2:"Artix Root Btrfs" "${TARGET_DISK}"

log_info "Formatting partitions..."
sudo mkfs.fat -F32 "${PART_EFI}"
sudo mkfs.btrfs -f -L ARTIX "${PART_ROOT}"

log_info "Creating Btrfs subvolumes..."
sudo mount "${PART_ROOT}" /mnt
sudo btrfs subvolume create /mnt/@
sudo btrfs subvolume create /mnt/@home
sudo btrfs subvolume create /mnt/@cache
sudo btrfs subvolume create /mnt/@log
sudo btrfs subvolume create /mnt/@pkg
sudo btrfs subvolume create /mnt/@tmp
sudo btrfs subvolume create /mnt/@snapshots
sudo btrfs subvolume create /mnt/@swap
sudo umount /mnt

log_info "Mounting subvolumes..."
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

log_info "Creating ${SWAP_SIZE_GB}GB Swapfile..."
sudo btrfs filesystem mkswapfile --size "${SWAP_SIZE_GB}g" --uuid clear /mnt/swap/swapfile || {
    sudo truncate -s 0 /mnt/swap/swapfile
    sudo chattr +C /mnt/swap/swapfile 2>/dev/null || true
    sudo fallocate -l "${SWAP_SIZE_GB}G" /mnt/swap/swapfile
    sudo chmod 600 /mnt/swap/swapfile
    sudo mkswap /mnt/swap/swapfile
}
sudo swapon /mnt/swap/swapfile

log_info "Bootstrapping base system..."
sudo basestrap /mnt base base-devel openrc elogind linux-zen linux-zen-headers linux-lts linux-lts-headers linux-firmware intel-ucode

log_info "Generating fstab..."
sudo fstabgen -U /mnt | sudo tee -a /mnt/etc/fstab

log_info "Configuring base system in chroot..."
sudo artix-chroot /mnt bash -c "
    ln -sf /usr/share/zoneinfo/Asia/Ho_Chi_Minh /etc/localtime
    hwclock --systohc
    echo 'en_US.UTF-8 UTF-8' > /etc/locale.gen
    echo 'vi_VN.UTF-8 UTF-8' >> /etc/locale.gen
    locale-gen
    echo 'LANG=en_US.UTF-8' > /etc/locale.conf
    echo '${HOSTNAME}' > /etc/hostname
    
    echo 'root:${TARGET_PASS}' | chpasswd
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

log_success "Base system installed and bootloader configured on ${TARGET_DISK}!"
log_info "You may now unmount /mnt and reboot into Artix Linux:"
log_info "  sudo umount -R /mnt && reboot"
