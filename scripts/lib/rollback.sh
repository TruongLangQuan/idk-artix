#!/usr/bin/env bash
# scripts/lib/rollback.sh - Rollback Handling Mechanism
# Version: 1.0

ROLLBACK_COMMANDS=()

register_rollback_cmd() {
    local cmd="$1"
    ROLLBACK_COMMANDS+=("$cmd")
}

execute_rollback() {
    echo "[WARNING] Initiating rollback sequence..."
    for (( i=${#ROLLBACK_COMMANDS[@]}-1; i>=0; i-- )); do
        echo "[ROLLBACK] Executing: ${ROLLBACK_COMMANDS[i]}"
        eval "${ROLLBACK_COMMANDS[i]}" || true
    done
}
