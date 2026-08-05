# STYLE GUIDE

Version: 1.0

---

# Purpose

This document defines coding, scripting, documentation, configuration, and repository conventions.

Every contributor and AI agent must follow these rules.

Consistency is more important than personal preference.

---

# Repository Philosophy

The repository should always feel like it was written by one person.

Formatting, naming, comments, and project structure must remain consistent.

---

# Directory Structure

Each directory has exactly one responsibility.

Example

docs/
configs/
scripts/
packages/
patches/
fonts/
assets/
wallpapers/
benchmark/
healthcheck/
ai-agent/

Never place unrelated files together.

---

# Naming

Directories

lowercase-with-hyphen

Examples

health-check
bootloader
system-config

Files

lowercase_with_underscore

Examples

install_packages.sh
configure_dwl.sh
health_check.sh

Configuration files should retain their original names when required.

Examples

.bashrc
config.h
config.ini

---

# Line Length

Target

100 characters

Maximum

120 characters

Avoid unnecessary wrapping.

---

# Indentation

Shell

4 spaces

Lua

4 spaces

Markdown

No indentation unless required.

Never use tabs unless required by the language.

---

# Shell Scripts

Every shell script begins with

#!/usr/bin/env bash

Use strict mode whenever practical.

Separate

Variables

Functions

Main execution

Never place executable code above function definitions.

---

# Variables

Global variables

UPPER_CASE

Examples

CONFIG_DIR
LOG_FILE

Local variables

snake_case

Examples

package_name
kernel_version

Constants

UPPER_CASE

---

# Functions

Function names

snake_case

Examples

install_packages()

configure_network()

create_snapshot()

Each function should perform one responsibility.

Avoid functions longer than 80 lines.

---

# Error Handling

Always check critical commands.

Prefer explicit error messages.

Example

"Failed to install NetworkManager."

Instead of

"Error"

---

# Logging

Every script should log

Start

End

Warnings

Errors

Success

Logs should be readable by humans.

---

# Comments

Write comments that explain

Why

Not

What

Bad

Enable compression.

Good

Compression reduces SSD writes while improving performance.

---

# Configuration Files

Group related options together.

Separate sections using headers.

Example

Filesystem

Networking

Performance

Appearance

Security

---

# Bash Aliases

Aliases should remain readable.

Good

update_system

Bad

us

Avoid cryptic names.

---

# Lua

Use

snake_case

Avoid global variables.

Split large files into modules.

Each module should have one responsibility.

---

# Markdown

Use

# for title

## for major section

### for subsection

Do not skip heading levels.

Use fenced code blocks.

Always specify language.

Example

```bash
pacman -S foot
```

---

# Tables

Use tables when comparing options.

Use lists for sequential steps.

Avoid large walls of text.

---

# Package Lists

Sort alphabetically within categories.

Group packages by purpose.

Example

Audio

Editors

Networking

Utilities

Development

---

# Git

Commit messages

Imperative mood

Examples

Add Btrfs snapshot configuration

Improve Bash history handling

Update dwl patches

Avoid vague messages.

Examples

Fix stuff

Update

Changes

---

# Documentation

Every document should answer

What

Why

How

Trade-offs

Related files

Further reading

---

# Patch Management

Store one patch per file.

Patch names should describe functionality.

Example

dwl-always-center.patch

dwl-smart-gaps.patch

Avoid generic names.

---

# Wallpapers

Store separately

static/

dynamic/

Use descriptive filenames.

---

# Fonts

Never modify upstream fonts.

Only package and configure them.

---

# Scripts

One script

One purpose

Do not create monolithic scripts.

Shared logic belongs in reusable libraries.

---

# Configuration Philosophy

Prefer

Explicit values

Readable structure

Predictable behavior

Avoid

Magic numbers

Hidden defaults

Implicit behavior

---

# Performance

Optimize only after measuring.

Document every optimization.

Never reduce readability for micro-optimizations.

---

# Security

Do not store

Passwords

Secrets

Private keys

Tokens

Configuration templates should use placeholders.

---

# AI Generated Code

AI output must

Compile

Run

Be formatted

Be documented

Match repository style

Avoid unnecessary abstraction.

---

# Code Review Checklist

Before accepting any change

Consistent formatting

Naming follows conventions

Documentation updated

No duplicated logic

No unnecessary dependencies

No dead code

No unused configuration

No conflicting packages

No broken scripts

---

# Quality Standard

Every file should be understandable by an experienced Linux user without external explanation.

Readable code is preferred over clever code.

Maintainability is preferred over brevity.

Consistency is preferred over individual style.

---

# Final Principle

If two implementations provide similar functionality, always choose the one that is simpler to understand, easier to maintain, and more consistent with the Suckless philosophy.
