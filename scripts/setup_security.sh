#!/usr/bin/env bash
# scripts/setup_security.sh - UFW, Fail2Ban & Sysctl Security Hardening
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
  -d, --dry-run    Show security hardening steps without modifying firewall or sysctl.
  -h, --help       Show this help message.

Description:
  Sets default UFW policy (deny incoming, allow outgoing), configures Fail2Ban
  SSH protection, applies sysctl security rules, and verifies permissions.
EOF
}

check_dry_run_flag "$@"

for arg in "$@"; do
    if [ "$arg" = "--help" ] || [ "$arg" = "-h" ]; then
        show_help
        exit 0
    fi
done

log_info "Starting security hardening setup..."

if checkpoint_exists "security"; then
    log_info "Security setup checkpoint exists (security.done). Skipping..."
    exit 0
fi

if [ "$IS_DRY_RUN" = true ]; then
    log_info "[DRY-RUN] UFW policy: default deny incoming, default allow outgoing"
    log_info "[DRY-RUN] Fail2Ban: configure /etc/fail2ban/jail.local with 1h bantime, maxretry=5"
    log_info "[DRY-RUN] Sysctl: apply kernel.randomize_va_space=2, net.ipv4.tcp_syncookies=1"
    exit 0
fi

# Configure UFW if installed
if check_command_installed ufw; then
    log_info "Configuring UFW default firewall rules..."
    sudo ufw default deny incoming
    sudo ufw default allow outgoing
    sudo ufw --force enable || log_warning "Failed to enable UFW."
fi

# Configure Fail2Ban if installed
if [ -d "/etc/fail2ban" ]; then
    log_info "Configuring Fail2Ban jail.local..."
    sudo bash -c 'cat << EOF > /etc/fail2ban/jail.local
[DEFAULT]
bantime = 1h
findtime = 10m
maxretry = 5
EOF'
fi

# Apply Security Sysctl Settings
if [ -d "/etc/sysctl.d" ]; then
    log_info "Applying Security sysctl hardening settings..."
    sudo bash -c 'cat << EOF > /etc/sysctl.d/99-security.conf
kernel.randomize_va_space=2
net.ipv4.conf.all.rp_filter=1
net.ipv4.tcp_syncookies=1
EOF'
    sudo sysctl --system || true
fi

# SSH permissions check if directory exists
if [ -d "${HOME}/.ssh" ]; then
    chmod 700 "${HOME}/.ssh"
    chmod 600 "${HOME}/.ssh"/* 2>/dev/null || true
fi

create_checkpoint "security"
log_success "Security setup completed."
