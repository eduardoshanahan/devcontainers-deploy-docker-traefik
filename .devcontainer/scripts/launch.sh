#!/bin/bash

# Source color definitions
if [ -f "$HOME/.devcontainer/scripts/colors.sh" ]; then
    source "$HOME/.devcontainer/scripts/colors.sh"
else
    echo "Warning: colors.sh not found, using default colors"
fi

# Source environment variables
if [ -f "/workspace/.devcontainer/config/.env" ]; then
    source "/workspace/.devcontainer/config/.env"
else
    echo "${RED}Error: .env file not found${COLOR_RESET}"
    exit 1
fi

# Validate environment variables
if [ -f "/workspace/.devcontainer/scripts/validate-env.sh" ]; then
    source "/workspace/.devcontainer/scripts/validate-env.sh"
    if [ $? -ne 0 ]; then
        echo "${RED}Environment validation failed. Please check your .env file${COLOR_RESET}"
        exit 1
    fi
else
    echo "${YELLOW}Warning: validate-env.sh not found, skipping environment validation${COLOR_RESET}"
fi

# Configure Git if variables are set
if [ -n "$GIT_USER_NAME" ] && [ -n "$GIT_USER_EMAIL" ]; then
    echo "${GREEN}Configuring Git with:${COLOR_RESET}"
    echo "  ${COLOR_BOLD}Name:${COLOR_RESET}  $GIT_USER_NAME"
    echo "  ${COLOR_BOLD}Email:${COLOR_RESET} $GIT_USER_EMAIL"
    git config --global user.name "$GIT_USER_NAME"
    git config --global user.email "$GIT_USER_EMAIL"
fi

# Make scripts executable
chmod +x /workspace/.devcontainer/scripts/bash-prompt.sh
chmod +x /workspace/.devcontainer/scripts/ssh-agent-setup.sh

# Source scripts in bashrc if not already present
if ! grep -q "source.*bash-prompt.sh" ~/.bashrc; then
    echo 'source /workspace/.devcontainer/scripts/bash-prompt.sh' >> ~/.bashrc
fi

if ! grep -q "source.*ssh-agent-setup.sh" ~/.bashrc; then
    echo 'source /workspace/.devcontainer/scripts/ssh-agent-setup.sh' >> ~/.bashrc
fi 