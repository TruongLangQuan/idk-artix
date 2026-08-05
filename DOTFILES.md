# DOTFILES GUIDE

Version: 1.0

Project: Artix Suckless Workstation

---

# 1. Overview

Dotfiles contain all user-level configuration.

Goals:

* Reproducible setup.
* Easy backup.
* Easy migration.
* Version control.
* AI-agent friendly.

Architecture:

```text
Repository

      |

      v

dotfiles/

      |

      v

~/.config/

      |

      v

Applications
```

---

# 2. Repository Structure

Recommended:

```text
dotfiles/

├── bash/
│   ├── bashrc
│   ├── aliases
│   └── functions
│
├── dwl/
│   ├── config.h
│   ├── patches/
│   └── startup.sh
│
├── slstatus/
│   ├── config.h
│   └── components/
│
├── foot/
│   └── foot.ini
│
├── fuzzel/
│   └── fuzzel.ini
│
├── nvim/
│   ├── init.lua
│   └── lua/
│
├── swaylock/
│   └── config
│
├── fcitx5/
│   └── config
│
├── mpv/
│   └── mpv.conf
│
├── swww/
│   └── wallpaper.sh
│
└── scripts/
    ├── install.sh
    └── update.sh
```

---

# 3. Installation Method

Preferred:

Symlink method.

Example:

```bash
ln -s ~/dotfiles/foot ~/.config/foot
```

Advantages:

* Changes instantly apply.
* Easy version control.
* No duplicated files.

---

# 4. Backup Strategy

Backup includes:

## System

```text
/etc/
```

Important:

* fstab
* grub config
* OpenRC services

---

## User

```text
~/.config/
~/.bashrc
~/.profile
```

---

## Source Code

```text
~/src/
```

Contains:

* dwl
* slstatus
* custom tools

---

# 5. Bash Configuration

Location:

```text
bash/
```

Files:

```text
bashrc
aliases
functions
```

---

# 6. Bash Goals

Provide:

* Fast startup.
* Useful aliases.
* Command history.
* Completion.
* Git helpers.

Avoid:

* Heavy frameworks.
* Slow startup scripts.

---

# 7. Bash History

Configuration:

```bash
HISTSIZE=100000
HISTFILESIZE=200000
```

Features:

* Ignore duplicates.
* Append history.
* Timestamp commands.

---

# 8. Aliases

Examples:

```bash
alias ll='ls -lah'

alias gs='git status'

alias rebuild-dwl='cd ~/src/dwl && make clean install'
```

Avoid:

Cryptic aliases.

---

# 9. Foot Configuration

Location:

```text
foot/foot.ini
```

Design:

Monochrome.

Font:

Primary:

```text
JetBrains Mono
```

Fallback:

```text
Monocraft
```

---

Settings:

* Black background.
* White text.
* No transparency.
* Minimal padding.
* Fast rendering.

---

# 10. Fuzzel Configuration

Location:

```text
fuzzel/fuzzel.ini
```

Purpose:

* Application launcher.
* Clipboard menu.
* Script UI.

Theme:

```text
Background:
Black

Text:
White

Selection:
Grey
```

---

# 11. Neovim Configuration

Location:

```text
nvim/
```

Structure:

```text
nvim/

├── init.lua
│
└── lua/
    ├── options.lua
    ├── keymaps.lua
    ├── plugins.lua
    ├── lsp.lua
    └── theme.lua
```

---

# 12. Neovim Philosophy

Priorities:

1. Fast startup.
2. Developer workflow.
3. Stability.

Avoid:

* Huge configurations.
* Unused plugins.

---

# 13. DWL Configuration

Location:

```text
dwl/
```

Contains:

```text
config.h
patches/
startup.sh
```

---

# 14. DWL Startup

Example:

```bash
#!/usr/bin/env bash

slstatus &

swww-daemon &

wl-paste --watch cliphist store &

fcitx5 -d &
```

---

# 15. Wallpaper Configuration

Location:

```text
swww/
```

Scripts:

```text
wallpaper-static.sh

wallpaper-live.sh

wallpaper-stop.sh
```

---

# 16. MPV Configuration

Location:

```text
mpv/mpv.conf
```

Goals:

* Hardware acceleration.
* Intel VAAPI.
* Low resource usage.

Example:

```text
hwdec=vaapi
vo=gpu
```

---

# 17. Swaylock Configuration

Location:

```text
swaylock/config
```

Style:

* Black background.
* White indicator.
* No animation.

---

# 18. Fcitx5 Configuration

Location:

```text
fcitx5/
```

Layouts:

```text
US

Vietnamese Telex
```

Toggle:

```text
Super + Space
```

---

# 19. Scripts

Directory:

```text
scripts/
```

Contains:

```text
install.sh

bootstrap.sh

backup.sh

restore.sh

healthcheck.sh
```

---

# 20. Bootstrap Script

Purpose:

Fresh system setup.

Example:

```bash
./bootstrap.sh
```

Actions:

* Install packages.
* Link configs.
* Enable services.
* Build dwl/slstatus.

---

# 21. Update Script

Purpose:

Maintain system.

Actions:

* Update packages.
* Update source.
* Rebuild suckless software.
* Backup configs.

---

# 22. Health Check Script

Checks:

System:

```text
Kernel
OpenRC
Services
Filesystem
```

Graphics:

```text
Wayland
GPU
dwl
```

Applications:

```text
PipeWire
Browser
Clipboard
```

---

# 23. Git Management

Repository:

```text
dotfiles.git
```

Commit examples:

```text
Add foot monochrome theme

Update dwl keybindings

Improve Neovim LSP config
```

---

# 24. Security Rules

Never commit:

```text
.env

passwords

private keys

tokens

SSH secrets
```

---

# 25. Final Dotfiles Goal

The complete environment should be recoverable:

```text
Fresh Artix Install

        |

        v

Clone Repository

        |

        v

Run bootstrap.sh

        |

        v

Complete Workstation
```

---

# Result

The user should be able to rebuild the entire environment from:

* package list
* scripts
* dotfiles
* documentation

without manual configuration.
