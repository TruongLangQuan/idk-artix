#!/usr/bin/env bash
# scripts/lib/checkpoint.sh - State and Checkpoint Tracking
# Version: 1.1

LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$LIB_DIR/../.." && pwd)"
STATE_DIR="${PROJECT_ROOT}/.state"
mkdir -p "$STATE_DIR"

checkpoint_exists() {
    local task_name="$1"
    local done_file="${STATE_DIR}/${task_name}.done"

    if [ "${IS_FORCE:-false}" = true ]; then
        rm -f "$done_file"
        return 1
    fi

    if [ -f "$done_file" ]; then
        return 0
    fi
    return 1
}

create_checkpoint() {
    local task_name="$1"
    date "+%Y-%m-%d %H:%M:%S" > "${STATE_DIR}/${task_name}.done"
}

clear_checkpoint() {
    local task_name="$1"
    rm -f "${STATE_DIR}/${task_name}.done"
}
