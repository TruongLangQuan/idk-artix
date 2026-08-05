# DWL BUILD GUIDE

Version: 1.0

Project: Artix Suckless Workstation

---

# 1. Overview

dwl is the core graphical environment.

Architecture:

```text
Wayland
   |
wlroots
   |
dwl
   |
slstatus
   |
Applications
```

Goals:

* Minimal compositor.
* Low RAM usage.
* Low latency.
* Keyboard-driven workflow.
* Easy maintenance.

---

# 2. Required Packages

Install build dependencies:

```bash
sudo pacman -S --needed \
git \
base-devel \
wayland \
wayland-protocols \
wlroots \
libinput \
pixman \
cairo \
pango \
libxkbcommon \
mesa \
seatd
```

---

# 3. Create Source Directory

Recommended:

```bash
mkdir -p ~/src
cd ~/src
```

---

# 4. Clone dwl

```bash
git clone https://codeberg.org/dwl/dwl.git
```

Enter:

```bash
cd dwl
```

---

# 5. Patch Strategy

Only use stable community patches.

Allowed categories:

## Layout

Examples:

* alwayscenter
* vanitygaps

Purpose:

Improve window organization.

---

## Workflow

Examples:

* attachaside
* movestack

Purpose:

Better keyboard workflow.

---

## Appearance

Examples:

* alpha (if needed)
* color configuration

Avoid:

* heavy animations
* blur
* unnecessary effects

---

# 6. Patch Management

Create:

```text
~/src/dwl/patches/
```

Example:

```text
patches/

alwayscenter.patch
movestack.patch
vanitygaps.patch
```

Apply:

```bash
patch -p1 < patches/name.patch
```

---

# 7. Configuration

dwl configuration is compiled.

Main file:

```text
config.h
```

Never modify binary files.

---

# 8. Appearance Configuration

Theme:

Monochrome.

Colors:

```c
static const char normfgcolor[] = "#ffffff";
static const char normbgcolor[] = "#000000";

static const char selfgcolor[] = "#000000";
static const char selbgcolor[] = "#808080";
```

No:

* RGB
* gradients
* transparency

---

# 9. Workspace Configuration

Five tags:

```c
static const char *tags[] = {
"1",
"2",
"3",
"4",
"5",
};
```

---

# 10. Keyboard Configuration

Modifier:

```c
#define MODKEY WLR_MODIFIER_LOGO
```

Super key.

---

# 11. Keybindings

## Terminal

Super + T

```c
{ MODKEY, XKB_KEY_t,
spawn, {.v = termcmd } }
```

---

## Launcher

Super

```c
{ MODKEY,
XKB_KEY_space,
spawn,
{.v = menucmd}}
```

---

## Browser

Super + B

```c
{ MODKEY,
XKB_KEY_b,
spawn,
{.v = browsercmd}}
```

---

## Close Window

Super + Q

```c
{ MODKEY,
XKB_KEY_q,
killclient,
{0}}
```

---

## Lock

Super + L

```c
{ MODKEY,
XKB_KEY_l,
spawn,
{.v = lockcmd}}
```

---

# 12. Workspace Keys

Switch:

```text
Super + 1
Super + 2
Super + 3
Super + 4
Super + 5
```

Move:

```text
Super + Shift + 1-5
```

---

# 13. Layouts

Enabled:

## Tile

Default.

## Monocle

Full screen.

## Floating

Manual positioning.

---

# 14. Input Configuration

libinput.

Settings:

* Natural scrolling optional.
* Tap-to-click enabled.
* Disable acceleration if preferred.

Example:

```c
static const enum libinput_config_accel_profile accel_profile =
LIBINPUT_CONFIG_ACCEL_PROFILE_ADAPTIVE;
```

---

# 15. Keyboard Layout

Default:

US.

Secondary:

Vietnamese Telex.

Managed by:

fcitx5.

Switch:

Super + Space.

---

# 16. Startup

Create:

```text
~/.dwl/startup.sh
```

Example:

```bash
#!/usr/bin/env bash

swww-daemon &
cliphist watch &
slstatus &
```

Make executable:

```bash
chmod +x ~/.dwl/startup.sh
```

---

# 17. Compile

Build:

```bash
make clean install
```

Verify:

```bash
which dwl
```

---

# 18. Starting dwl

From TTY:

Login.

Run:

```bash
dwl
```

Optional:

Create:

```text
~/.bash_profile
```

Add:

```bash
if [ -z "$WAYLAND_DISPLAY" ] && [ "$(tty)" = "/dev/tty1" ]; then
    exec dwl
fi
```

---

# 19. Debugging

Start with logs:

```bash
dwl > ~/.dwl.log 2>&1
```

Check:

```bash
cat ~/.dwl.log
```

---

# 20. Performance Rules

Do:

* Keep patches minimal.
* Avoid animations.
* Avoid compositing effects.
* Avoid unnecessary daemons.

Do not:

* Install desktop environment.
* Install extra compositor.
* Add notification daemon.

---

# 21. Validation Checklist

## Basic

* [ ] dwl starts
* [ ] Keyboard works
* [ ] Mouse works
* [ ] Terminal launches
* [ ] Windows tile correctly

## Workflow

* [ ] Five workspaces work
* [ ] Shortcuts work
* [ ] Lock works
* [ ] Screenshot works

## Performance

Check:

```bash
btop
```

Expected:

* Low CPU idle.
* Low RAM usage.

---

# 22. Maintenance

Update:

```bash
cd ~/src/dwl
git pull
```

Before update:

1. Backup config.h.
2. Check patch compatibility.
3. Rebuild.
4. Test.

---

# Final Goal

The final dwl environment should provide:

* Fast Wayland session.
* Minimal resource usage.
* Keyboard-first workflow.
* Stable daily usage.
* Full control by the user.

dwl is the foundation of the entire graphical environment.
