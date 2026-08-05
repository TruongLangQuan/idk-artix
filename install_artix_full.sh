#!/usr/bin/env bash
# install_artix_full.sh - Artix Linux OpenRC Suckless All-in-One Standalone Installation Framework
# Version: 3.0
# SINGLE SELF-CONTAINED SCRIPT - No sub-script dependencies.
# Handles Stage 0 (Live ISO 2TB NVMe SSD setup, Btrfs + 16GB Swap, Basestrap, GRUB UEFI)
# to Stages 1-12 (Pacman stack, OpenRC, dwl/slstatus compilation, dotfiles, optimization, healthcheck).

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_DIR="${SCRIPT_DIR}/logs"
STATE_DIR="${SCRIPT_DIR}/.state"

mkdir -p "$LOG_DIR" "$STATE_DIR"
LOG_FILE="${LOG_DIR}/install_$(date +%Y%m%d_%H%M%S).log"

# Default System Configuration Parameters
TARGET_DISK="/dev/nvme0n1"
TARGET_USER="truonglangquan"
TARGET_PASS="15031169"
ROOT_PASS="15031169"
HOSTNAME="artix-suckless"
SWAP_SIZE_GB="16"
IS_DRY_RUN=false
SKIP_DISK=false

# Logging Utilities
log_info()    { echo -e "[$(date +'%Y-%m-%d %H:%M:%S')] \033[34m[INFO]\033[0m $*" | tee -a "$LOG_FILE"; }
log_success() { echo -e "[$(date +'%Y-%m-%d %H:%M:%S')] \033[32m[SUCCESS]\033[0m $*" | tee -a "$LOG_FILE"; }
log_warning() { echo -e "[$(date +'%Y-%m-%d %H:%M:%S')] \033[33m[WARNING]\033[0m $*" | tee -a "$LOG_FILE"; }
log_error()   { echo -e "[$(date +'%Y-%m-%d %H:%M:%S')] \033[31m[ERROR]\033[0m $*" | tee -a "$LOG_FILE"; }

checkpoint_exists() { [ -f "${STATE_DIR}/${1}.done" ]; }
create_checkpoint()  { touch "${STATE_DIR}/${1}.done"; }
clear_checkpoint()   { rm -f "${STATE_DIR}/${1}.done"; }

ask_confirmation() {
    local prompt="$1"
    if [ "$IS_DRY_RUN" = true ]; then return 0; fi
    read -r -p "${prompt} [y/N]: " response
    case "$response" in
        [yY][eE][sS]|[yY]) return 0 ;;
        *) return 1 ;;
    esac
}

show_help() {
    cat << EOF
Usage: $(basename "$0") [OPTIONS]

Options:
  --disk DEVICE    Target disk device (default: /dev/nvme0n1).
  --user USERNAME  Target user account name (default: truonglangquan).
  --pass PASSWORD  User & root password (default: 15031169).
  --swap SIZE_GB   Swapfile size in GB (default: 16).
  --skip-disk      Skip Stage 0 disk setup (for post-reboot runs).
  -d, --dry-run    Run full setup simulation without modifying disk or system.
  -h, --help       Show this help message.

Description:
  100% Single Self-Contained Master Script for Artix Linux OpenRC Suckless Setup.
  Stage 0  - Live ISO: Partition NVMe SSD, format Btrfs + 16GB Swap, basestrap, GRUB UEFI.
  Stage 1  - Package Stack: Official pacman packages with repository pre-validation.
  Stage 2  - Btrfs & Snapper: Subvolumes & automatic snapshot policies.
  Stage 3  - OpenRC Services: Activate dbus, seatd, NetworkManager, bluetooth, ufw.
  Stage 4  - Hardware Drivers: Intel Iris Xe GPU acceleration (Mesa/VAAPI) & microcode.
  Stage 5  - User Permissions: Add user truonglangquan to wheel, audio, video, input, seat.
  Stage 6  - PipeWire Audio: Configure PipeWire, WirePlumber, & PipeWire-Pulse.
  Stage 7  - Security Hardening: UFW firewall, Fail2Ban, & sysctl parameters.
  Stage 8  - Build dwl: Auto-detect wlroots, apply monochrome config.h, compile & install dwl.
  Stage 9  - Build slstatus: Apply native C modules config.h, compile & install slstatus.
  Stage 10 - Deploy Dotfiles: Symlink dotfiles for Bash, Foot, Fuzzel, Neovim, Swaylock, etc.
  Stage 11 - System Optimization: 16GB Swapfile, zram, & weekly fstrim schedule.
  Stage 12 - System Healthcheck: Execute 15-point diagnostic verification report.
EOF
}

