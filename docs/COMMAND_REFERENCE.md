# COMMAND REFERENCE GUIDE

Version: 1.0

Project: Artix Linux OpenRC Suckless Workstation

---

# 1. System & Init Management (OpenRC)

| Command | Description |
| --- | --- |
| `rc-status` | Display status of all services in current runlevel. |
| `sudo rc-service <name> start` | Start specified OpenRC service. |
| `sudo rc-service <name> stop` | Stop specified OpenRC service. |
| `sudo rc-service <name> restart` | Restart specified OpenRC service. |
| `sudo rc-update add <name> default` | Enable service to start automatically at boot. |
| `sudo rc-update del <name> default` | Disable service from starting at boot. |

---

# 2. Filesystem & Storage (Btrfs / NVMe)

| Command | Description |
| --- | --- |
| `lsblk` | List all block devices and mount points. |
| `btrfs filesystem show` | Show Btrfs filesystem usage and allocation. |
| `btrfs subvolume list /` | List Btrfs subvolumes on root filesystem. |
| `sudo fstrim -av` | Perform manual SSD TRIM on mounted filesystems. |
| `sudo nvme smart-log /dev/nvme0` | View NVMe SSD health and SMART log. |
| `sudo snapper list` | List Btrfs Snapper snapshots. |

---

# 3. Audio & Multimedia (PipeWire / ALSA)

| Command | Description |
| --- | --- |
| `wpctl status` | Display PipeWire audio sinks, sources, and devices. |
| `pw-top` | Real-time monitoring of PipeWire audio streams & latency. |
| `pavucontrol` | Launch graphical GTK audio volume mixer. |
| `pamixer -i 5` / `pamixer -d 5` | Increase / Decrease volume by 5%. |
| `pamixer -t` | Toggle audio mute. |
| `playerctl play-pause` | Toggle media playback (MPV, Spotify, Browser). |

---

# 4. Networking & Bluetooth

| Command | Description |
| --- | --- |
| `nmcli device` | Show NetworkManager status of network devices. |
| `nmcli device wifi list` | List available Wi-Fi access points. |
| `nmcli device wifi connect <SSID> password <PASS>` | Connect to Wi-Fi network. |
| `bluetoothctl` | Open interactive Bluetooth control CLI. |
| `loginctl seat-status seat0` | Check `seatd` user seat permissions and DRM access. |

---

# 5. Security & Firewall

| Command | Description |
| --- | --- |
| `sudo ufw status` | View UFW firewall rules and status. |
| `sudo ufw default deny incoming` | Set default incoming policy to block. |
| `sudo ufw default allow outgoing` | Set default outgoing policy to allow. |
| `sudo fail2ban-client status` | View Fail2Ban protection jails status. |

---

# 6. Graphics & System Diagnostics

| Command | Description |
| --- | --- |
| `glxinfo \| grep renderer` | Verify Mesa OpenGL graphics acceleration driver. |
| `vainfo` | Verify Intel VAAPI hardware video decoding profiles. |
| `lscpu` | Display CPU architecture, cores, and threads. |
| `free -h` | Display RAM and Swap/zram utilization. |
| `btop` | Launch interactive terminal resource monitor. |
| `fastfetch` | Output system information summary fetch. |

---

# 7. Wayland & Suckless Utilities

| Command | Description |
| --- | --- |
| `dwl` | Launch dwl Wayland window manager compositor. |
| `slstatus` | Run slstatus status bar monitor. |
| `foot` | Launch Foot Wayland terminal emulator. |
| `fuzzel` | Launch Fuzzel application menu. |
| `swaylock` | Lock Wayland screen. |
| `grim -g "$(slurp)" <out.png>` | Capture region screenshot. |
| `cliphist list \| fuzzel \| cliphist decode \| wl-copy` | Select & restore item from clipboard history. |
| `swww img <image.png>` | Set static wallpaper. |
| `mpvpaper '*' <video.mp4>` | Set dynamic video wallpaper. |
