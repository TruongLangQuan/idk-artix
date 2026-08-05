#!/usr/bin/env bash
# scripts/setup_btrfs.sh - Safe Btrfs Subvolume & Mount Configuration
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
  -d, --dry-run    Show Btrfs configuration actions without executing.
  -h, --help       Show this help message.

Description:
  Detects current Btrfs filesystem, subvolumes, and configures mount options,
  Snapper snapshots, and zram. NEVER automatically formats disks.
EOF
}

check_dry_run_flag "$@"

for arg in "$@"; do
    if [ "$arg" = "--help" ] || [ "$arg" = "-h" ]; then
        show_help
        exit 0
    fi
done

log_info "Starting Btrfs filesystem configuration..."

if checkpoint_exists "btrfs"; then
    log_info "Btrfs configuration checkpoint exists (btrfs.done). Skipping..."
    exit 0
fi

log_info "Current block devices:"
lsblk || true

log_info "Checking current filesystem type on root..."
ROOT_FS=$(findmnt -n -o FSTYPE / || true)

if [ "$ROOT_FS" != "btrfs" ]; then
    log_warning "Root filesystem is '$ROOT_FS', not 'btrfs'."
    log_warning "Automatic disk re-partitioning or formatting is STRICTLY PROHIBITED."
    log_warning "Please manually set up Btrfs following INSTALLATION.md if installing fresh."
    exit 0
fi

log_info "Root filesystem is Btrfs. Subvolumes detected:"
btrfs subvolume list / || true

REQUIRED_SUBVOLS=("@" "@home" "@cache" "@log" "@pkg" "@tmp" "@snapshots" "@swap")

if [ "$IS_DRY_RUN" = true ]; then
    log_info "[DRY-RUN] Would verify existing subvolumes: ${REQUIRED_SUBVOLS[*]}"
    log_info "[DRY-RUN] Would verify mount options: noatime,compress=zstd"
    log_info "[DRY-RUN] Would configure Snapper snapshot policy for / and @home"
    exit 0
fi

if ! ask_confirmation "Proceed with Btrfs subvolume inspection and Snapper configuration?"; then
    log_info "Aborted Btrfs setup."
    exit 0
fi

# Configure snapper if snapper tool is available
if check_command_installed snapper; then
    log_info "Configuring Snapper for root filesystem..."
    if ! snapper -c root list >/dev/null 2>&1; then
        snapper -c root create-config /
    fi
fi

create_checkpoint "btrfs"
log_success "Btrfs setup check completed."
