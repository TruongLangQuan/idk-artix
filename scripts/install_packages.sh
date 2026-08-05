#!/usr/bin/env bash
# scripts/install_packages.sh - Idempotent Package Installation Script
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
  -d, --dry-run    Show packages that would be installed without modifying system.
  -h, --help       Show this help message.

Description:
  Installs official packages from packages/*.txt categories after verifying availability.
EOF
}

check_dry_run_flag "$@"

for arg in "$@"; do
    if [ "$arg" = "--help" ] || [ "$arg" = "-h" ]; then
        show_help
        exit 0
    fi
done

log_info "Starting package installation stage..."

if checkpoint_exists "packages"; then
    log_info "Package installation checkpoint exists (packages.done). Skipping..."
    exit 0
fi

PACKAGE_FILES=(
    "${PROJECT_ROOT}/packages/base.txt"
    "${PROJECT_ROOT}/packages/wayland.txt"
    "${PROJECT_ROOT}/packages/development.txt"
    "${PROJECT_ROOT}/packages/multimedia.txt"
    "${PROJECT_ROOT}/packages/security.txt"
    "${PROJECT_ROOT}/packages/optional.txt"
)

VALID_TO_INSTALL=()
SKIPPED_PACKAGES=()

for pkg_file in "${PACKAGE_FILES[@]}"; do
    if [ -f "$pkg_file" ]; then
        while IFS= read -r pkg || [ -n "$pkg" ]; do
            # Strip whitespace & comments
            pkg=$(echo "$pkg" | xargs)
            [[ -z "$pkg" || "$pkg" =~ ^# ]] && continue
            
            if ! pacman -Qi "$pkg" >/dev/null 2>&1; then
                if pacman -Si "$pkg" >/dev/null 2>&1; then
                    VALID_TO_INSTALL+=("$pkg")
                else
                    SKIPPED_PACKAGES+=("$pkg")
                    log_warning "Package '$pkg' not found in active pacman repositories. Skipping..."
                fi
            fi
        done < "$pkg_file"
    fi
done

if [ ${#SKIPPED_PACKAGES[@]} -gt 0 ]; then
    log_warning "Skipped ${#SKIPPED_PACKAGES[@]} package(s) not found in pacman repos: ${SKIPPED_PACKAGES[*]}"
fi

if [ ${#VALID_TO_INSTALL[@]} -eq 0 ]; then
    log_info "No missing valid packages to install via pacman."
    create_checkpoint "packages"
    exit 0
fi

if [ "$IS_DRY_RUN" = true ]; then
    log_info "[DRY-RUN] Packages that would be installed (${#VALID_TO_INSTALL[@]} total):"
    printf '  - %s\n' "${VALID_TO_INSTALL[@]}"
    exit 0
fi

log_info "Installing ${#VALID_TO_INSTALL[@]} valid missing packages..."
sudo pacman -S --needed --noconfirm "${VALID_TO_INSTALL[@]}"

create_checkpoint "packages"
log_success "Package installation completed successfully."
