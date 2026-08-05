# SYSTEM OPTIMIZATION GUIDE

Version: 1.0

Project: Artix Suckless Workstation

---

# 1. Optimization Philosophy

Optimization priorities:

1. Stability
2. Battery life
3. Low latency
4. Resource efficiency
5. Performance

Never apply:

* Random kernel tweaks.
* Unsafe sysctl values.
* Disabling security features.
* Extreme scheduler modifications.

---

# 2. Performance Targets

Expected idle state:

RAM:

```text
< 1.5GB
```

CPU:

```text
< 2%
```

Background services:

Minimal.

Boot:

Fast and predictable.

---

# 3. Service Audit

## Check Running Services

```bash
rc-status
```

Remove unnecessary services.

---

Keep only:

```text
dbus
seatd
NetworkManager
bluetooth
power-profiles-daemon
```

---

Disable unnecessary daemons.

Example:

```bash
sudo rc-update del service_name
```

---

# 4. Kernel Optimization

## Kernel Choice

Primary:

```text
linux-zen
```

Purpose:

* Lower latency.
* Desktop responsiveness.

Fallback:

```text
linux-lts
```

Purpose:

* Maximum stability.

---

# 5. Intel Microcode

Required:

```bash
intel-ucode
```

Purpose:

CPU bug fixes.

---

# 6. Intel Graphics Optimization

Install:

```text
mesa
vulkan-intel
intel-media-driver
```

---

Verify:

```bash
glxinfo | grep renderer
```

Expected:

```text
Intel Graphics
```

---

# 7. Hardware Video Acceleration

Check:

```bash
vainfo
```

Expected:

Intel VAAPI profiles.

---

Applications:

mpv:

```text
hwdec=vaapi
```

Browser:

Enable:

```text
hardware acceleration
```

---

# 8. NVMe Optimization

Install:

```bash
nvme-cli
```

Check:

```bash
sudo nvme smart-log /dev/nvme0
```

---

Mount options:

Recommended:

```text
noatime
compress=zstd
```

Benefits:

* Less write amplification.
* Better SSD lifespan.
* Lower storage usage.

---

# 9. Btrfs Optimization

Recommended:

Compression:

```text
zstd
```

Reason:

Good balance.

---

Avoid:

```text
nodatacow
```

globally.

Reason:

Lose Btrfs benefits.

---

# 10. Btrfs Maintenance

Enable trim:

```bash
sudo rc-update add fstrim weekly
```

Manual:

```bash
sudo fstrim -av
```

---

Balance:

Only when needed.

Do not run frequently.

---

# 11. RAM Optimization

## zram

Purpose:

Compress memory.

Recommended:

```text
zram size:
50-100% RAM
```

For 16GB RAM:

Recommended:

```text
8GB zram
```

---

Check:

```bash
swapon --show
```

---

# 12. Swap Strategy

Priority:

```text
zram
 |
v
NVMe swapfile
```

Avoid:

Heavy swapping.

---

# 13. CPU Optimization

Install:

```bash
powertop
```

Analyze:

```bash
sudo powertop
```

---

Apply:

```bash
sudo powertop --auto-tune
```

Only after testing.

---

# 14. Power Management

Primary:

```text
power-profiles-daemon
```

Modes:

Balanced:

Daily use.

Performance:

Compilation.

Power saver:

Battery.

---

# 15. CPU Frequency

Check:

```bash
cpupower frequency-info
```

Avoid manual frequency locking.

Let Intel driver manage scaling.

---

# 16. Laptop Battery Optimization

Install:

```text
brightnessctl
```

Reduce:

* Screen brightness.
* Background tasks.
* Browser tabs.

---

# 17. Boot Optimization

Measure:

```bash
systemd-analyze
```

(Not available on OpenRC)

Alternative:

```bash
dmesg --ctime
```

---

Check:

```bash
rc-status
```

Remove:

Unused startup services.

---

# 18. Bash Optimization

Goals:

Fast shell startup.

Avoid:

* Heavy prompt plugins.
* Slow commands.

---

Recommended:

* Bash completion.
* Starship optional.
* Ble.sh optional.

---

# 19. Foot Optimization

Keep:

* Hardware rendering.
* Minimal font configuration.

Avoid:

* Transparency.
* Animations.

---

# 20. dwl Optimization

Avoid:

* Large patches.
* Animations.
* Effects.

Use:

* Minimal patches.
* Native wlroots features.

---

# 21. slstatus Optimization

Update intervals:

CPU:

1s

Temperature:

5s

Disk:

30s

Network:

5s

---

Avoid:

Calling external commands.

Bad:

```bash
$(cat file)
```

Good:

Read directly in C.

---

# 22. Browser Optimization

Zen Browser:

Enable:

```text
Wayland mode
Hardware acceleration
```

Reduce:

* Extensions.
* Background tabs.

---

# 23. Build Optimization

For compiling:

Install:

```text
ccache
```

---

Configure:

```bash
export CCACHE_DIR=$HOME/.cache/ccache
```

---

For large builds:

Use:

```bash
make -j$(nproc)
```

---

# 24. Development Optimization

Recommended:

Tools:

```text
Neovim
tmux
lazygit
ripgrep
fd
```

Avoid:

Heavy IDEs.

---

# 25. Monitoring Tools

Install:

```text
btop
htop
iotop
nvme-cli
lm_sensors
```

---

# 26. Health Check Commands

System:

```bash
fastfetch
```

Memory:

```bash
free -h
```

CPU:

```bash
btop
```

Disk:

```bash
df -h
```

GPU:

```bash
glxinfo
```

Audio:

```bash
pw-top
```

---

# 27. Benchmark Before/After

Record:

Before:

```text
RAM usage
CPU idle
Boot time
Battery
```

After:

```text
RAM usage
CPU idle
Boot time
Battery
```

---

# 28. Things NOT To Do

Do not:

* Disable journaling.
* Disable security modules blindly.
* Change scheduler randomly.
* Disable swap completely.
* Disable Btrfs CoW globally.
* Install unnecessary desktop components.

---

# 29. Final Optimization Target

Final system:

```text
Artix OpenRC

        +

dwl Wayland

        +

Suckless tools

        +

Btrfs

        +

Intel optimization

        +

Minimal services

        =

Fast + stable workstation
```

---

# Completion Checklist

* [ ] Services audited
* [ ] zram configured
* [ ] Intel graphics accelerated
* [ ] NVMe optimized
* [ ] Btrfs compression enabled
* [ ] Power management configured
* [ ] Resource usage measured
* [ ] No unnecessary daemons
