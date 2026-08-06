#!/usr/bin/env bash
# scripts/deploy_dotfiles.sh - User Dotfiles Deployment & Backup Script
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
  -d, --dry-run    Show dotfiles deployment & symlink creation without modifying home directory.
  -h, --help       Show this help message.

Description:
  Creates safety backups of existing ~/.config entries and symlinks configuration files
  from dotfiles/ into ~/.config/ and home.
EOF
}

check_dry_run_flag "$@"

for arg in "$@"; do
    if [ "$arg" = "--help" ] || [ "$arg" = "-h" ]; then
        show_help
        exit 0
    fi
done

log_info "Starting dotfiles deployment..."

if checkpoint_exists "dotfiles"; then
    log_info "Dotfiles deployment checkpoint exists (dotfiles.done). Skipping..."
    exit 0
fi

DOTFILES_SRC="${PROJECT_ROOT}/dotfiles"

MAPPINGS=(
    "${DOTFILES_SRC}/bash/.bashrc:${HOME}/.bashrc"
    "${DOTFILES_SRC}/foot:${HOME}/.config/foot"
    "${DOTFILES_SRC}/fuzzel:${HOME}/.config/fuzzel"
    "${DOTFILES_SRC}/nvim:${HOME}/.config/nvim"
    "${DOTFILES_SRC}/swaylock:${HOME}/.config/swaylock"
    "${DOTFILES_SRC}/mpv:${HOME}/.config/mpv"
    "${DOTFILES_SRC}/fcitx5:${HOME}/.config/fcitx5"
    "${DOTFILES_SRC}/dwl/startup.sh:${HOME}/.dwl/startup.sh"
)

if [ "$IS_DRY_RUN" = true ]; then
    log_info "[DRY-RUN] Symlinks to create:"
    for map in "${MAPPINGS[@]}"; do
        src="${map%%:*}"
        target="${map#*:}"
        log_info "  ${target} -> ${src}"
    done
    exit 0
fi

mkdir -p "${HOME}/.config" "${HOME}/.dwl"

for map in "${MAPPINGS[@]}"; do
    src="${map%%:*}"
    target="${map#*:}"

    if [ -e "$target" ] && [ ! -L "$target" ]; then
        backup_target "$target"
        rm -rf "$target"
    fi

    log_info "Linking ${target} -> ${src}"
    mkdir -p "$(dirname "$target")"
    ln -sf "$src" "$target"
done

log_info "Deploying startdwl launcher script..."
sudo tee /usr/local/bin/startdwl >/dev/null << 'EOF_DWL_LAUNCHER'
#!/usr/bin/env bash
[ -f "$HOME/.dwl/startup.sh" ] && bash "$HOME/.dwl/startup.sh" &
exec dwl -s slstatus
EOF_DWL_LAUNCHER
sudo chmod +x /usr/local/bin/startdwl
sudo cp -f /usr/local/bin/startdwl /usr/bin/startdwl 2>/dev/null || true

create_checkpoint "dotfiles"
log_success "Dotfiles and startdwl launcher deployed successfully."
