# SYSTEM RECOVERY & TROUBLESHOOTING GUIDE

Version: 1.0

Project: Artix Linux OpenRC Suckless Workstation

---

# 1. Overview

This document provides step-by-step procedures for recovering from system failures, broken packages, failed source builds, misconfigurations, or boot issues.

---

# 2. Package Installation Failures

### Symptom
Package installation fails due to network interruption, pacman lock, or missing mirrors.

### Solution
1. Clear pacman lock file if stale:
   ```bash
   sudo rm -f /var/lib/pacman/db.lck
   ```
2. Update mirrorlist & sync database:
   ```bash
   sudo pacman -Sy
   ```
3. Resume package installation from checkpoint:
   ```bash
   ./scripts/install_packages.sh --resume
   ```
4. Or force package re-installation:
   ```bash
   ./scripts/install_packages.sh --force
   ```

---

# 3. dwl or slstatus Compilation Failures

### Symptom
`dwl` or `slstatus` fails to compile due to patch conflicts or missing build headers.

### Solution
1. Run a clean rebuild to reset the source tree:
   ```bash
   ./scripts/build_dwl.sh --clean
   ./scripts/build_slstatus.sh --clean
   ```
2. Verify required build dependencies are present:
   ```bash
   sudo pacman -S --needed base-devel wayland wayland-protocols wlroots libinput pixman cairo pango
   ```
3. Test manual compilation in build directory:
   ```bash
   cd ~/src/dwl
   make clean && make
   ```

---

# 4. Broken Dotfiles / Configuration Recovery

### Symptom
User configuration file is broken or accidental deletion occurred.

### Solution
Every execution of `deploy_dotfiles.sh` creates a timestamped backup before modifying files.

1. List available backups:
   ```bash
   ls -la ~/idk-code/idk-artix/backup/
   ```
2. Restore configuration from latest backup directory:
   ```bash
   cp -a ~/idk-code/idk-artix/backup/<TIMESTAMP>/<CONFIG_NAME> ~/.config/
   ```
3. Force re-deploy clean repository dotfiles:
   ```bash
   ./scripts/deploy_dotfiles.sh --force
   ```

---

# 5. Btrfs Snapshot Rollback

### Symptom
System package update breaks system stability or kernel update fails.

### Solution via GRUB-Btrfs Boot
1. Reboot machine.
2. In GRUB boot menu, select **Artix Linux Snapshots**.
3. Choose the latest working pre-update snapshot.
4. Boot into snapshot.

### Manual Snapper Rollback from Terminal
1. List available snapshots:
   ```bash
   sudo snapper list
   ```
2. Perform snapshot rollback:
   ```bash
   sudo snapper rollback <SNAPSHOT_NUM>
   ```
3. Reboot:
   ```bash
   sudo reboot
   ```

---

# 6. OpenRC Service Failures

### Symptom
A service (e.g. NetworkManager, seatd, PipeWire, bluetooth) fails to start.

### Solution
1. Inspect OpenRC runlevel status:
   ```bash
   rc-status
   ```
2. Check specific service status & restart:
   ```bash
   sudo rc-service <service_name> status
   sudo rc-service <service_name> restart
   ```
3. View OpenRC log messages:
   ```bash
   cat /var/log/rc.log
   ```

---

# 7. Boot Fallback & Recovery Kernel

### Symptom
`linux-zen` kernel fails to boot or panics.

### Solution
1. In GRUB boot menu, select **Advanced options for Artix Linux**.
2. Select **Artix Linux, with Linux LTS** (`linux-lts`).
3. Re-install or repair primary kernel once booted:
   ```bash
   sudo pacman -S linux-zen
   sudo grub-mkconfig -o /boot/grub/grub.cfg
   ```
