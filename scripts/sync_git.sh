#!/bin/bash

# Enable strict mode
set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Print functions
info() { echo -e "${YELLOW}  $1${NC}"; }
success() { echo -e "${GREEN} $1${NC}"; }
error() { echo -e "${RED} $1${NC}" >&2; }

# Get the actual project directory (parent of scripts directory)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

# Load environment variables if .env file exists
if [ -f "$PROJECT_DIR/.devcontainer/config/.env" ]; then
    source "$PROJECT_DIR/.devcontainer/config/.env"
fi

# Configuration with defaults
BRANCH="${BRANCH:-main}"
FORCE_PULL="${FORCE_PULL:-false}"
GIT_REMOTE_URL="${GIT_REMOTE_URL:-}"

# Function to backup local changes
backup_local_changes() {
    local backup_dir="$PROJECT_DIR/backup_$(date +%Y%m%d_%H%M%S)"
    info "Creating backup in $backup_dir..."
    mkdir -p "$backup_dir"
    git diff > "$backup_dir/local_changes.patch"
    git status --porcelain | while read -r status file; do
        if [[ $status == "??" ]]; then
            cp --parents "$file" "$backup_dir/"
        fi
    done
    success "Backup created in $backup_dir"
}

# Function to configure Git user if not already set
configure_git_user() {
    if [ -n "${GIT_USER_NAME:-}" ] && [ -n "${GIT_USER_EMAIL:-}" ]; then
        if [ "$(git config --global user.name 2>/dev/null)" != "$GIT_USER_NAME" ]; then
            git config --global user.name "$GIT_USER_NAME"
            info "Git user name set to: $GIT_USER_NAME"
        fi
        if [ "$(git config --global user.email 2>/dev/null)" != "$GIT_USER_EMAIL" ]; then
            git config --global user.email "$GIT_USER_EMAIL"
            info "Git user email set to: $GIT_USER_EMAIL"
        fi
    fi
}

# Main script
main() {
    cd "$PROJECT_DIR" || { error "Project directory not found!"; exit 1; }
    info "Working in directory: $PROJECT_DIR"

    # Check if .git exists
    if [ ! -d ".git" ]; then
        info "No .git folder found. Initializing git repository..."
        
        # Check if remote URL is provided
        if [ -z "$GIT_REMOTE_URL" ]; then
            error "No GIT_REMOTE_URL environment variable set. Please set it in your .env file."
            exit 1
        fi

        # Initialize git repository
        git init

        # Configure Git user
        configure_git_user

        # Add remote
        git remote add origin "$GIT_REMOTE_URL"
        
        # If files exist, add them to git
        if [ -n "$(ls -A .)" ]; then
            info "Existing files detected. Adding them to git..."
            git add .
            git commit -m "Initial commit of existing files"
        fi

        # Handle remote branch logic properly
        info "Fetching from remote and setting up branch $BRANCH..."
        git fetch origin
        
        if git ls-remote --heads origin "$BRANCH" | grep -q "$BRANCH"; then
            # Remote branch exists - pull it and merge with local changes
            info "Remote branch $BRANCH exists. Pulling and merging..."
            if [ -n "$(git log --oneline 2>/dev/null)" ]; then
                # We have local commits, need to merge with remote
                git pull origin "$BRANCH" --allow-unrelated-histories
            else
                # No local commits, just checkout the remote branch
                git checkout -b "$BRANCH" "origin/$BRANCH"
            fi
        else
            # Remote branch doesn't exist, create it
            info "Remote branch $BRANCH doesn't exist. Creating it..."
            # Check if we're already on the main branch
            if git branch --show-current 2>/dev/null | grep -q "^$BRANCH$"; then
                info "Already on $BRANCH branch, pushing to remote..."
            else
                git checkout -b "$BRANCH"
            fi
            git push -u origin "$BRANCH"
        fi
        
        success "Git repository initialized and synced with remote."
        exit 0
    fi

    # Get current remote URL
    REMOTE_URL=$(git remote get-url origin 2>/dev/null || echo "")

    if [ -z "$REMOTE_URL" ]; then
        if [ -n "$GIT_REMOTE_URL" ]; then
            info "Adding remote URL from environment variable..."
            git remote add origin "$GIT_REMOTE_URL"
            REMOTE_URL="$GIT_REMOTE_URL"
        else
            error "No remote URL configured. Please set GIT_REMOTE_URL in your .env file."
            exit 1
        fi
    fi

    success "Git repository found with remote: $REMOTE_URL"

    # Configure Git user
    configure_git_user

    # Check if we're in detached HEAD state
    if ! git symbolic-ref HEAD &>/dev/null; then
        info "Detached HEAD state detected. Checking out $BRANCH..."
        git checkout "$BRANCH" || git checkout -b "$BRANCH"
    fi

    info "Syncing with remote repository..."

    if [ "$FORCE_PULL" = true ]; then
        info "Force pulling and overwriting local changes..."
        backup_local_changes
        git fetch origin
        git reset --hard "origin/$BRANCH"
        git clean -fd  # Remove untracked files and directories
    else
        # Check if we have any commits
        if ! git rev-parse HEAD &>/dev/null; then
            info "No commits found. Initializing repository..."
            if [ -n "$(ls -A .)" ]; then
                git add .
                git commit -m "Initial commit"
            fi
            git pull origin "$BRANCH" || {
                info "No remote branch found. Creating new branch..."
                git push -u origin "$BRANCH"
            }
        else
            # Check for local changes
            if ! git diff-index --quiet HEAD --; then
                error "Local changes detected. Please commit or stash them first."
                error "Or set FORCE_PULL to overwrite local changes -> FORCE_PULL=true ./scripts/sync_git.sh"
                exit 1
            fi
            git pull origin "$BRANCH"
        fi
    fi

    success "Git sync complete!"
}

# Run main function
main "$@"
