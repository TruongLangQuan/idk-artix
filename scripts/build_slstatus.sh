#!/usr/bin/env bash
# scripts/build_slstatus.sh - Safe slstatus Building & Customization Script
# Version: 1.0

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

source "${SCRIPT_DIR}/lib/logging.sh"
source "${SCRIPT_DIR}/lib/checkpoint.sh"
source "${SCRIPT_DIR}/lib/validation.sh"
source "${SCRIPT_DIR}/lib/backup.sh"

show_help() {
    cat << EOF
Usage: $(basename "$0") [OPTIONS]

Options:
  -d, --dry-run    Show slstatus build steps without cloning or compiling.
  -h, --help       Show this help message.

Description:
  Clones slstatus source code to ~/src/slstatus, applies custom config.h for
  RAM, CPU, Temperature, Disk, Network, Date/Time monitoring, compiles and installs binary.
EOF
}

check_dry_run_flag "$@"

for arg in "$@"; do
    if [ "$arg" = "--help" ] || [ "$arg" = "-h" ]; then
        show_help
        exit 0
    fi
done

log_info "Starting slstatus build process..."

if checkpoint_exists "slstatus"; then
    log_info "slstatus build checkpoint exists (slstatus.done). Skipping..."
    exit 0
fi

BUILD_DIR="$HOME/src/slstatus"
DOTFILES_CONFIG="${PROJECT_ROOT}/dotfiles/slstatus/config.h"

if [ "$IS_DRY_RUN" = true ]; then
    log_info "[DRY-RUN] Target source directory: ${BUILD_DIR}"
    log_info "[DRY-RUN] Config header source: ${DOTFILES_CONFIG}"
    log_info "[DRY-RUN] Would clone https://git.suckless.org/slstatus"
    log_info "[DRY-RUN] Would compile slstatus with make clean install"
    exit 0
fi

mkdir -p "$HOME/src"

if [ ! -d "$BUILD_DIR" ]; then
    log_info "Cloning slstatus repository..."
    git clone https://git.suckless.org/slstatus "$BUILD_DIR"
else
    log_info "slstatus source already present at ${BUILD_DIR}. Updating..."
    cd "$BUILD_DIR"
    git pull || log_warning "Failed to git pull slstatus repository."
fi

cd "$BUILD_DIR"

if [ -f "config.h" ]; then
    backup_target "${BUILD_DIR}/config.h"
fi

if [ -f "$DOTFILES_CONFIG" ]; then
    log_info "Deploying repository config.h to slstatus source..."
    cp -f "$DOTFILES_CONFIG" "${BUILD_DIR}/config.h"
fi

log_info "Compiling slstatus..."
make clean
make

log_info "Installing slstatus..."
sudo make install

create_checkpoint "slstatus"
log_success "slstatus built and installed successfully."