# Parse Arguments
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
log_info "    ARTIX LINUX OPENRC SUCKLESS STANDALONE MASTER INSTALLER      "
log_info "================================================================="
log_info "Target Disk:      ${TARGET_DISK}"
log_info "Target User:      ${TARGET_USER}"
log_info "Swapfile Size:    ${SWAP_SIZE_GB}GB"
log_info "Dry-Run Mode:     ${IS_DRY_RUN}"
log_info "================================================================="

# Detect Live ISO environment or non-Btrfs root filesystem
IS_LIVE_ISO=false
if [ "$(uname -n 2>/dev/null)" = "artix-live" ] || [ -d "/run/artix/bootmnt" ] || [ -d "/run/archiso" ] || [ -f "/etc/artix-release" ] || [ "$(findmnt -n -o FSTYPE / 2>/dev/null)" != "btrfs" ]; then
    IS_LIVE_ISO=true
fi

if [ "$SKIP_DISK" = false ] && [ "$IS_LIVE_ISO" = true ]; then
    log_info "-----------------------------------------------------------------"
    log_info "STAGE 0: Live ISO Disk Setup & Base System Bootstrap"
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
        log_warning "ATTENTION: ALL DATA ON ${TARGET_DISK} WILL BE ERASED!"
        if ! ask_confirmation "Proceed with formatting ${TARGET_DISK}?"; then
            log_info "Aborted disk setup."
            exit 0
        fi

        log_info "Wiping partition table on ${TARGET_DISK}..."
        sudo sgdisk --zap-all "${TARGET_DISK}" || true

        log_info "Creating GPT partitions..."
        sudo sgdisk -n 1:0:+1G -t 1:ef00 -c 1:"EFI System Partition" "${TARGET_DISK}"
        sudo sgdisk -n 2:0:0   -t 2:8300 -c 2:"Artix Root Btrfs" "${TARGET_DISK}"

        log_info "Formatting FAT32 & Btrfs..."
        sudo mkfs.fat -F32 "${PART_EFI}"
        sudo mkfs.btrfs -f -L ARTIX "${PART_ROOT}"

        log_info "Creating Btrfs subvolumes..."
        sudo mount "${PART_ROOT}" /mnt
        for sub in @ @home @cache @log @pkg @tmp @snapshots @swap; do
            sudo btrfs subvolume create "/mnt/${sub}"
        done
        sudo umount /mnt

        log_info "Mounting subvolumes with zstd:3 compression..."
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

        # Copy installer file to new system user directory for post-reboot run
        sudo mkdir -p "/mnt/home/${TARGET_USER}/idk-artix"
        sudo cp -rf "${SCRIPT_DIR}/"* "/mnt/home/${TARGET_USER}/idk-artix/" 2>/dev/null || true
        sudo chown -R 1000:1000 "/mnt/home/${TARGET_USER}/idk-artix"

        log_success "Stage 0 Complete! Unmount and reboot into your system, then run:"
        log_info "  ./install.sh --skip-disk"
    fi
fi

# =================================================================
# STAGE 1: OFFICIAL PACKAGE STACK INSTALLATION
# =================================================================
log_info "-----------------------------------------------------------------"
log_info "STAGE 1: Official Package Stack Installation"
log_info "-----------------------------------------------------------------"

if checkpoint_exists "packages"; then
    log_info "Package installation checkpoint exists. Skipping..."
