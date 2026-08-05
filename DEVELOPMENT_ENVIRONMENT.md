# DEVELOPMENT ENVIRONMENT GUIDE

Version: 1.0

Project: Artix Suckless Workstation

---

# 1. Philosophy

Development environment goals:

```text
Fast startup

+

Keyboard workflow

+

Minimal dependencies

+

Power user capability
```

Ưu tiên:

* Terminal workflow.
* CLI tools.
* Neovim.
* Git.
* Compiler native.

Tránh:

* IDE nặng chạy nền.
* Plugin dư thừa.
* Background services.

---

# 2. Development Package Groups

Structure:

```text
packages/

├── compiler.txt
├── languages.txt
├── editors.txt
├── git.txt
└── tools.txt
```

---

# 3. Base Development Tools

Install:

```bash
sudo pacman -S --needed \
base-devel \
git \
curl \
wget \
make \
cmake \
ninja \
pkgconf
```

Includes:

* gcc
* g++
* make
* linker
* build utilities

---

# 4. C/C++ Environment

Packages:

```bash
sudo pacman -S --needed \
gcc \
clang \
lldb \
gdb \
cmake
```

---

# Compiler Check

```bash
gcc --version

clang --version
```

---

# Debugging

GDB:

```bash
gdb program
```

LLDB:

```bash
lldb program
```

---

# 5. Python Environment

Install:

```bash
sudo pacman -S python python-pip
```

Check:

```bash
python --version
```

---

# Virtual Environment

Create:

```bash
python -m venv .venv
```

Activate:

```bash
source .venv/bin/activate
```

---

# 6. JavaScript / Web Development

Install:

```bash
sudo pacman -S \
nodejs \
npm
```

Check:

```bash
node --version

npm --version
```

---

# 7. Rust Environment

Install:

```bash
sudo pacman -S rustup
```

Setup:

```bash
rustup default stable
```

Check:

```bash
rustc --version
```

---

# 8. Game Development

## Godot

Install:

```bash
sudo pacman -S godot
```

---

## Unity

Use:

* Official Unity Hub.
* Install only required versions.

Avoid keeping multiple engines installed.

---

# 9. Neovim

Primary editor.

Install:

```bash
sudo pacman -S neovim
```

---

# Configuration Structure

```text
~/.config/nvim/

├── init.lua
│
└── lua/
    |
    ├── options.lua
    ├── keymaps.lua
    ├── plugins.lua
    ├── lsp.lua
    └── theme.lua
```

---

# 10. Neovim Goals

Features:

* Syntax highlighting.
* LSP.
* Completion.
* Git integration.
* File navigation.
* Debugging.

---

# 11. Recommended Neovim Plugins

Minimal:

## Plugin Manager

lazy.nvim

Purpose:

Fast plugin loading.

---

## Core Plugins

```text
nvim-lspconfig

nvim-cmp

treesitter

telescope

gitsigns

which-key
```

---

# 12. Language Server Setup

Recommended:

C/C++:

```text
clangd
```

Python:

```text
pyright
```

Rust:

```text
rust-analyzer
```

JavaScript:

```text
typescript-language-server
```

Lua:

```text
lua-language-server
```

---

# 13. Nano

Purpose:

Emergency editor.

Install:

```bash
sudo pacman -S nano
```

Configuration:

```text
~/.nanorc
```

Enable:

* Syntax highlighting.
* Mouse support.
* Line numbers.

---

# 14. LazyGit

Purpose:

Terminal Git interface.

Install:

```bash
sudo pacman -S lazygit
```

Run:

```bash
lazygit
```

---

# 15. Git Configuration

Basic:

```bash
git config --global init.defaultBranch main
```

Editor:

```bash
git config --global core.editor nvim
```

---

# 16. Useful CLI Tools

Recommended:

```bash
sudo pacman -S --needed \
ripgrep \
fd \
fzf \
bat \
eza \
tree \
btop \
htop
```

---

# 17. File Searching

fd:

```bash
fd filename
```

ripgrep:

```bash
rg "text"
```

---

# 18. Terminal Workflow

Example:

```text
Foot

 |

Bash

 |

tmux

 |

Neovim

 |

lazygit
```

---

# 19. tmux

Install:

```bash
sudo pacman -S tmux
```

Purpose:

* Persistent sessions.
* Multiple terminals.

---

# 20. Fonts

Primary:

```text
JetBrains Mono
```

Install:

```bash
sudo pacman -S ttf-jetbrains-mono
```

---

# Secondary:

```text
Monocraft
```

Use as fallback.

---

# 21. Font Configuration

Location:

```text
~/.config/fontconfig/fonts.conf
```

Priority:

```text
JetBrains Mono

>

Monocraft

>

Noto Sans Mono
```

---

# 22. Terminal Development Theme

Style:

```text
Background:
#000000

Foreground:
#FFFFFF

Secondary:
#808080
```

---

# 23. Bash Development Aliases

Example:

```bash
alias c='clear'

alias v='nvim'

alias lg='lazygit'

alias gs='git status'

alias rebuild='make clean install'
```

---

# 24. Git Workflow

Daily:

```bash
git status

git add .

git commit

git push
```

---

# 25. Project Structure

Recommended:

```text
~/Projects/

├── c/
├── cpp/
├── python/
├── javascript/
├── rust/
└── games/
```

---

# 26. Build Cache

Install:

```bash
sudo pacman -S ccache
```

Enable:

```bash
export PATH="/usr/lib/ccache/bin:$PATH"
```

Benefits:

* Faster rebuilds.
* Less CPU usage.

---

# 27. Debug Tools

Install:

```bash
sudo pacman -S \
strace \
ltrace \
valgrind
```

---

# 28. Performance Rules

Avoid:

* Huge IDEs.
* Multiple language servers.
* Unused plugins.

Use:

* Lazy loading.
* Project-specific tools.

---

# 29. Development Checklist

## Editor

* [ ] Neovim works
* [ ] LSP works
* [ ] Git integration works

## Languages

* [ ] C/C++
* [ ] Python
* [ ] JS
* [ ] Rust

## Tools

* [ ] lazygit
* [ ] tmux
* [ ] ripgrep
* [ ] fd

---

# Final Development Environment

```text
Artix Linux

     +

dwl

     +

Foot

     +

Bash

     +

Neovim

     +

LazyGit

     +

Compiler Toolchain

     +

Minimal CLI Workflow
```

Fast, lightweight, and suitable for serious development.
