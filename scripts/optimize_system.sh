#!/usr/bin/env bash
# scripts/optimize_system.sh - System Performance & Resource Optimization
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
  -d, --dry-run    Show optimization settings without modifying system configuration.
  -h, --help       Show this help message.

Description:
  Configures zram generator, NVMe trim schedule, power-profiles-daemon,
  ccache build cache, and performs service audit.
EOF
}

check_dry_run_flag "$@"

for arg in "$@"; do
    if [ "$arg" = "--help" ] || [ "$arg" = "-h" ]; then
        show_help
        exit 0
    fi
done

log_info "Starting system optimization..."

if checkpoint_exists "optimization"; then
    log_info "Optimization checkpoint exists (optimization.done). Skipping..."
    exit 0
fi

if [ "$IS_DRY_RUN" = true ]; then
    log_info "[DRY-RUN] zram: Configure /etc/systemd/zram-generator.conf (or zram service) for 8GB"
    log_info "[DRY-RUN] NVMe trim: Schedule fstrim weekly"
    log_info "[DRY-RUN] Power profile: Set power-profiles-daemon to balanced"
    log_info "[DRY-RUN] ccache: Set CCACHE_DIR=$HOME/.cache/ccache"
    exit 0
fi

# Configure zram-generator if directory exists
if [ -d "/etc/systemd" ]; then
    log_info "Setting up zram-generator configuration..."
    sudo bash -c 'cat << EOF > /etc/systemd/zram-generator.conf
[zram0]
zram-size = ram / 2
compression-algorithm = zstd
EOF'
fi

# Set power profile if power-profiles-daemon CLI is available
if check_command_installed powerprofilesctl; then
    log_info "Setting power profile to balanced..."
    powerprofilesctl set balanced || log_warning "Failed to set power profile."
fi

# Setup ccache directory
mkdir -p "${HOME}/.cache/ccache"

create_checkpoint "optimization"
log_success "System optimization completed."
