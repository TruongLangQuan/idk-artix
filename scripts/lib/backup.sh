#!/usr/bin/env bash
# scripts/lib/backup.sh - Configuration Backup Helper
# Version: 1.0

LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$LIB_DIR/../.." && pwd)"
BACKUP_DIR="${PROJECT_ROOT}/backup/$(date +%Y%m%d_%H%M%S)"

backup_target() {
    local target="$1"
    if [ -e "$target" ]; then
        mkdir -p "$BACKUP_DIR"
        echo "[INFO] Creating backup of ${target} in ${BACKUP_DIR}"
        cp -a "$target" "${BACKUP_DIR}/"
    fi
}
