# Development Container Scripts

This directory contains various shell scripts that handle different aspects of the development container setup and configuration.

## Scripts Overview

### `bash-prompt.sh`

Configures the shell environment and sets up various aliases:

- Initializes Starship prompt if available
- Sources environment variables and other scripts
- Sets up Git aliases (gs, ga, gc, gp, gl, gd, gco, gb, glog)
- Configures JSON processing aliases (jsonlint, jsonformat, jsonvalidate, jsonpretty)
- Ensures bash is used as the default shell

### `colors.sh`

Defines color variables for terminal output:

- Basic colors (RED, GREEN, YELLOW, BLUE, etc.)
- Bold variants (BOLD_RED, BOLD_GREEN, etc.)
- Utility colors (COLOR_RESET, COLOR_BOLD, COLOR_DIM)
- Used by other scripts for consistent colored output

### `launch.sh`

Main initialization script that:

- Sources color definitions and environment variables
- Validates environment configuration
- Configures Git user information
- Makes scripts executable
- Sets up bashrc to source required scripts
- Handles error reporting with colored output

### `post-create.sh`

Runs after container creation to:

- Source and validate environment variables
- Configure Git user information
- Make scripts executable
- Set up bashrc with required script sources
- Ensures proper initialization of the development environment

### `ssh-agent-setup.sh`

Manages SSH agent configuration:

- Creates .ssh directory with proper permissions
- Starts a new SSH agent
- Saves agent environment variables
- Adds private keys to the agent
- Validates key permissions
- Shows currently loaded keys
- Includes error handling and permission checks

### `validate-env.sh`

Validates environment variables:

- Checks required variables (HOST_USERNAME, HOST_UID, HOST_GID)
- Validates optional variables with defaults
- Uses regex patterns for validation
- Provides detailed error messages
- Returns non-zero exit code on validation failure

## Usage

These scripts are automatically sourced and executed as part of the container setup process. They are designed to work together to provide a consistent development environment.

### Manual Execution

If you need to run any script manually:

```bash
# Make the script executable
chmod +x /workspace/.devcontainer/scripts/script-name.sh

# Run the script
source /workspace/.devcontainer/scripts/script-name.sh
```

### Dependencies

The scripts have the following dependencies:

- `colors.sh` is sourced by other scripts for colored output
- `validate-env.sh` is called by `launch.sh` and `post-create.sh`
- `bash-prompt.sh` and `ssh-agent-setup.sh` are sourced in bashrc

## Customization

You can customize these scripts to:

- Add new aliases in `bash-prompt.sh`
- Modify color schemes in `colors.sh`
- Add new environment variables in `validate-env.sh`
- Change SSH key handling in `ssh-agent-setup.sh`

## Error Handling

All scripts include error handling:

- Exit on undefined variables
- Check for required files
- Validate permissions
- Provide colored error messages
- Return appropriate exit codes

## Security

The scripts implement security best practices:

- Proper file permissions
- Secure SSH key handling
- Environment variable validation
- Safe shell options
- Input validation
