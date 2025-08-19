#!/bin/bash

# Enable Starship prompt first
if command -v starship >/dev/null 2>&1; then
    eval "$(starship init bash)"
fi

# Source environment variables
if [ -f "/workspace/.devcontainer/config/.env" ]; then
    source "/workspace/.devcontainer/config/.env"
else
    echo "Error: .env file not found"
    exit 1
fi

if [ -f /etc/container.env ]; then
    source /etc/container.env
fi

# Source SSH agent setup
if [ -f "$HOME/.devcontainer/scripts/ssh-agent-setup.sh" ]; then
    source "$HOME/.devcontainer/scripts/ssh-agent-setup.sh"
fi

# Source color definitions
if [ -f "$HOME/.devcontainer/scripts/colors.sh" ]; then
    source "$HOME/.devcontainer/scripts/colors.sh"
else
    echo "Warning: colors.sh not found, using default colors"
fi

# Only set up prompt in interactive shells
case $- in
    *i*) ;;
    *) return;;
esac

# Git aliases
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git pull'
alias gd='git diff'
alias gco='git checkout'
alias gb='git branch'
alias glog='git log --oneline --graph --decorate'

# JSON linting aliases
alias jsonlint='jq "."'
alias jsonformat='jq "."'
alias jsonvalidate='jq empty'
alias jsonpretty='jq "."'

# Export SHELL variable to ensure bash is used
export SHELL=/bin/bash 