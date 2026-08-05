#!/usr/bin/env bash
# scripts/bootstrap.sh - Artix Suckless Master Bootstrap Automation Script
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
  -d, --dry-run    Run all sub-scripts in dry-run mode without modifying the system.
  -h, --help       Show this help message.

Description:
  Master automation orchestrator for Artix Linux OpenRC Suckless Workstation setup.
  Runs package installation, Btrfs, OpenRC services, hardware driver configuration,
  Wayland/dwl/slstatus compilation, dotfiles deployment, security, optimization, and healthchecks.
EOF
}

check_dry_run_flag "$@"

for arg in "$@"; do
    if [ "$arg" = "--help" ] || [ "$arg" = "-h" ]; then
        show_help
        exit 0
    fi
done

log_info "=================================================="
log_info " Starting Artix Linux OpenRC Workstation Bootstrap "
log_info "=================================================="

if [ "$IS_DRY_RUN" = true ]; then
    log_info "RUNNING IN DRY-RUN MODE. NO SYSTEM CHANGES WILL BE MADE."
fi

EXTRA_FLAGS=""
if [ "$IS_DRY_RUN" = true ]; then
    EXTRA_FLAGS="--dry-run"
fi

run_stage() {
    local script_name="$1"
    local stage_title="$2"

    log_info "--------------------------------------------------"
    log_info "Executing Stage: ${stage_title} (${script_name})"
    log_info "--------------------------------------------------"

    local script_path="${SCRIPT_DIR}/${script_name}"
    if [ -f "$script_path" ]; then
        bash "$script_path" $EXTRA_FLAGS
    else
        log_error "Script file not found: ${script_path}"
        exit 1
    fi
}

if [ "${1:-}" = "--disk" ] || [ "${1:-}" = "--stage0" ] || ([ -f "/etc/artix-release" ] && grep -qi "live" /etc/artix-release 2>/dev/null); then
    run_stage "setup_disk.sh" "Live ISO Disk Setup & Base System Installation"
fi

run_stage "install_packages.sh" "Package Installation"
run_stage "setup_btrfs.sh"       "Btrfs Filesystem Checks"
run_stage "setup_openrc.sh"      "OpenRC Services Setup"
run_stage "setup_hardware.sh"    "Hardware Drivers & Microcode"
run_stage "setup_network.sh"     "Network & User Permissions"
run_stage "setup_audio.sh"       "PipeWire Audio Infrastructure"
run_stage "setup_security.sh"    "UFW & Fail2Ban Security"
run_stage "build_dwl.sh"         "Compiling dwl Compositor"
run_stage "build_slstatus.sh"    "Compiling slstatus Status Bar"
run_stage "deploy_dotfiles.sh"   "Deploying User Dotfiles"
run_stage "optimize_system.sh"   "System Optimization & zram"
run_stage "healthcheck.sh"       "System Healthcheck Diagnostics"

log_info "=================================================="
log_success "Bootstrap sequence finished successfully!"
log_info "=================================================="
