# SCRIPTS DESIGN

Version: 1.0

Project: Artix Suckless Workstation

---

# 1. Purpose

This document defines the architecture of all automation scripts.

The scripts manage:

* Installation
* Configuration
* Building
* Optimization
* Backup
* Recovery
* Health checking

---

# 2. Script Philosophy

All scripts must follow:

```text
Safe

  |

Repeatable

  |

Logged

  |

Recoverable

  |

Automated
```

---

# 3. Script Directory

Structure:

```text
scripts/

├── lib/
│   ├── logging.sh
│   ├── checks.sh
│   ├── packages.sh
│   └── rollback.sh
│
├── bootstrap.sh
│
├── install_packages.sh
│
├── setup_btrfs.sh
│
├── setup_openrc.sh
│
├── setup_hardware.sh
│
├── build_dwl.sh
│
├── build_slstatus.sh
│
├── deploy_dotfiles.sh
│
├── optimize_system.sh
│
├── backup.sh
│
├── restore.sh
│
└── healthcheck.sh
```

---

# 4. Common Script Header

Every script must start with:

```bash
#!/usr/bin/env bash

set -euo pipefail
```

Purpose:

* Stop on errors.
* Prevent undefined variables.
* Detect pipeline failures.

---

# 5. Directory Variables

Every script uses:

```bash
PROJECT_ROOT
CONFIG_DIR
LOG_DIR
CACHE_DIR
BACKUP_DIR
```

Example:

```bash
PROJECT_ROOT="$HOME/artix-suckless"
LOG_DIR="$PROJECT_ROOT/logs"
```

---

# 6. Logging System

All scripts create logs.

Location:

```text
logs/
```

Example:

```text
logs/

bootstrap-20260805.log

dwl-build.log

healthcheck.log
```

---

# 7. Logging Format

Example:

```text
[INFO] Installing packages

[WARN] Package already installed

[ERROR] Build failed

[SUCCESS] Completed
```

---

# 8. Checkpoint System

Purpose:

Allow resume after failure.

Location:

```text
.state/
```

Example:

```text
.state/

packages.done

btrfs.done

dwl.done

dotfiles.done
```

---

# 9. Checkpoint Example

Before:

```bash
if checkpoint_exists "dwl"; then
    skip
fi
```

After success:

```bash
create_checkpoint "dwl"
```

---

# 10. Bootstrap Script

File:

```text
bootstrap.sh
```

Purpose:

Main entry point.

Flow:

```text
bootstrap

 |

 +-- check system

 |

 +-- install packages

 |

 +-- configure OpenRC

 |

 +-- setup hardware

 |

 +-- build dwl

 |

 +-- build slstatus

 |

 +-- deploy dotfiles

 |

 +-- optimize

 |

 +-- healthcheck
```

---

# 11. Package Installation Script

File:

```text
install_packages.sh
```

Responsibilities:

* Install official packages.
* Verify packages.
* Record changes.

Example:

```bash
pacman -S --needed package
```

Never:

```bash
pacman -S package --overwrite "*"
```

---

# 12. Package Groups

Packages separated:

```text
packages/

├── base.txt

├── graphics.txt

├── wayland.txt

├── development.txt

├── multimedia.txt

└── optional.txt
```

---

# 13. Btrfs Setup Script

File:

```text
setup_btrfs.sh
```

Responsibilities:

* Create subvolumes.
* Configure compression.
* Configure snapshots.

Must check:

* Existing filesystem.
* Existing data.
* Mount status.

---

# 14. OpenRC Setup Script

File:

```text
setup_openrc.sh
```

Enable:

```text
dbus

seatd

NetworkManager

bluetooth

power-profiles-daemon
```

Disable unnecessary services.

---

# 15. Hardware Setup Script

File:

```text
setup_hardware.sh
```

Configure:

* Intel microcode.
* Mesa.
* Vulkan.
* VAAPI.
* Sensors.
* NVMe tools.

---

# 16. DWL Build Script

File:

```text
build_dwl.sh
```

Flow:

```text
Download source

        |

Apply patches

        |

Backup config.h

        |

Compile

        |

Install

        |

Validate
```

---

# 17. Patch Verification

Before applying patch:

Check:

```bash
git apply --check patch.patch
```

If failed:

Stop.

Do not force patch.

---

# 18. slstatus Build Script

File:

```text
build_slstatus.sh
```

Flow:

```text
Backup config

        |

Apply modules

        |

Compile

        |

Install

        |

Test
```

---

# 19. Dotfiles Deployment

File:

```text
deploy_dotfiles.sh
```

Responsibilities:

* Create directories.
* Backup existing configs.
* Create symlinks.

Example:

```bash
ln -sf source target
```

---

# 20. Backup Script

File:

```text
backup.sh
```

Backup:

```text
/etc

/home configuration

dwl source

dotfiles
```

Storage:

```text
backup/
```

---

# 21. Restore Script

File:

```text
restore.sh
```

Requirements:

* Confirm before overwrite.
* Validate backup.
* Create safety backup.

---

# 22. Optimization Script

File:

```text
optimize_system.sh
```

Tasks:

* Configure zram.
* Configure sysctl.
* Configure power profile.
* Enable trim.

Must:

Measure before applying changes.

---

# 23. Healthcheck Script

File:

```text
healthcheck.sh
```

Checks:

## System

```text
Kernel

OpenRC

Services
```

## Hardware

```text
CPU

GPU

Temperature

NVMe
```

## Desktop

```text
Wayland

dwl

PipeWire

Clipboard
```

---

# 24. Security Rules

Scripts must never:

* Disable firewall automatically.
* Change permissions recursively.
* Delete user data.
* Format disks without confirmation.

---

# 25. Dry Run Mode

Scripts should support:

```bash
--dry-run
```

Example:

```bash
./bootstrap.sh --dry-run
```

Shows:

* Commands.
* Changes.
* Files modified.

---

# 26. User Confirmation

Required for destructive actions:

Examples:

* Disk formatting.
* Removing packages.
* Deleting configs.

---

# 27. Error Recovery

When failure happens:

1. Stop.
2. Save logs.
3. Report failed step.
4. Suggest recovery.
5. Allow resume.

---

# 28. Script Testing

Before release:

Test:

* Fresh install.
* Existing installation.
* Interrupted execution.
* Re-run execution.

---

# 29. AI Agent Usage

AI agent should:

Before running:

* Read documentation.
* Explain changes.
* Request confirmation for destructive actions.

After running:

Provide:

```text
Changed:

Installed:

Modified:

Tested:

Remaining:
```

---

# 30. Final Goal

The complete system can be rebuilt using:

```text
One repository

       +

One command

       |

       v

Complete Artix Workstation
```

while remaining:

* transparent,
* repairable,
* maintainable.
