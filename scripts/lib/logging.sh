#!/usr/bin/env bash
# scripts/lib/logging.sh - Reusable Logging Framework
# Version: 1.0

# Ensure log directory exists
LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$LIB_DIR/../.." && pwd)"
LOG_DIR="${PROJECT_ROOT}/logs"
mkdir -p "$LOG_DIR"

TODAY=$(date +%Y-%m-%d)
CURRENT_SCRIPT_NAME="$(basename "${0:-script}")"
LOG_FILE="${LOG_DIR}/${TODAY}-${CURRENT_SCRIPT_NAME}.log"

log_msg() {
    local level="$1"
    shift
    local timestamp
    timestamp=$(date "+%Y-%m-%d %H:%M:%S")
    local message="$*"
    local formatted="[${timestamp}] [${level}] ${message}"

    echo "${formatted}" | tee -a "$LOG_FILE"
}

log_info() {
    log_msg "INFO" "$@"
}

log_warning() {
    log_msg "WARNING" "$@"
}

log_error() {
    log_msg "ERROR" "$@"
}

log_success() {
    log_msg "SUCCESS" "$@"
}
