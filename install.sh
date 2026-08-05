#!/usr/bin/env bash
# install.sh - Top-Level Master Setup Launcher
# Version: 2.0
# Artix Linux OpenRC Suckless All-in-One Master Launcher

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FULL_INSTALLER="${SCRIPT_DIR}/install_artix_full.sh"

if [ ! -f "$FULL_INSTALLER" ]; then
    echo "[ERROR] Master installer script not found at ${FULL_INSTALLER}" >&2
    exit 1
fi

chmod +x "${FULL_INSTALLER}" "${SCRIPT_DIR}"/scripts/*.sh "${SCRIPT_DIR}"/scripts/lib/*.sh 2>/dev/null || true

exec bash "$FULL_INSTALLER" "$@"
