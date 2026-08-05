#!/usr/bin/env bash
# install.sh - Top-Level Master Setup Launcher
# Version: 1.0
# Artix Linux OpenRC Suckless Workstation Setup Launcher

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BOOTSTRAP_SCRIPT="${SCRIPT_DIR}/scripts/bootstrap.sh"

if [ ! -f "$BOOTSTRAP_SCRIPT" ]; then
    echo "[ERROR] Bootstrap script not found at ${BOOTSTRAP_SCRIPT}" >&2
    exit 1
fi

chmod +x "${SCRIPT_DIR}"/scripts/*.sh "${SCRIPT_DIR}"/scripts/lib/*.sh 2>/dev/null || true

exec bash "$BOOTSTRAP_SCRIPT" "$@"
