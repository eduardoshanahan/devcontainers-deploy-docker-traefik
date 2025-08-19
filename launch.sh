#!/bin/bash

# Set strict bash options
set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print error messages
error() {
  echo -e "${RED}ERROR: $1${NC}" >&2
}

# Function to print success messages
success() {
  echo -e "${GREEN}$1${NC}"
}

# Function to print info messages
info() {
  echo -e "${YELLOW}$1${NC}"
}

# Function to check if a variable is set
check_var() {
  local var_name="$1"
  local var_value="$2"
  if [ -z "$var_value" ]; then
    error "$var_name is not set in .devcontainer/config/.env"
    return 1
  fi
  info "$var_name: $var_value"
}

# Check if .env file exists
if [ ! -f .devcontainer/config/.env ]; then
  error ".devcontainer/config/.env file not found!"
  error "Please create it with the following variables:"
  cat <<EOF
# User configuration
HOST_USERNAME=your_username
HOST_UID=your_uid
HOST_GID=your_gid

# Git configuration
GIT_USER_NAME="Your Name"
GIT_USER_EMAIL="your.email@example.com"

# Editor configuration
EDITOR_CHOICE=code  # Use 'code' for VS Code or 'cursor' for Cursor

# Docker configuration
DOCKER_IMAGE_NAME=your-image-name
DOCKER_IMAGE_TAG=your-tag
EOF
  exit 1
fi

# Load environment variables from .devcontainer/config/.env
info "Loading environment variables..."
set -a
source .devcontainer/config/.env
set +a

# Export variables explicitly for devcontainer
export HOST_USERNAME
export HOST_UID
export HOST_GID
export GIT_USER_NAME
export GIT_USER_EMAIL
export EDITOR_CHOICE
export DOCKER_IMAGE_NAME
export DOCKER_IMAGE_TAG

# Verify required variables
required_vars=(
  "HOST_USERNAME"
  "HOST_UID"
  "HOST_GID"
  "GIT_USER_NAME"
  "GIT_USER_EMAIL"
  "EDITOR_CHOICE"
  "DOCKER_IMAGE_NAME"
  "DOCKER_IMAGE_TAG"
)

# Check all required variables
for var in "${required_vars[@]}"; do
  check_var "$var" "${!var:-}" || exit 1
done

# Validate editor choice
if [ "${EDITOR_CHOICE}" != "code" ] && [ "${EDITOR_CHOICE}" != "cursor" ]; then
  error "EDITOR_CHOICE must be set to either 'code' or 'cursor' in .devcontainer/config/.env"
  exit 1
fi

# Check if the chosen editor is installed
if ! command -v "${EDITOR_CHOICE}" &>/dev/null; then
  error "${EDITOR_CHOICE} is not installed!"
  if [ "${EDITOR_CHOICE}" = "code" ]; then
    error "Please install VS Code from https://code.visualstudio.com/"
  else
    error "Please install Cursor from https://cursor.sh"
  fi
  exit 1
fi

# Clean up any existing containers using our image
if docker ps -a | grep -q "${DOCKER_IMAGE_NAME}"; then
  info "Cleaning up existing containers..."
  docker ps -a | grep "${DOCKER_IMAGE_NAME}" | cut -d' ' -f1 | xargs -r docker stop
  docker ps -a | grep "${DOCKER_IMAGE_NAME}" | cut -d' ' -f1 | xargs -r docker rm
fi

# Launch the editor
info "Launching ${EDITOR_CHOICE}..."
if [ "${EDITOR_CHOICE}" = "code" ]; then
  code "${PWD}" >/dev/null 2>&1 &
else
  cursor "${PWD}" --no-sandbox >/dev/null 2>&1 &
fi

success "${EDITOR_CHOICE} launched successfully!"
disown 