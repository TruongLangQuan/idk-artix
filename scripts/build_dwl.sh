#!/usr/bin/env bash
# scripts/build_dwl.sh - Safe dwl Building & Customization Script (With Top Bar Patch)
# Version: 2.0

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
  -d, --dry-run    Show dwl build steps without cloning or compiling.
  -h, --help       Show this help message.

Description:
  Clones dwl source code to ~/src/dwl, applies official top bar patch (bar.patch),
  deploys custom config.h, builds the binary, and installs dwl.
EOF
}

check_dry_run_flag "$@"

IS_CLEAN=false

for arg in "$@"; do
    if [ "$arg" = "--clean" ] || [ "$arg" = "-c" ]; then
        IS_CLEAN=true
    elif [ "$arg" = "--help" ] || [ "$arg" = "-h" ]; then
        show_help
        exit 0
    fi
done

log_info "Starting dwl build process..."

if [ "$IS_CLEAN" = true ]; then
    log_info "Clean rebuild requested. Clearing checkpoint and existing build directory..."
    clear_checkpoint "dwl"
    rm -rf "$HOME/src/dwl"
elif checkpoint_exists "dwl"; then
    log_info "dwl build checkpoint exists (dwl.done). Skipping..."
    exit 0
fi

BUILD_DIR="$HOME/src/dwl"
DOTFILES_CONFIG="${PROJECT_ROOT}/dotfiles/dwl/config.h"

if [ "$IS_DRY_RUN" = true ]; then
    log_info "[DRY-RUN] Target source directory: ${BUILD_DIR}"
    log_info "[DRY-RUN] Config header source: ${DOTFILES_CONFIG}"
    log_info "[DRY-RUN] Would clone https://codeberg.org/dwl/dwl.git"
    log_info "[DRY-RUN] Would apply official top bar patch (bar.patch)"
    log_info "[DRY-RUN] Would compile dwl with make clean install"
    exit 0
fi

log_info "Ensuring bar patch dependencies (fcft, tllist, pixman) are installed..."
sudo pacman -S --needed --noconfirm fcft tllist pixman libinput xkbcommon wayland-protocols || log_warning "Failed to pre-install bar patch dependencies."

mkdir -p "$HOME/src"

if [ ! -d "$BUILD_DIR" ]; then
    log_info "Cloning dwl repository..."
    git clone https://codeberg.org/dwl/dwl.git "$BUILD_DIR"
else
    log_info "dwl source already present at ${BUILD_DIR}. Updating..."
    cd "$BUILD_DIR"
    git pull || log_warning "Failed to git pull dwl repository."
fi

cd "$BUILD_DIR"

log_info "Downloading and applying official dwl top bar patch..."
curl -sL "https://codeberg.org/dwl/dwl-patches/raw/branch/main/patches/bar/bar.patch" -o bar.patch
if git apply --check bar.patch >/dev/null 2>&1; then
    git apply bar.patch
elif patch -p1 --dry-run < bar.patch >/dev/null 2>&1; then
    patch -p1 < bar.patch
else
    log_warning "bar.patch already applied or could not be applied cleanly."
fi

if ! grep -q "void shiftview" dwl.c; then
    log_info "Injecting shiftview function for smooth workspace navigation..."
    cat << "EOF_SHIFT" >> dwl.c

void
shiftview(const Arg *arg)
{
	Arg a;
	if (!selmon) return;
	a.ui = selmon->tagset[selmon->seltags];
	if (arg->i > 0)
		a.ui = (a.ui << arg->i) | (a.ui >> (5 - arg->i));
	else
		a.ui = (a.ui >> -arg->i) | (a.ui << (5 + arg->i));
	a.ui &= (1 << 5) - 1;
	if (a.ui)
		view(&a);
}
EOF_SHIFT
fi

if [ -f "config.h" ]; then
    backup_target "${BUILD_DIR}/config.h"
fi

if [ -f "$DOTFILES_CONFIG" ]; then
    log_info "Deploying repository config.h to dwl source..."
    cp -f "$DOTFILES_CONFIG" "${BUILD_DIR}/config.h"
fi

log_info "Detecting installed wlroots pkg-config package..."
FOUND_WLR=""
for wver in wlroots-0.20 wlroots0.20 wlroots-0.19 wlroots0.19 wlroots-0.18 wlroots; do
    if pkg-config --exists "$wver" 2>/dev/null; then
        FOUND_WLR="$wver"
        break
    fi
done

if [ -n "$FOUND_WLR" ]; then
    log_info "Found installed wlroots: ${FOUND_WLR}. Adjusting dwl Makefile..."
    sed -i -E "s/wlroots-0\.[0-9]+/${FOUND_WLR}/g" Makefile
    sed -i -E "s/wlroots0\.[0-9]+/${FOUND_WLR}/g" Makefile
else
    log_warning "No wlroots pkg-config package detected via pkg-config."
fi

log_info "Compiling dwl with top bar support..."
make clean
make

log_info "Installing dwl..."
sudo make install

create_checkpoint "dwl"
log_success "dwl (with built-in top bar) built and installed successfully."
