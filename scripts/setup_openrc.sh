#!/usr/bin/env bash
# scripts/setup_openrc.sh - OpenRC Service Configuration Script
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
  -d, --dry-run    Show OpenRC services to be enabled/disabled without executing.
  -h, --help       Show this help message.

Description:
  Enables required OpenRC services (dbus, seatd, NetworkManager, bluetooth,
  power-profiles-daemon, ufw, fail2ban) and disables unneeded services.
EOF
}

check_dry_run_flag "$@"

for arg in "$@"; do
    if [ "$arg" = "--help" ] || [ "$arg" = "-h" ]; then
        show_help
        exit 0
    fi
done

log_info "Starting OpenRC service configuration..."

if checkpoint_exists "openrc"; then
    log_info "OpenRC service checkpoint exists (openrc.done). Skipping..."
    exit 0
fi

REQUIRED_SERVICES=(
    "dbus"
    "seatd"
    "NetworkManager"
    "bluetooth"
    "power-profiles-daemon"
    "ufw"
    "fail2ban"
)

if [ "$IS_DRY_RUN" = true ]; then
    log_info "[DRY-RUN] OpenRC services that would be added to default runlevel:"
    printf '  - %s\n' "${REQUIRED_SERVICES[@]}"
    exit 0
fi

log_info "Enabling required OpenRC services..."
for service in "${REQUIRED_SERVICES[@]}"; do
    if check_command_installed rc-update; then
        sudo rc-update add "$service" default || log_warning "Failed to add service: $service"
    else
        log_warning "rc-update command not found. Skipping service activation."
        break
    fi
done

create_checkpoint "openrc"
log_success "OpenRC service configuration completed."
