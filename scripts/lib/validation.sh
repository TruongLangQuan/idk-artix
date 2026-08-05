#!/usr/bin/env bash
# scripts/lib/validation.sh - Input Validation, Flag Parsing & Dry-Run / Force Support
# Version: 1.1

IS_DRY_RUN=false
IS_FORCE=false
IS_RESUME=false

parse_common_flags() {
    for arg in "$@"; do
        case "$arg" in
            --dry-run|-d)
                IS_DRY_RUN=true
                ;;
            --force|-f)
                IS_FORCE=true
                ;;
            --resume|-r)
                IS_RESUME=true
                ;;
        esac
    done
}

# Legacy backward compatibility wrapper
check_dry_run_flag() {
    parse_common_flags "$@"
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
