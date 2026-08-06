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

log_info "Deploying foot.ini to root & system-wide fallback..."
sudo mkdir -p /root/.config/foot /etc/xdg/foot
sudo cp -f "${DOTFILES_SRC}/foot/foot.ini" /root/.config/foot/foot.ini
sudo cp -f "${DOTFILES_SRC}/foot/foot.ini" /etc/xdg/foot/foot.ini

log_info "Deploying startdwl launcher script..."
sudo tee /usr/local/bin/startdwl >/dev/null << 'EOF_DWL_LAUNCHER'
#!/usr/bin/env bash
exec dwl "$@"
EOF_DWL_LAUNCHER
sudo chmod +x /usr/local/bin/startdwl
sudo cp -f /usr/local/bin/startdwl /usr/bin/startdwl 2>/dev/null || true

log_info "Deploying zen-browser launcher script..."
sudo tee /usr/local/bin/zen-browser >/dev/null << 'EOF_ZEN'
#!/usr/bin/env bash
if command -v flatpak &>/dev/null && flatpak info app.zen_browser.zen &>/dev/null; then
    exec flatpak run app.zen_browser.zen "$@"
elif [ -x "$HOME/.local/zen/zen" ]; then
    exec "$HOME/.local/zen/zen" "$@"
elif [ -x "$HOME/zen/zen" ]; then
    exec "$HOME/zen/zen" "$@"
elif [ -x "/opt/zen/zen" ]; then
    exec /opt/zen/zen "$@"
elif command -v zen-browser-bin &>/dev/null; then
    exec zen-browser-bin "$@"
elif command -v zen &>/dev/null; then
    exec zen "$@"
else
    ZEN_PATH="$(find $HOME /opt /usr -name "zen" -type f -executable 2>/dev/null | grep -v "node_modules" | head -n 1)"
    if [ -n "$ZEN_PATH" ]; then
        exec "$ZEN_PATH" "$@"
    else
        exec firefox "$@"
    fi
fi
EOF_ZEN
sudo chmod +x /usr/local/bin/zen-browser
sudo cp -f /usr/local/bin/zen-browser /usr/bin/zen-browser 2>/dev/null || true

log_info "Deploying keybind-help tutorial script..."
sudo tee /usr/local/bin/keybind-help >/dev/null << 'EOF_HELP'
#!/usr/bin/env bash
exec foot --app-id=foot-keybinds --title="Artix DWL Keybindings Tutorial" bash -c '
cat << "EOF_TXT"
===================================================================
                  ARTIX DWL KEYBINDINGS TUTORIAL                   
===================================================================

[LAUNCHERS & CORE]
  Super + d               Toggle Fuzzel Application Launcher
  Super + Return / t      Launch Foot Terminal
  Super + b               Launch Zen Web Browser
  Super + q               Kill / Close Focused Window
  Super + l               Lock Screen (Swaylock)
  Super + Space           Toggle Keyboard Layout (US <-> Vietnamese)
  Super + v               Clipboard History Picker (cliphist + fuzzel)
  PrintScreen             Take Region Screenshot (grim + slurp)
  Super + F1 / Shift + H  Open This Keybinding Tutorial

[WINDOW LAYOUT & FLOATING TOGGLES]
  Super + s               Toggle Focused Window (Floating <-> Tiling)
  Super + Shift + Space   Toggle Focused Window (Floating <-> Tiling)
  Super + Shift + T       Switch Workspace Layout to Tiling [[]=]
  Super + Shift + F       Switch Workspace Layout to Floating [><>]
  Super + Shift + M       Switch Workspace Layout to Monocle [[M]]
  Super + f               Toggle Fullscreen Mode

[WORKSPACE NAVIGATION]
  Super + 1 .. 9          Switch to Workspace 1..9
  Super + Shift + 1 .. 9  Move Window to Workspace 1..9
  Super + Ctrl + Arrows   Cycle Next / Previous Workspace
  Ctrl + Shift + Arrows   Cycle Next / Previous Workspace

[VIRTUAL TERMINAL (TTY)]
  Ctrl + Alt + F1         Switch back to DWL Wayland Desktop
  Ctrl + Alt + F2 .. F6   Switch to Linux TTY Console 2..6

[MOUSE CONTROLS]
  Super + Left Click      Drag and move window position
  Super + Right Click     Resize window dimensions
===================================================================
EOF_TXT
echo ""
read -n 1 -s -r -p "Press any key to close..."
'
EOF_HELP
sudo chmod +x /usr/local/bin/keybind-help
sudo cp -f /usr/local/bin/keybind-help /usr/bin/keybind-help 2>/dev/null || true

create_checkpoint "dotfiles"
log_success "Dotfiles, startdwl launcher, and keybind-help deployed successfully."
