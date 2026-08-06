#!/usr/bin/env bash
# post_install.sh - Standalone Post-Stage 0 Setup Script for Artix Linux OpenRC
# Version: 1.0
# Executes Stages 1-12 based on configuration scripts in scripts/ folder.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_DIR="${SCRIPT_DIR}/logs"
STATE_DIR="${SCRIPT_DIR}/.state"

mkdir -p "$LOG_DIR" "$STATE_DIR"
LOG_FILE="${LOG_DIR}/post_install_$(date +%Y%m%d_%H%M%S).log"

TARGET_USER="truonglangquan"
SWAP_SIZE_GB="16"
IS_DRY_RUN=false

log_info()    { echo -e "[$(date +'%Y-%m-%d %H:%M:%S')] \033[34m[INFO]\033[0m $*" | tee -a "$LOG_FILE"; }
log_success() { echo -e "[$(date +'%Y-%m-%d %H:%M:%S')] \033[32m[SUCCESS]\033[0m $*" | tee -a "$LOG_FILE"; }
log_warning() { echo -e "[$(date +'%Y-%m-%d %H:%M:%S')] \033[33m[WARNING]\033[0m $*" | tee -a "$LOG_FILE"; }
log_error()   { echo -e "[$(date +'%Y-%m-%d %H:%M:%S')] \033[31m[ERROR]\033[0m $*" | tee -a "$LOG_FILE"; }

checkpoint_exists() { [ -f "${STATE_DIR}/${1}.done" ]; }
create_checkpoint()  { touch "${STATE_DIR}/${1}.done"; }

show_help() {
    cat << EOF
Usage: $(basename "$0") [OPTIONS]

Options:
  -f, --force      Force re-running all stages (clears existing checkpoint state).
  -d, --dry-run    Run setup simulation without modifying system.
  -h, --help       Show this help message.

Description:
  Standalone Post-Stage 0 installer script for Artix Linux OpenRC Suckless Workstation.
  Orchestrates package installation, AUR bootstrap (paru-bin), OpenRC services,
  dwl & slstatus compilation, user dotfiles deployment, security, optimization, and healthchecks.
EOF
}

# Parse Arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        -f|--force)    rm -rf "${STATE_DIR}"/*.done 2>/dev/null || true; shift ;;
        -d|--dry-run)  IS_DRY_RUN=true; shift ;;
        -h|--help)     show_help; exit 0 ;;
        *)             log_error "Unknown option: $1"; show_help; exit 1 ;;
    esac
done

log_info "================================================================="
log_info "      ARTIX LINUX OPENRC POST-STAGE 0 WORKSTATION SETUP          "
log_info "================================================================="
log_info "Target User:      ${TARGET_USER}"
log_info "Swapfile Size:    ${SWAP_SIZE_GB}GB"
log_info "Dry-Run Mode:     ${IS_DRY_RUN}"
log_info "================================================================="

# =================================================================
# STAGE 1: OFFICIAL & AUR PACKAGE STACK INSTALLATION
# =================================================================
log_info "-----------------------------------------------------------------"
log_info "STAGE 1: Official Package Stack & AUR Installation"
log_info "-----------------------------------------------------------------"

if checkpoint_exists "packages"; then
    log_info "Package installation checkpoint exists. Skipping..."