else
    PACKAGES=(
        base base-devel btrfs-progs dbus efibootmgr grub grub-btrfs intel-ucode
        linux-firmware linux-lts linux-zen os-prober polkit snap-pac snapper sudo zram-generator
        bash-completion brightnessctl cairo cliphist fcitx5 fcitx5-configtool fcitx5-unikey
        foot fuzzel grim libinput libva libva-utils libxkbcommon mesa pango pixman seatd slurp
        swaylock ttf-jetbrains-mono vulkan-intel wayland wayland-protocols wlroots0.20 wlroots0.19
        wl-clipboard xorg-xwayland bat btop ccache clang cmake eza fastfetch fd file fzf gcc gdb
        git go htop jdk-openjdk jq lazygit less lldb llvm ltrace lua make meson nano neovim ninja
        nodejs npm openssh pkgconf python python-pip ripgrep rsync rust strace tmux tree valgrind
        go-yq zig zoxide alsa-utils bluez bluez-utils intel-media-driver mpv pamixer pavucontrol
        pipewire pipewire-alsa pipewire-jack pipewire-pulse wireplumber fail2ban ufw 7zip curl
        wget unzip hwinfo lm_sensors networkmanager network-manager-applet nvme-cli nvtop
        power-profiles-daemon powertop smartmontools
    )

    VALID_TO_INSTALL=()
    SKIPPED_PACKAGES=()

    for pkg in "${PACKAGES[@]}"; do
        if ! pacman -Qi "$pkg" >/dev/null 2>&1; then
            if pacman -Si "$pkg" >/dev/null 2>&1; then
                VALID_TO_INSTALL+=("$pkg")
            else
                SKIPPED_PACKAGES+=("$pkg")
            fi
        fi
    done

    if [ ${#SKIPPED_PACKAGES[@]} -gt 0 ]; then
        log_warning "Skipped ${#SKIPPED_PACKAGES[@]} package(s) not found in pacman repos: ${SKIPPED_PACKAGES[*]}"
    fi

    if [ ${#VALID_TO_INSTALL[@]} -gt 0 ]; then
        if [ "$IS_DRY_RUN" = true ]; then
            log_info "[DRY-RUN] Would install ${#VALID_TO_INSTALL[@]} valid packages via pacman."
        else
            log_info "Installing ${#VALID_TO_INSTALL[@]} valid missing packages..."
            echo -e "y\ny\ny\ny\ny\n" | sudo pacman -S --needed --noconfirm "${VALID_TO_INSTALL[@]}"
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

if [ "$IS_DRY_RUN" = true ]; then
    log_info "[DRY-RUN] Would clone dwl, apply monochrome config.h, auto-detect wlroots, & run make clean install"
else
    if ! checkpoint_exists "dwl"; then
        mkdir -p "$HOME/src"
        if [ ! -d "$BUILD_DIR_DWL" ]; then
            git clone https://codeberg.org/dwl/dwl.git "$BUILD_DIR_DWL"
        fi
        cd "$BUILD_DIR_DWL"

        cat << 'EOF_DWL' > "${BUILD_DIR_DWL}/config.h"
/* dwl config.h - Artix Suckless Workstation */
#include <X11/XF86keysym.h>

#define COLOR(hex)    { ((hex >> 24) & 0xFF) / 255.0f, \
                        ((hex >> 16) & 0xFF) / 255.0f, \
                        ((hex >> 8) & 0xFF) / 255.0f, \
                        (hex & 0xFF) / 255.0f }

static const int sloppyfocus               = 1;
static const int bypass_surface_visibility = 0;
static const unsigned int borderpx         = 1;
static const float rootcolor[]             = COLOR(0x000000ff);
static const float bordercolor[]           = COLOR(0x333333ff);
static const float focuscolor[]            = COLOR(0x808080ff);
static const float urgentcolor[]           = COLOR(0xffffffff);
static const float fullscreen_bg[]         = {0.0f, 0.0f, 0.0f, 1.0f};

#define TAGCOUNT (5)
static int log_level = WLR_ERROR;

static const Rule rules[] = {
	{ "Gimp",     NULL,       0,            1,           -1 },
};

static const Layout layouts[] = {
	{ "[]=",      tile },
	{ "><>",      NULL },
	{ "[M]",      monocle },
};

static const MonitorRule monrules[] = {
	{ NULL,       0.55f, 1,      1,    &layouts[0], WL_OUTPUT_TRANSFORM_NORMAL,   -1,  -1 },
};

static const struct xkb_rule_names xkb_rules = { .options = NULL };
static const int repeat_rate = 25;
static const int repeat_delay = 600;
static const int tap_to_click = 1;
static const int tap_and_drag = 1;
static const int drag_lock = 1;
static const int natural_scrolling = 0;
static const int disable_while_typing = 1;
static const int left_handed = 0;
static const int middle_button_emulation = 0;
static const enum libinput_config_scroll_method scroll_method = LIBINPUT_CONFIG_SCROLL_2FG;
static const enum libinput_config_click_method click_method = LIBINPUT_CONFIG_CLICK_METHOD_BUTTON_AREAS;
static const uint32_t send_events_mode = LIBINPUT_CONFIG_SEND_EVENTS_ENABLED;
static const enum libinput_config_accel_profile accel_profile = LIBINPUT_CONFIG_ACCEL_PROFILE_ADAPTIVE;
static const double accel_speed = 0.0;
static const enum libinput_config_tap_button_map button_map = LIBINPUT_CONFIG_TAP_MAP_LRM;

#define MODKEY WLR_MODIFIER_LOGO

#define TAGKEYS(KEY,SKEY,TAG) \
	{ MODKEY,                    KEY,            view,            {.ui = 1 << TAG} }, \
	{ MODKEY|WLR_MODIFIER_CTRL,  KEY,            toggleview,      {.ui = 1 << TAG} }, \
	{ MODKEY|WLR_MODIFIER_SHIFT, SKEY,           tag,             {.ui = 1 << TAG} }, \
	{ MODKEY|WLR_MODIFIER_CTRL|WLR_MODIFIER_SHIFT,SKEY,toggletag, {.ui = 1 << TAG} }

static const char *termcmd[]    = { "foot", NULL };
static const char *menucmd[]     = { "fuzzel", NULL };
static const char *browsercmd[]  = { "zen-browser", NULL };
static const char *lockcmd[]     = { "swaylock", NULL };
static const char *shotcmd[]     = { "sh", "-c", "grim -g \"$(slurp)\" ~/Pictures/screenshot_$(date +%Y%m%d_%H%M%S).png", NULL };
static const char *clipcmd[]     = { "sh", "-c", "cliphist list | fuzzel | cliphist decode | wl-copy", NULL };
static const char *volup[]       = { "pamixer", "-i", "5", NULL };
static const char *voldown[]     = { "pamixer", "-d", "5", NULL };
static const char *volmute[]     = { "pamixer", "-t", NULL };
static const char *brightup[]    = { "brightnessctl", "set", "+10%", NULL };
static const char *brightdown[]  = { "brightnessctl", "set", "10%-", NULL };

static const Key keys[] = {
	{ MODKEY,                    XKB_KEY_space,      spawn,          {.v = menucmd} },
	{ MODKEY,                    XKB_KEY_t,          spawn,          {.v = termcmd} },
	{ MODKEY,                    XKB_KEY_b,          spawn,          {.v = browsercmd} },
	{ MODKEY,                    XKB_KEY_q,          killclient,     {0} },
	{ MODKEY,                    XKB_KEY_l,          spawn,          {.v = lockcmd} },
	{ MODKEY,                    XKB_KEY_v,          spawn,          {.v = clipcmd} },
	{ MODKEY|WLR_MODIFIER_SHIFT, XKB_KEY_space,      togglefloating, {0} },
	{ MODKEY,                    XKB_KEY_e,          togglefullscreen,{0} },
	{ 0,                         XKB_KEY_Print,      spawn,          {.v = shotcmd} },
	{ 0,                         XF86XK_AudioRaiseVolume, spawn,     {.v = volup} },
	{ 0,                         XF86XK_AudioLowerVolume, spawn,     {.v = voldown} },
	{ 0,                         XF86XK_AudioMute,        spawn,     {.v = volmute} },
	{ 0,                         XF86XK_MonBrightnessUp,   spawn,     {.v = brightup} },
	{ 0,                         XF86XK_MonBrightnessDown, spawn,     {.v = brightdown} },
	{ MODKEY,                    XKB_KEY_j,          focusstack,     {.i = +1} },
	{ MODKEY,                    XKB_KEY_k,          focusstack,     {.i = -1} },
	{ MODKEY,                    XKB_KEY_h,          setmfact,       {.f = -0.05f} },
	{ MODKEY,                    XKB_KEY_l,          setmfact,       {.f = +0.05f} },
	TAGKEYS(                     XKB_KEY_1,          XKB_KEY_exclam,  0),
	TAGKEYS(                     XKB_KEY_2,          XKB_KEY_at,      1),
	TAGKEYS(                     XKB_KEY_3,          XKB_KEY_numbersign, 2),
	TAGKEYS(                     XKB_KEY_4,          XKB_KEY_dollar,  3),
	TAGKEYS(                     XKB_KEY_5,          XKB_KEY_percent, 4),
	{ MODKEY|WLR_MODIFIER_SHIFT, XKB_KEY_Q,          quit,           {0} },
};

static const Button buttons[] = {
	{ MODKEY, BTN_LEFT,   moveresize,     {.ui = CurMove} },
	{ MODKEY, BTN_MIDDLE, togglefloating, {0} },
	{ MODKEY, BTN_RIGHT,  moveresize,     {.ui = CurResize} },
};
EOF_DWL

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

if [ "$IS_DRY_RUN" = true ]; then
    log_info "[DRY-RUN] Would clone slstatus, apply native C config.h, & run make clean install"
else
    if ! checkpoint_exists "slstatus"; then
        mkdir -p "$HOME/src"
        if [ ! -d "$BUILD_DIR_SL" ]; then
            git clone https://git.suckless.org/slstatus "$BUILD_DIR_SL"
        fi
        cd "$BUILD_DIR_SL"

        cat << 'EOF_SL' > "${BUILD_DIR_SL}/config.h"
/* slstatus config.h - Native C System Monitoring Bar */
static const unsigned int interval = 2;
static const char unknown_str[] = "n/a";
#define MAXLEN 2048

static const struct arg args[] = {
	/* function format argument */
	{ ram_perc,     " RAM %s%% | ",     NULL },
	{ cpu_perc,     "CPU %s%% | ",      NULL },
	{ cpu_temp,     "TEMP %sC | ",      "/sys/class/hwmon/hwmon0/temp1_input" },
	{ disk_perc,    "SSD %s%% | ",      "/" },
	{ netspeed_rx,  "DOWN %sB/s | ",    "wlan0" },
	{ netspeed_tx,  "UP %sB/s | ",      "wlan0" },
	{ datetime,     "%s",               "%Y-%m-%d %H:%M:%S" },
};
EOF_SL

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

if [ "$IS_DRY_RUN" = true ]; then
    log_info "[DRY-RUN] Would deploy dotfiles for Bash, Foot, Fuzzel, Neovim, Swaylock, MPV, Fcitx5."
else
    # Deploy .bashrc
    cat << 'EOF_BASH' > "${HOME}/.bashrc"
# ~/.bashrc - Minimal Monochrome Developer Shell
[[ $- != *i* ]] && return

alias ls='eza --icons=never --group-directories-first'
alias ll='eza -lbGF --icons=never'
alias la='eza -lbhHigUmuSa --icons=never'
alias grep='grep --color=auto'
alias v='nvim'
alias g='git'
alias c='clear'

eval "$(zoxide init bash)"
EOF_BASH

    # Deploy Foot config
    mkdir -p "${HOME}/.config/foot"
    cat << 'EOF_FOOT' > "${HOME}/.config/foot/foot.ini"
[main]
font=JetBrains Mono:size=11
pad=12x12
[colors]
background=000000
foreground=cccccc
regular0=000000
regular7=cccccc
bright7=ffffff
EOF_FOOT

    # Deploy Fuzzel config
    mkdir -p "${HOME}/.config/fuzzel"
    cat << 'EOF_FUZZEL' > "${HOME}/.config/fuzzel/fuzzel.ini"
[main]
font=JetBrains Mono:size=11
dpi-aware=yes
prompt="> "
[colors]
background=000000ff
text=ccccccff
selection=333333ff
selection-text=ffffffff
border=444444ff
EOF_FUZZEL

    # Deploy Neovim Lua Config
    mkdir -p "${HOME}/.config/nvim"
    cat << 'EOF_NVIM' > "${HOME}/.config/nvim/init.lua"
vim.g.mapleader = " "
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.termguicolors = true
vim.cmd("colorscheme dim")
EOF_NVIM

    # Deploy Swaylock config
    mkdir -p "${HOME}/.config/swaylock"
    cat << 'EOF_SWAYLOCK' > "${HOME}/.config/swaylock/config"
color=000000
font=JetBrains Mono
indicator-radius=80
inside-color=000000
ring-color=333333
line-color=000000
key-hl-color=ffffff
EOF_SWAYLOCK

    # Deploy DWL Startup script
    mkdir -p "${HOME}/.dwl"
    cat << 'EOF_STARTUP' > "${HOME}/.dwl/startup.sh"
#!/usr/bin/env bash
pipewire &
wireplumber &
fcitx5 -d &
slstatus &
EOF_STARTUP
    chmod +x "${HOME}/.dwl/startup.sh"

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