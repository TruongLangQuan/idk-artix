#!/usr/bin/env bash
# scripts/setup_network.sh - Network, Bluetooth & Seatd Permissions Setup
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
  -d, --dry-run    Show network and user group assignment without executing.
  -h, --help       Show this help message.

Description:
  Configures user group permissions (seat, video, input, wheel) for seatd and NetworkManager.
EOF
}

check_dry_run_flag "$@"

for arg in "$@"; do
    if [ "$arg" = "--help" ] || [ "$arg" = "-h" ]; then
        show_help
        exit 0
    fi
done

log_info "Starting network & seatd permissions setup..."

if checkpoint_exists "network"; then
    log_info "Network setup checkpoint exists (network.done). Skipping..."
    exit 0
fi

TARGET_USER="${USER:-truonglangquan}"
GROUPS=("wheel" "video" "input" "seat" "audio")

if [ "$IS_DRY_RUN" = true ]; then
    log_info "[DRY-RUN] User ${TARGET_USER} would be added to groups: ${GROUPS[*]}"
    exit 0
fi

log_info "Adding user ${TARGET_USER} to required groups..."
for grp in "${GROUPS[@]}"; do
    sudo usermod -aG "$grp" "$TARGET_USER" || log_warning "Failed to add user to group $grp"
done

create_checkpoint "network"
log_success "Network & user permissions setup completed."
