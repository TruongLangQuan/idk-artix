# SECURITY GUIDE

Version: 1.0

Project: Artix Suckless Workstation

---

# 1. Security Philosophy

Security priorities:

```text id="u0c4pn"
Minimal attack surface

        +

Regular updates

        +

Strong permissions

        +

Simple recovery
```

Không sử dụng:

* Antivirus chạy nền.
* Security daemon nặng.
* Firewall rule phức tạp không cần thiết.

---

# 2. User Account Security

## Root Usage

Không sử dụng root cho công việc hằng ngày.

Sai:

```bash id="e2u6qj"
login root
```

Đúng:

```bash id="z7m6j5"
sudo command
```

---

# 3. User Groups

Kiểm tra:

```bash id="f2w7cl"
groups
```

User chính nên có:

```text id="8z3x9r"
wheel

audio

video

input

seat
```

---

# 4. Sudo Configuration

File:

```text id="fmb3rk"
/etc/sudoers
```

Edit:

```bash id="3cr7p9"
EDITOR=nano visudo
```

Enable:

```text id="y2r3w7"
%wheel ALL=(ALL:ALL) ALL
```

---

# 5. Firewall

## UFW

Install:

```bash id="7j7u9n"
sudo pacman -S ufw
```

---

Enable OpenRC:

```bash id="t4aj2r"
sudo rc-update add ufw default
```

Start:

```bash id="h6p4ws"
sudo rc-service ufw start
```

---

# 6. Default Firewall Policy

Recommended:

```bash id="xq0s2b"
sudo ufw default deny incoming

sudo ufw default allow outgoing
```

---

# 7. Allow Local Services

SSH only if needed:

```bash id="2z8z5v"
sudo ufw allow ssh
```

Check:

```bash id="1x0v2h"
sudo ufw status
```

---

# 8. Fail2Ban

Purpose:

Protect against:

* SSH brute force.
* Repeated authentication failures.

Install:

```bash id="2n2j8f"
sudo pacman -S fail2ban
```

---

Enable:

```bash id="d5x6fh"
sudo rc-update add fail2ban default
```

Start:

```bash id="n3q4ga"
sudo rc-service fail2ban start
```

---

# 9. Fail2Ban Configuration

Create:

```text id="o9wq0z"
/etc/fail2ban/jail.local
```

Example:

```ini id="1f7m0k"
[DEFAULT]

bantime = 1h

findtime = 10m

maxretry = 5
```

---

# 10. SSH Security

Only if SSH is used.

Install:

```bash id="s3l7b1"
sudo pacman -S openssh
```

---

Disable root login:

File:

```text id="5kj4mu"
/etc/ssh/sshd_config
```

Set:

```text id="7x0f1g"
PermitRootLogin no
```

---

Use keys:

```text id="0c4k5x"
PasswordAuthentication no
```

after testing.

---

# 11. Automatic Updates

Artix does not force automatic updates.

Recommended:

Weekly:

```bash id="xj9j3r"
sudo pacman -Syu
```

---

Before major update:

Backup:

```bash id="n2q0k1"
btrfs subvolume snapshot
```

---

# 12. Btrfs Snapshots

Purpose:

Rollback after bad update.

Structure:

```text id="8f3wq4"
@snapshots
```

---

Manual snapshot:

```bash id="7b1j9r"
btrfs subvolume snapshot \
/ \
/.snapshots/pre-update
```

---

# 13. File Permissions

Check home:

```bash id="y8m3df"
ls -ld ~
```

Recommended:

```text id="1g9h7p"
700
```

---

SSH keys:

```bash id="j2h5s8"
chmod 700 ~/.ssh

chmod 600 ~/.ssh/*
```

---

# 14. Kernel Security

Keep:

* Secure updates.
* Microcode.
* Modern kernel.

Install:

```bash id="q4g8z0"
intel-ucode
```

---

# 15. Sysctl Hardening

File:

```text id="n7h3jd"
/etc/sysctl.d/99-security.conf
```

Example:

```conf id="w0c9as"
kernel.randomize_va_space=2

net.ipv4.conf.all.rp_filter=1

net.ipv4.tcp_syncookies=1
```

Apply:

```bash id="j7z2kd"
sudo sysctl --system
```

---

# 16. Application Security

## Browser

Zen Browser:

Enable:

* Automatic updates.
* Sandboxing.
* HTTPS-only mode.

Avoid:

* Unknown extensions.
* Random scripts.

---

# 17. Development Security

Never commit:

```text id="5j9s3q"
passwords

API keys

SSH keys

tokens

.env files
```

Use:

```text id="4m8q7c"
.gitignore
```

---

# 18. Git Security

Configure:

```bash id="k5m9t1"
git config --global user.signingkey KEY
```

Optional:

Signed commits.

---

# 19. Package Security

Only install from:

* Official repositories.
* Trusted AUR/community packages.

Before installing:

Check:

```bash id="0b2x9m"
PKGBUILD
source
maintainer
```

---

# 20. Service Audit

Regular check:

```bash id="v8w1q4"
rc-status
```

Remove unused services:

```bash id="c3x7h9"
sudo rc-update del service
```

---

# 21. USB Security

Avoid:

```bash id="q9m3a7"
sudo mount unknown devices
```

Verify:

```bash id="5h7z2p"
lsblk
```

---

# 22. Backup Security

Backup locations:

```text id="k0v5q9"
encrypted storage
```

Protect:

* SSH keys.
* Password database.
* Personal data.

---

# 23. Monitoring

Useful tools:

```bash id="m8v1x3"
btop

journalctl

ufw status

fail2ban-client status
```

---

# 24. Security vs Performance

Allowed:

✓ UFW
✓ Fail2Ban
✓ Btrfs snapshots
✓ Minimal services
✓ Regular updates

Avoid:

✗ Heavy antivirus
✗ Constant scanners
✗ Duplicate firewalls
✗ Background monitoring tools

---

# 25. Security Checklist

## Firewall

* [ ] UFW enabled
* [ ] Default deny incoming

## Authentication

* [ ] Strong password
* [ ] Sudo configured
* [ ] SSH secured

## System

* [ ] Microcode installed
* [ ] Updates maintained
* [ ] Snapshots available

## Applications

* [ ] Browser hardened
* [ ] Git secrets protected

---

# Final Security Goal

The final workstation:

```text id="p3x6v8"
Artix OpenRC

+

Minimal Services

+

Firewall

+

Fail2Ban

+

Btrfs Recovery

+

Secure Workflow
```

maintains:

* Low resource usage.
* Fast boot.
* Easy recovery.
* Strong workstation security.
