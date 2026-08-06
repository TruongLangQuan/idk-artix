#!/usr/bin/env bash
# scripts/healthcheck.sh - Read-Only System Verification & Diagnostic Audit
# Version: 1.0
# READ-ONLY SCRIPT: DOES NOT MODIFY SYSTEM STATE

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

source "${SCRIPT_DIR}/lib/logging.sh"
source "${SCRIPT_DIR}/lib/validation.sh"

show_help() {
    cat << EOF
Usage: $(basename "$0") [OPTIONS]

Options:
  -h, --help       Show this help message.

Description:
  Read-only system diagnostic tool. Inspects hardware specs, kernel microcode,
  Btrfs subvolumes, OpenRC services, Wayland/dwl state, PipeWire audio,
  NetworkManager, UFW firewall, and Fail2Ban without making any changes.
EOF
}

for arg in "$@"; do
    if [ "$arg" = "--help" ] || [ "$arg" = "-h" ]; then
        show_help
        exit 0
    fi
done

log_info "=================================================="
log_info "      ARTIX SUCKLESS SYSTEM HEALTHCHECK REPORT    "
log_info "=================================================="

PASS_COUNT=0
WARN_COUNT=0
FAIL_COUNT=0

report_status() {
    local status="$1"
    local category="$2"
    local details="$3"

    case "$status" in
        "PASS")
            log_info "[PASS] [${category}] ${details}"
            ((PASS_COUNT++)) || true
            ;;
        "WARN")
            log_warning "[WARN] [${category}] ${details}"
            ((WARN_COUNT++)) || true
            ;;
        "FAIL")
            log_error "[FAIL] [${category}] ${details}"
            ((FAIL_COUNT++)) || true
            ;;
    esac
}

# 1. Kernel & Microcode
log_info "--- Checking Kernel & Microcode ---"
KERNEL_VER=$(uname -r)
report_status "PASS" "Kernel" "Running kernel version: ${KERNEL_VER}"

if dmesg 2>/dev/null | grep -i "microcode" >/dev/null 2>&1; then
    report_status "PASS" "Microcode" "Intel CPU microcode loaded successfully."
else
    report_status "WARN" "Microcode" "Microcode log not found in dmesg (or dmesg restricted)."
fi

# 2. Hardware: CPU, GPU, RAM, Disk
log_info "--- Checking Hardware ---"
if check_command_installed lscpu; then
    CPU_NAME=$(lscpu | grep "Model name:" | sed 's/Model name:[ \t]*//')
    report_status "PASS" "CPU" "${CPU_NAME}"
fi

if check_command_installed free; then
    RAM_TOTAL=$(free -h | awk '/Mem:/ {print $2}')
    RAM_AVAIL=$(free -h | awk '/Mem:/ {print $7}')
    report_status "PASS" "RAM" "Total: ${RAM_TOTAL}, Available: ${RAM_AVAIL}"
fi

if check_command_installed glxinfo; then
    RENDERER=$(glxinfo 2>/dev/null | grep "OpenGL renderer" | sed 's/OpenGL renderer string:[ \t]*//' || echo "Unknown")
    report_status "PASS" "GPU" "Renderer: ${RENDERER}"
else
    report_status "WARN" "GPU" "glxinfo tool not installed."
fi

# 3. Filesystem: Btrfs
log_info "--- Checking Filesystem ---"
ROOT_FSTYPE=$(findmnt -n -o FSTYPE / || echo "Unknown")
if [ "$ROOT_FSTYPE" = "btrfs" ]; then
    report_status "PASS" "Filesystem" "Root filesystem is Btrfs."
else
    report_status "WARN" "Filesystem" "Root filesystem is ${ROOT_FSTYPE} (expected btrfs)."
fi

# 4. OpenRC Services
log_info "--- Checking OpenRC Services ---"
if check_command_installed rc-status; then
    SERVICES=("dbus" "seatd" "NetworkManager" "bluetooth" "power-profiles-daemon")
    for srv in "${SERVICES[@]}"; do
        if rc-status default 2>/dev/null | grep -q "$srv"; then
            report_status "PASS" "OpenRC" "Service '$srv' active in default runlevel."
        else
            report_status "WARN" "OpenRC" "Service '$srv' not active in default runlevel."
        fi
    done
else
    report_status "WARN" "OpenRC" "rc-status command not available."
fi

# 5. Display & Wayland Environment
log_info "--- Checking Display Environment ---"
if [ "${XDG_SESSION_TYPE:-}" = "wayland" ] || [ -n "${WAYLAND_DISPLAY:-}" ]; then
    report_status "PASS" "Wayland" "Wayland session detected (${WAYLAND_DISPLAY:-wayland-0})."
else
    report_status "WARN" "Wayland" "Wayland session environment variable not currently active."
fi

if check_command_installed dwl; then
    report_status "PASS" "dwl" "dwl binary available: $(which dwl)"
else
    report_status "WARN" "dwl" "dwl binary not found in PATH."
fi

if check_command_installed slstatus; then
    report_status "PASS" "slstatus" "slstatus binary available: $(which slstatus)"
else
    report_status "WARN" "slstatus" "slstatus binary not found in PATH."
fi

# 6. Audio System
log_info "--- Checking Audio System ---"
if check_command_installed wpctl; then
    if wpctl status >/dev/null 2>&1; then
        report_status "PASS" "Audio" "PipeWire & WirePlumber running normally."
    else
        report_status "WARN" "Audio" "wpctl unable to connect to PipeWire daemon."
    fi
else
    report_status "WARN" "Audio" "wpctl command not installed."
fi

# 7. Security Status
log_info "--- Checking Security Status ---"
if check_command_installed ufw; then
    UFW_STAT=$(sudo -n ufw status 2>/dev/null | grep "Status:" || echo "Status: inactive / sudo required")
    report_status "PASS" "Security" "UFW Firewall ${UFW_STAT}"
else
    report_status "WARN" "Security" "UFW firewall tool not installed."
fi

if check_command_installed fail2ban-client; then
    report_status "PASS" "Security" "Fail2Ban client available."
else
    report_status "WARN" "Security" "Fail2Ban client not installed."
fi

# 8. Markdown Documentation Package Audit
log_info "--- Checking Markdown Documentation Packages ---"
MD_FILE="${PROJECT_ROOT}/PACKAGE_LIST.md"
if [ -f "$MD_FILE" ]; then
    RAW_WORDS=$(sed -n "/\`\`\`/,/\`\`\`/p" "$MD_FILE" | grep -v "\`\`\`" | grep -v "^#" | sed "s/#.*//" | xargs -n1 | sort -u || true)
    MD_MISSING=()
    MD_INSTALLED_COUNT=0
    for word in $RAW_WORDS; do
        if pacman -Qi "$word" >/dev/null 2>&1; then
            ((MD_INSTALLED_COUNT++))
        elif pacman -Si "$word" >/dev/null 2>&1; then
            MD_MISSING+=("$word")
        fi
    done
    if [ ${#MD_MISSING[@]} -eq 0 ]; then
        report_status "PASS" "Markdown Packages" "All ${MD_INSTALLED_COUNT} packages in PACKAGE_LIST.md are fully installed."
    else
        report_status "WARN" "Markdown Packages" "${#MD_MISSING[@]} package(s) listed in Markdown are missing: ${MD_MISSING[*]}"
    fi
fi

log_info "=================================================="
log_info "Summary: PASS: ${PASS_COUNT} | WARN: ${WARN_COUNT} | FAIL: ${FAIL_COUNT}"
log_info "Healthcheck complete."
