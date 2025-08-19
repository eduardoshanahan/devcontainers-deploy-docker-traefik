#!/bin/bash
# --- SSH Agent Setup ---

# Exit on error, undefined vars, and pipe failures
set -euo pipefail
IFS=$'\n\t'

# Function to check file permissions
check_file_permissions() {
  local file="$1"
  local expected_perms="$2"
  local actual_perms

  actual_perms=$(stat -c %a "$file")
  if [ "$actual_perms" != "$expected_perms" ]; then
    echo "Warning: $file has incorrect permissions ($actual_perms). Expected: $expected_perms"
    return 1
  fi
  return 0
}

# Check for an interactive shell.
if [[ $- == *i* ]]; then
  # Create .ssh directory with proper permissions if it doesn't exist
  if [ ! -d "$HOME/.ssh" ]; then
    mkdir -p "$HOME/.ssh"
    chmod 700 "$HOME/.ssh"
  else
    check_file_permissions "$HOME/.ssh" "700" || chmod 700 "$HOME/.ssh"
  fi

  # Always start a new SSH agent to ensure clean state
  echo "Starting new SSH agent..."
  eval "$(ssh-agent -s)" >/dev/null

  # Save the agent variables with proper permissions
  umask 077
  {
    echo "export SSH_AUTH_SOCK=${SSH_AUTH_SOCK}"
    echo "export SSH_AGENT_PID=${SSH_AGENT_PID}"
  } >"$HOME/.ssh/agent_env"

  echo "Looking for SSH keys in $HOME/.ssh/"
  
  # Add all private keys
  for key in "$HOME/.ssh/"*; do
    if [ -f "$key" ]; then
      # Skip public keys, known_hosts, and agent_env
      if [[ "$key" != *.pub ]] && [[ "$key" != *known_hosts* ]] && [[ "$key" != *agent_env ]]; then
        echo "Attempting to add private key: $key"
        if check_file_permissions "$key" "600"; then
          if ssh-add "$key" 2>/dev/null; then
            echo "Successfully added key: $key"
          else
            echo "Failed to add key: $key"
          fi
        else
          echo "Warning: $key has incorrect permissions. Skipping."
        fi
      fi
    fi
  done

  # Show all loaded keys
  echo "Currently loaded keys:"
  ssh-add -l
fi

set +e
# --- End SSH Agent Setup ---