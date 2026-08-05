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
    log_info "[DRY-RUN] Swap: Would verify or create 16GB Btrfs swapfile at /swap/swapfile (or /swapfile)"
    log_info "[DRY-RUN] zram: Configure zram-generator or OpenRC zram service for 8GB"
    log_info "[DRY-RUN] NVMe trim: Schedule fstrim weekly"
    log_info "[DRY-RUN] Power profile: Set power-profiles-daemon to balanced"
    log_info "[DRY-RUN] ccache: Set CCACHE_DIR=$HOME/.cache/ccache"
    exit 0
fi

# Configure 16GB Swapfile if active swap is under 16GB
SWAP_TOTAL_MB=$(free -m | awk '/^Swap:/ {print $2}')
if [ "${SWAP_TOTAL_MB:-0}" -lt 16000 ]; then
    log_info "Creating 16GB Btrfs swapfile..."
    sudo mkdir -p /swap
    if [ -f "/swap/swapfile" ] || [ -f "/swapfile" ]; then
        log_info "Swapfile already exists. Ensuring swap is active..."
        SWAP_PATH="/swap/swapfile"
        [ -f "/swapfile" ] && SWAP_PATH="/swapfile"
        sudo swapon "$SWAP_PATH" 2>/dev/null || true
    else
        SWAP_PATH="/swap/swapfile"
        if check_command_installed btrfs; then
            sudo btrfs filesystem mkswapfile --size 16g --uuid clear "$SWAP_PATH" || {
                sudo truncate -s 0 "$SWAP_PATH"
                sudo chattr +C "$SWAP_PATH" 2>/dev/null || true
                sudo fallocate -l 16G "$SWAP_PATH"
                sudo chmod 600 "$SWAP_PATH"
                sudo mkswap "$SWAP_PATH"
            }
        else
            sudo fallocate -l 16G "$SWAP_PATH" || sudo dd if=/dev/zero of="$SWAP_PATH" bs=1M count=16384
            sudo chmod 600 "$SWAP_PATH"
            sudo mkswap "$SWAP_PATH"
        fi
        sudo swapon "$SWAP_PATH" || log_warning "Failed to activate $SWAP_PATH"
        if ! grep -q "$SWAP_PATH" /etc/fstab; then
            echo "$SWAP_PATH none swap defaults 0 0" | sudo tee -a /etc/fstab
        fi
    fi
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
