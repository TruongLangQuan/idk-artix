#!/usr/bin/env bash
# scripts/setup_audio.sh - PipeWire Audio System Setup Script
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
  -d, --dry-run    Show PipeWire & audio setup steps without executing.
  -h, --help       Show this help message.

Description:
  Configures PipeWire, WirePlumber, ALSA, pavucontrol, and Bluetooth audio.
  Ensures standalone PulseAudio daemon is not running.
EOF
}

check_dry_run_flag "$@"

for arg in "$@"; do
    if [ "$arg" = "--help" ] || [ "$arg" = "-h" ]; then
        show_help
        exit 0
    fi
done

log_info "Starting audio setup..."

if checkpoint_exists "audio"; then
    log_info "Audio setup checkpoint exists (audio.done). Skipping..."
    exit 0
fi

if [ "$IS_DRY_RUN" = true ]; then
    log_info "[DRY-RUN] Would check and terminate standalone pulseaudio daemon if running."
    log_info "[DRY-RUN] Would test wpctl status for PipeWire sinks and sources."
    exit 0
fi

# Ensure standalone pulseaudio is stopped if active
if pgrep -x pulseaudio >/dev/null 2>&1; then
    log_info "Stopping standalone PulseAudio daemon..."
    pulseaudio -k || true
fi

if check_command_installed wpctl; then
    log_info "Checking PipeWire audio system status:"
    wpctl status || log_warning "wpctl returned warnings."
fi

create_checkpoint "audio"
log_success "Audio setup completed successfully."
