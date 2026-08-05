# ~/.bashrc - Artix Suckless Workstation Bash Configuration
# Version: 1.0

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# History configuration
HISTSIZE=100000
HISTFILESIZE=200000
HISTCONTROL=ignoreboth:erasedups
HISTTIMEFORMAT="%Y-%m-%d %H:%M:%S "
shopt -s histappend
shopt -s checkwinsize

# Source external bash modular files if available
if [[ -f ~/.config/bash/aliases ]]; then
    source ~/.config/bash/aliases
elif [[ -f ~/dotfiles/bash/aliases ]]; then
    source ~/dotfiles/bash/aliases
fi

if [[ -f ~/.config/bash/functions ]]; then
    source ~/.config/bash/functions
elif [[ -f ~/dotfiles/bash/functions ]]; then
    source ~/dotfiles/bash/functions
fi

# Enable bash completion if available
if [[ -f /usr/share/bash-completion/bash_completion ]]; then
    source /usr/share/bash-completion/bash_completion
fi

# Monochrome Prompt Setup
PS1='\[\031[1;37m\]\u@\h\[\033[0m\]:\[\033[0;37m\]\w\[\033[0m\]\$ '

# Environment variables
export EDITOR="nvim"
export VISUAL="nvim"
export TERMINAL="foot"
export BROWSER="zen-browser"
export MOZ_ENABLE_WAYLAND=1
export QT_QPA_PLATFORM=wayland
export SDL_VIDEODRIVER=wayland
export XDG_SESSION_TYPE=wayland

# Autostart dwl if on TTY1 and Wayland is not active
if [ -z "$WAYLAND_DISPLAY" ] && [ "$(tty)" = "/dev/tty1" ]; then
    exec dwl
fi
