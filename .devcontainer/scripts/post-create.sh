#!/bin/bash

# Source environment variables
if [ -f "/workspace/.devcontainer/config/.env" ]; then
    source "/workspace/.devcontainer/config/.env"
else
    echo "Error: .env file not found"
    exit 1
fi

# Validate environment variables
if [ -f "/workspace/.devcontainer/scripts/validate-env.sh" ]; then
    source "/workspace/.devcontainer/scripts/validate-env.sh"
    if [ $? -ne 0 ]; then
        echo "Environment validation failed. Please check your .env file"
        exit 1
    fi
else
    echo "Warning: validate-env.sh not found, skipping environment validation"
fi

# Configure Git if variables are set
if [ -n "$GIT_USER_NAME" ] && [ -n "$GIT_USER_EMAIL" ]; then
    echo "Configuring Git with:"
    echo "  Name:  $GIT_USER_NAME"
    echo "  Email: $GIT_USER_EMAIL"
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