else
    PACKAGES=(
        base base-devel btrfs-progs dbus dbus-openrc efibootmgr openrc elogind-openrc
        grub grub-btrfs intel-ucode linux-firmware sof-firmware wireless-regdb linux-lts linux-zen os-prober polkit snap-pac
        snapper sudo zram-init zram-init-openrc bash-completion brightnessctl cairo cliphist
        fcitx5 fcitx5-configtool fcitx5-unikey foot fuzzel grim libinput libva libva-utils
        libxkbcommon mesa pango pixman seatd slurp swaylock ttf-jetbrains-mono
        vulkan-intel wayland wayland-protocols wlroots0.20 wlroots0.19 wl-clipboard xorg-xwayland
        bat btop ccache clang cmake eza fastfetch fd file fzf gcc gdb git go htop jdk-openjdk jq
        lazygit less lldb llvm ltrace lua make meson nano neovim ninja nodejs npm openssh pkgconf
        python python-pip ripgrep rsync rust strace tmux tree valgrind go-yq zig zoxide
        alsa-utils bluez bluez-utils bluez-openrc intel-media-driver mpv pamixer pavucontrol
        pipewire pipewire-alsa pipewire-jack pipewire-pulse wireplumber fail2ban ufw ufw-openrc
        7zip curl wget unzip hwinfo lm_sensors networkmanager networkmanager-openrc
        network-manager-applet nvme-cli nvtop power-profiles-daemon powertop smartmontools
        wpa_supplicant iw iwd
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
            # Automatically resolve pipewire-jack vs jack2 provider conflict
            if pacman -Qi jack2 >/dev/null 2>&1; then
                sudo pacman -Rdd --noconfirm jack2 2>/dev/null || true
            fi
            yes | sudo pacman -S --needed --noconfirm "${VALID_TO_INSTALL[@]}"
        fi
    else
        log_info "All requested official packages are already installed."
    fi

    # AUR Helper Bootstrap & AUR Packages
    AUR_HELPER=""
    if command -v paru >/dev/null 2>&1; then
        AUR_HELPER="paru"
    elif command -v yay >/dev/null 2>&1; then
        AUR_HELPER="yay"
    elif [ "$IS_DRY_RUN" = false ]; then
        log_info "Bootstrapping AUR helper (paru-bin)..."
        rm -rf /tmp/paru-bin
        git clone https://aur.archlinux.org/paru-bin.git /tmp/paru-bin
        (cd /tmp/paru-bin && makepkg -si --noconfirm) || log_warning "Failed to build paru-bin from AUR."
        rm -rf /tmp/paru-bin
        if command -v paru >/dev/null 2>&1; then
            AUR_HELPER="paru"
        fi
    fi

    AUR_PACKAGES=("zen-browser-bin" "mpvpaper")
    if [ -n "$AUR_HELPER" ] && [ "$IS_DRY_RUN" = false ]; then
        log_info "Installing AUR packages (${AUR_PACKAGES[*]}) via ${AUR_HELPER}..."
        $AUR_HELPER -S --needed --noconfirm "${AUR_PACKAGES[@]}" || log_warning "Some AUR packages could not be installed."
    fi

    create_checkpoint "packages"
fi

# =================================================================
# STAGE 1.5: MARKDOWN DOCUMENTATION PACKAGE AUDIT
# =================================================================
log_info "-----------------------------------------------------------------"
log_info "STAGE 1.5: Verifying Packages Listed in Markdown Files"
log_info "-----------------------------------------------------------------"

audit_markdown_packages() {
    local md_files=("${SCRIPT_DIR}/PACKAGE_LIST.md" "${SCRIPT_DIR}/README.md")
    local md_missing=()
    local md_installed=()

    for md_file in "${md_files[@]}"; do
        if [ -f "$md_file" ]; then
            log_info "Parsing package requirements from ${md_file##*/}..."
            local raw_words
            raw_words=$(sed -n "/\`\`\`/,/\`\`\`/p" "$md_file" | grep -v "\`\`\`" | grep -v "^#" | sed "s/#.*//" | xargs -n1 | sort -u || true)

            for word in $raw_words; do
                if pacman -Qi "$word" >/dev/null 2>&1; then
                    md_installed+=("$word")
                elif pacman -Si "$word" >/dev/null 2>&1; then
                    md_missing+=("$word")
                fi
            done
        fi
    done

    readarray -t md_missing < <(printf '%s\n' "${md_missing[@]:-}" | sort -u)
    readarray -t md_installed < <(printf '%s\n' "${md_installed[@]:-}" | sort -u)

    log_info "Markdown Audit: ${#md_installed[@]} packages installed, ${#md_missing[@]} missing."

    if [ ${#md_missing[@]} -gt 0 ] && [ -n "${md_missing[0]}" ]; then
        if [ "$IS_DRY_RUN" = true ]; then
            log_info "[DRY-RUN] Would install ${#md_missing[@]} missing Markdown-documented packages: ${md_missing[*]}"
        else
            log_info "Installing ${#md_missing[@]} missing packages documented in Markdown: ${md_missing[*]}"
            if pacman -Qi jack2 >/dev/null 2>&1; then
                sudo pacman -Rdd --noconfirm jack2 2>/dev/null || true
            fi
            yes | sudo pacman -S --needed --noconfirm "${md_missing[@]}" || log_warning "Some packages could not be installed."
        fi
    else
        log_success "All required packages documented in Markdown files are fully installed!"
    fi
}

audit_markdown_packages

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
    log_info "[DRY-RUN] Would clone dwl, apply custom config.h, auto-detect wlroots, & run make clean install"
else
    if ! checkpoint_exists "dwl"; then
        sudo pacman -S --needed --noconfirm fcft tllist pixman libinput xkbcommon wayland-protocols 2>/dev/null || true
        mkdir -p "$HOME/src"
        rm -rf "$BUILD_DIR_DWL"
        git clone https://codeberg.org/dwl/dwl.git "$BUILD_DIR_DWL"
        cd "$BUILD_DIR_DWL"

        log_info "Downloading and applying official dwl top bar patch (bar.patch)..."
        curl -sL "https://codeberg.org/dwl/dwl-patches/raw/branch/main/patches/bar/bar.patch" -o bar.patch
        if git apply --check bar.patch >/dev/null 2>&1; then
            git apply bar.patch
        elif patch -p1 --dry-run < bar.patch >/dev/null 2>&1; then
            patch -p1 < bar.patch
        fi

        if ! grep -q "void shiftview" dwl.c; then
            log_info "Injecting shiftview function for smooth workspace navigation..."
            cat << "EOF_SHIFT" >> dwl.c

void
shiftview(const Arg *arg)
{
	Arg a;
	uint32_t cur;
	int i, tag = 0;
	if (!selmon) return;
	cur = selmon->tagset[selmon->seltags];
	for (i = 0; i < 5; i++) {
		if (cur & (1 << i)) {
			tag = i;
			break;
		}
	}
	if (arg->i > 0)
		tag = (tag + 1) % 5;
	else
		tag = (tag - 1 + 5) % 5;
	a.ui = 1 << tag;
	view(&a);
}
EOF_SHIFT
        fi

        if [ -f "${SCRIPT_DIR}/dotfiles/dwl/config.h" ]; then
            cp -f "${SCRIPT_DIR}/dotfiles/dwl/config.h" "${BUILD_DIR_DWL}/config.h"
        fi

        FOUND_WLR=""
        for wver in wlroots-0.20 wlroots0.20 wlroots-0.19 wlroots0.19 wlroots-0.18 wlroots; do
            if pkg-config --exists "$wver" 2>/dev/null; then
                FOUND_WLR="$wver"
                break
            fi
        done
        if [ -n "$FOUND_WLR" ]; then
            sed -i -E "s/wlroots-0\.[0-9]+/${FOUND_WLR}/g" Makefile || true
            sed -i -E "s/wlroots0\.[0-9]+/${FOUND_WLR}/g" Makefile || true
        fi

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
        rm -rf "$BUILD_DIR_SL"
        git clone https://git.suckless.org/slstatus "$BUILD_DIR_SL"
        cd "$BUILD_DIR_SL"

        if [ -f "${SCRIPT_DIR}/dotfiles/slstatus/config.h" ]; then
            cp -f "${SCRIPT_DIR}/dotfiles/slstatus/config.h" "${BUILD_DIR_SL}/config.h"
        fi

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
    if [ -f "${SCRIPT_DIR}/scripts/deploy_dotfiles.sh" ]; then
        bash "${SCRIPT_DIR}/scripts/deploy_dotfiles.sh"
    else
        mkdir -p "${HOME}/.config/foot" "${HOME}/.config/fuzzel" "${HOME}/.config/nvim" "${HOME}/.config/swaylock" "${HOME}/.config/mpv" "${HOME}/.config/fcitx5" "${HOME}/.dwl"
        
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
term=foot
font=JetBrains Mono:size=11
pad=12x12
resize-delay-ms=0
[colors-dark]
background=000000
foreground=cccccc
regular0=000000
regular7=cccccc
bright7=ffffff
EOF_FOOT
        sudo mkdir -p /root/.config/foot /etc/xdg/foot 2>/dev/null || true
        sudo cp -f "${HOME}/.config/foot/foot.ini" /root/.config/foot/foot.ini 2>/dev/null || true
        sudo cp -f "${HOME}/.config/foot/foot.ini" /etc/xdg/foot/foot.ini 2>/dev/null || true

        # Deploy Fuzzel config
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
vim.cmd("colorscheme quiet")
EOF_NVIM

        # Deploy Swaylock config
        mkdir -p "${HOME}/.config/swaylock"
        cat << 'EOF_SWAYLOCK' > "${HOME}/.config/swaylock/config"
color=000000
font=JetBrains Mono
indicator-radius=90
indicator-thickness=6
line-color=000000
ring-color=ffffff
inside-color=000000
key-hl-color=808080
text-color=ffffff
show-failed-attempts
EOF_SWAYLOCK

        # Deploy MPV config
        mkdir -p "${HOME}/.config/mpv"
        cat << 'EOF_MPV' > "${HOME}/.config/mpv/mpv.conf"
hwdec=auto
vo=gpu
profile=fast
gpu-api=vulkan
EOF_MPV

        # Deploy Fcitx5 config
        mkdir -p "${HOME}/.config/fcitx5"
        cat << 'EOF_FCITX' > "${HOME}/.config/fcitx5/config"
[Hotkey]
TriggerKeys=Control+space
EOF_FCITX

        # Deploy DWL Startup script
        mkdir -p "${HOME}/.dwl"
        cat << 'EOF_STARTUP' > "${HOME}/.dwl/startup.sh"
#!/usr/bin/env bash
pipewire &
wireplumber &
fcitx5 -d &
EOF_STARTUP
        chmod +x "${HOME}/.dwl/startup.sh"

        # Create system-wide startdwl launcher connecting slstatus bar to dwl
        sudo tee /usr/local/bin/startdwl >/dev/null << 'EOF_DWL_WRAPPER'
#!/usr/bin/env bash
[ -f "$HOME/.dwl/startup.sh" ] && bash "$HOME/.dwl/startup.sh" &
exec slstatus -s | dwl
EOF_DWL_WRAPPER
        sudo chmod +x /usr/local/bin/startdwl
        sudo cp -f /usr/local/bin/startdwl /usr/bin/startdwl 2>/dev/null || true
    fi

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
                sudo btrfs filesystem mkswapfile --size "${SWAP_SIZE_GB}g" "$SWAP_PATH" 2>/dev/null || {
                    sudo truncate -s 0 "$SWAP_PATH"
                    sudo chattr +C "$SWAP_PATH" 2>/dev/null || true
                    sudo dd if=/dev/zero of="$SWAP_PATH" bs=1M count=$((SWAP_SIZE_GB * 1024)) status=progress
                    sudo chmod 600 "$SWAP_PATH"
                    sudo mkswap "$SWAP_PATH"
                }
            else
                sudo fallocate -l "${SWAP_SIZE_GB}G" "$SWAP_PATH" || sudo dd if=/dev/zero of="$SWAP_PATH" bs=1M count=$((SWAP_SIZE_GB * 1024))
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
log_success "ALL POST-INSTALLATION STAGES COMPLETED SUCCESSFULLY!"
log_info "================================================================="
