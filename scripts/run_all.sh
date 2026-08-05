#!/usr/bin/env bash
# scripts/run_all.sh - Sequential Execution Script
# Version: 1.0

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BOOTSTRAP_SCRIPT="${SCRIPT_DIR}/bootstrap.sh"

exec bash "$BOOTSTRAP_SCRIPT" "$@"
