#!/usr/bin/env bash
# scripts/lib/validation.sh - Input Validation & Dry-Run Support
# Version: 1.0

IS_DRY_RUN=false

check_dry_run_flag() {
    for arg in "$@"; do
        if [ "$arg" = "--dry-run" ] || [ "$arg" = "-d" ]; then
            IS_DRY_RUN=true
            break
        fi
    done
}

ask_confirmation() {
    local prompt_msg="$1"
    if [ "$IS_DRY_RUN" = true ]; then
        echo "[DRY-RUN] Would prompt for confirmation: ${prompt_msg}"
        return 0
    fi

    read -rp "${prompt_msg} [y/N]: " choice
    case "$choice" in
        [yY][eE][sS]|[yY])
            return 0
            ;;
        *)
            echo "Operation cancelled by user."
            return 1
            ;;
    esac
}

check_command_installed() {
    local cmd="$1"
    if command -v "$cmd" >/dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}
