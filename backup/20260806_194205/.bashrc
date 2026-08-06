#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
PS1='[\u@\h \W]\$ '


# Added by Antigravity CLI installer
export PATH="/home/truonglangquan/.local/bin:$PATH"
export PATH="/home/truonglangquan/.local/bin:$PATH"
export PATH="/home/truonglangquan/.local/bin:$PATH"
export PATH="/home/truonglangquan/.local/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"

eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv bash)"

eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv bash)"
