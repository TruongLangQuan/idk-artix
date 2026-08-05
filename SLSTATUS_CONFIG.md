# SLSTATUS CONFIGURATION GUIDE

Version: 1.0

Project: Artix Suckless Workstation

---

# 1. Overview

slstatus is the system status monitor used by dwl.

Design goals:

* Lightweight.
* No graphical dependencies.
* Minimal CPU usage.
* Simple C code.
* Easy modification.

Data flow:

```text
Hardware
 |
 +-- CPU
 |
 +-- RAM
 |
 +-- Disk
 |
 +-- Temperature
 |
 +-- Network
 |
 v
slstatus
 |
 v
dwl status bar
```

---

# 2. Build Dependencies

Install:

```bash
sudo pacman -S --needed \
git \
base-devel \
libx11 \
libxft
```

---

# 3. Download Source

Create source directory:

```bash
mkdir -p ~/src
cd ~/src
```

Clone:

```bash
git clone https://git.suckless.org/slstatus
```

Enter:

```bash
cd slstatus
```

---

# 4. Configuration

Main configuration:

```text
config.h
```

slstatus is configured at compile time.

Workflow:

```text
config.h
 |
 v
make
 |
 v
slstatus binary
```

---

# 5. Status Format

Final output example:

```text
[1][2][3][4][5] | RAM 5.2G/15.4G | SSD 42% | CPU 8% | 46°C | WiFi | 23:45 2026-08-05
```

---

# 6. Workspace Module

Required:

Display current workspace.

Format:

```text
1 2 3 4 5
```

Active workspace:

Highlighted by dwl.

---

# 7. RAM Module

Display:

Used RAM / Total RAM

Example:

```text
RAM 4.8G/15.4G
```

Source:

```text
/proc/meminfo
```

Calculation:

```
Total - Available = Used
```

---

# 8. Disk Module

Display:

Root filesystem usage.

Example:

```text
SSD 38%
```

Source:

```text
statvfs()
```

Monitor:

```text
/
```

---

# 9. CPU Usage Module

Display:

CPU utilization.

Example:

```text
CPU 12%
```

Source:

```text
/proc/stat
```

Calculation:

Compare:

* idle time
* total CPU time

between intervals.

---

# 10. Temperature Module

Display:

CPU temperature.

Example:

```text
45°C
```

Source:

```text
/sys/class/thermal
```

Fallback:

```text
lm_sensors
```

If unavailable:

Display:

```text
N/A
```

---

# 11. Network Module

Display:

Active connection.

Example:

Wi-Fi:

```text
WiFi
```

Ethernet:

```text
ETH
```

Disconnected:

```text
OFF
```

Source:

```text
/proc/net/dev
```

---

# 12. Clock Module

Format:

```text
23:45 2026-08-05
```

Configuration:

24-hour format.

Timezone:

```text
Asia/Ho_Chi_Minh
```

---

# 13. Update Interval

Recommended:

```c
#define UPDATE_INTERVAL 1
```

Reason:

* Smooth updates.
* Low CPU impact.

Heavy modules should update slower.

Example:

CPU:

1 second

Temperature:

5 seconds

Disk:

30 seconds

---

# 14. Optimization

Avoid:

* Shell commands inside status updates.
* Large scripts.
* Network requests.
* Frequent disk scanning.

Prefer:

* Reading kernel interfaces.
* Native C functions.

---

# 15. Example config.h Structure

```c
static const Block blocks[] = {

    /* RAM */
    {"ram", 0, 5},

    /* CPU */
    {"cpu", 0, 1},

    /* Temperature */
    {"temp", 0, 5},

    /* Disk */
    {"disk", 0, 30},

    /* Network */
    {"wifi", 0, 5},

    /* Date */
    {"datetime", 0, 30},

};
```

---

# 16. Custom Modules

Create:

```text
components/
```

Example:

```text
components/
|
├── ram.c
├── cpu.c
├── temperature.c
├── disk.c
└── network.c
```

---

# 17. Compilation

Build:

```bash
make clean install
```

Restart:

```bash
pkill slstatus
slstatus &
```

---

# 18. Startup Integration

Start from:

```text
~/.dwl/startup.sh
```

Example:

```bash
#!/usr/bin/env bash

slstatus &
```

---

# 19. Debugging

Run manually:

```bash
slstatus
```

Check:

```bash
journalctl --user
```

---

# 20. Validation

Check:

## Workspace

* [ ] Five workspaces visible.

## Memory

* [ ] Correct used/total value.

## CPU

* [ ] Updates correctly.

## Temperature

* [ ] Matches sensors.

## Disk

* [ ] Shows percentage.

## Network

* [ ] Changes with connection.

---

# 21. Maintenance

Before updating:

Backup:

```bash
cp config.h config.h.backup
```

Update:

```bash
git pull
make clean install
```

---

# Final Result

slstatus should provide:

* Useful information.
* Minimal CPU usage.
* No external dependencies.
* Perfect integration with dwl.
* Consistent monochrome appearance.
