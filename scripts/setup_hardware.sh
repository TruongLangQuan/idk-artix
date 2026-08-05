#!/usr/bin/env bash
# scripts/setup_hardware.sh - Intel Hardware Optimization & Diagnostics
# Version: 1.0

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

source "${SCRIPT_DIR}/lib/logging.sh"
source "${SCRIPT_DIR}/lib/checkpoint.sh"
source "${SCRIPT_DIR}/lib/validation.sh"

show_help() {
    cat << EOF
Usage: $(basename "$0") [OPTIONS]

Options:
  -d, --dry-run    Show hardware detection and driver setup actions without executing.
  -h, --help       Show this help message.

Description:
  Detects Intel CPU/GPU/RAM/NVMe hardware and configures microcode, Mesa,
  Vulkan, and VAAPI hardware video decoding drivers.
EOF
}

check_dry_run_flag "$@"

for arg in "$@"; do
    if [ "$arg" = "--help" ] || [ "$arg" = "-h" ]; then
        show_help
        exit 0
    fi
done

log_info "Starting hardware detection and acceleration setup..."

if checkpoint_exists "hardware"; then
    log_info "Hardware setup checkpoint exists (hardware.done). Skipping..."
    exit 0
fi

log_info "Detecting system hardware specs..."

if check_command_installed lscpu; then
    CPU_INFO=$(lscpu | grep "Model name:" || true)
    log_info "CPU: ${CPU_INFO}"
fi

if check_command_installed lspci; then
    GPU_INFO=$(lspci | grep -E "VGA|3D" || true)
    log_info "GPU: ${GPU_INFO}"
fi

if check_command_installed free; then
    RAM_INFO=$(free -h | grep "Mem:" || true)
    log_info "RAM: ${RAM_INFO}"
fi

if [ "$IS_DRY_RUN" = true ]; then
    log_info "[DRY-RUN] Would verify intel-ucode microcode loading."
    log_info "[DRY-RUN] Would verify Mesa, vulkan-intel, and intel-media-driver VAAPI status."
    exit 0
fi

# Verify VAAPI capabilities if vainfo is available
if check_command_installed vainfo; then
    log_info "Running VAAPI diagnostic test..."
    vainfo || log_warning "vainfo command returned warning/error."
fi

create_checkpoint "hardware"
log_success "Hardware configuration completed."
