# Ansible Project Structure Rules

## Symlink Directory Structure

- The `src/roles/roles/` directory is a symlink to `src/roles/`
- The `src/playbooks/roles/` directory is also a symlink to `src/roles/`
- This is intentional and correct for Ansible project organization
- Do not treat these as duplicate or nested directory issues
- When analyzing the project structure, recognize that all these directories point to the same location: `src/roles/`
- Focus on the actual role implementations in `src/roles/` directory

## Role Organization

- All Ansible roles are located in `src/roles/`
- The symlink structure is used to maintain proper Ansible conventions
- When checking for missing roles, only look in `src/roles/` directory
- Ignore the apparent "nested" structure as it's just symlinks

## File Analysis Context

- When analyzing missing components, focus on the actual file structure in `src/roles/`
- The symlink structure is not an issue that needs to be fixed
- This is a standard pattern in Ansible projects for role organization
- Do not suggest deleting "duplicate" directories that are actually symlinks

## Project Structure Understanding

- The project uses standard Ansible conventions with roles in `src/roles/`
- The symlink pattern is intentional and should not be flagged as an issue
- When providing analysis or suggestions, base them on the actual directory structure, not the symlink appearance
- Always verify if directories are symlinks before suggesting deletion

## Common Misconceptions to Avoid

- Do not suggest removing `src/roles/roles/` or `src/playbooks/roles/` as "duplicates"
- Do not treat the symlink structure as a recursive directory problem
- When analyzing orphaned files, only consider the actual `src/roles/` directory
- Remember that Ansible uses symlinks for role organization conventions
