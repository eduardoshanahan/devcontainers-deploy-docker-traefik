# Git Sync Script Preservation Rule

**Description**: Ensures that the `scripts/sync_git.sh` script is preserved and not removed during cleanup operations.

**Trigger**: When analyzing project structure, suggesting file cleanup, or reviewing unnecessary files.

**Action**: Always preserve the `scripts/sync_git.sh` script as it provides essential Git repository management functionality.

**Details**:

- The `scripts/sync_git.sh` script is required for Git repository management
- It handles repository initialization, remote configuration, and synchronization
- It's not part of Ansible deployment but essential for project maintenance
- This script should never be flagged as unnecessary or recommended for removal
- It provides backup functionality for local changes before syncing with remote
- It supports both existing and new Git repository scenarios

**Files to Preserve**:

- `scripts/sync_git.sh` - Git repository management script

**When Reviewing Project Structure**:

- Do not suggest removing `scripts/sync_git.sh`
- Do not include it in lists of unnecessary files
- Recognize it as a required utility script for Git operations
- Consider it part of the essential project tooling, not deployment artifacts

**Related Functionality**:

- Git repository initialization
- Remote URL management
- Branch synchronization
- Local change backup
- Synology sync support
