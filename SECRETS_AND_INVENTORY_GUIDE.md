# Secrets and Inventory Directory Guide

## Overview

This document provides a comprehensive guide to the `secrets/` and `src/inventory/` directories, explaining their purpose, structure, and how they work together to provide a secure and organized configuration management system for Ansible-based infrastructure projects.

## Table of Contents

1. [Secrets Directory](#secrets-directory)
2. [Inventory Directory](#inventory-directory)
3. [Security Architecture](#security-architecture)
4. [Variable Precedence](#variable-precedence)
5. [Best Practices](#best-practices)
6. [Migration Guide](#migration-guide)
7. [Troubleshooting](#troubleshooting)

---

## Secrets Directory

### Purpose

The `secrets/` directory serves as a centralized, secure storage location for all sensitive configuration data. It replaces the old vault structure and provides a cleaner separation between sensitive and non-sensitive configuration.

### Structure

```text
secrets/
├── vault.yml              # Encrypted Ansible vault file (main secrets)
├── vault.example.yml      # Example configuration template
├── vault.decrypted.yml    # Decrypted version for reference
├── .env                   # Environment variables and non-sensitive config
├── .vault_pass           # Vault password file
├── README.md             # Directory documentation
└── .gitignore           # Git ignore rules
```

### Key Files

#### `vault.yml`

- **Purpose**: Main encrypted file containing all sensitive data
- **Encryption**: Uses Ansible Vault for encryption
- **Content**: Server IPs, passwords, API keys, SSH keys, email credentials
- **Access**: Requires vault password to view/edit

#### `vault.example.yml`

- **Purpose**: Template showing the structure and example values
- **Security**: Contains no real sensitive data
- **Usage**: Copy to `vault.yml` and replace with real values

#### `.env`

- **Purpose**: Non-sensitive environment variables
- **Content**: Ansible configuration paths, Docker settings, monitoring thresholds
- **Usage**: Can be sourced directly or used by scripts

### Security Features

- **Git Ignored**: All files in `secrets/` are ignored by git
- **Encryption**: Sensitive data is encrypted with Ansible Vault
- **Separation**: Clear separation between sensitive and non-sensitive data
- **Backup**: Vault passwords should be backed up securely

### Usage Examples

```bash
# Edit vault file
ansible-vault edit secrets/vault.yml

# View vault file
ansible-vault view secrets/vault.yml

# Source environment variables
source secrets/.env

# Run playbooks with vault
ansible-playbook -i src/inventory playbooks/full.yml --ask-vault-pass
```

## Inventory Directory

### Inventory Purpose

The `src/inventory/` directory contains the Ansible inventory configuration organized following best practices. It provides a hierarchical variable system that separates behavior configuration from environment-specific values.

### Inventory Structure

```text
src/inventory/
├── hosts.yml                    # Host definitions and group memberships
├── known_hosts                  # SSH known hosts file
├── group_vars/
│   ├── all/
│   │   └── main.yml            # Unified environment configuration
│   └── README.md               # Configuration system documentation
├── host_vars/
│   └── vps/
│       └── main.yml            # Host-specific variables
├── README.md                   # Inventory documentation
└── SECURITY.md                 # Security guidelines
```

### Inventory Key Files

#### `hosts.yml`

- **Purpose**: Defines hosts and their group memberships
- **Structure**: Single environment configuration (no production/staging/development)
- **Security**: References vault variables for sensitive data

```yaml
all:
  hosts:
    vps:
      ansible_host: "{{ vault_vps_server_ip }}"
      ansible_user: "{{ vault_initial_deployment_user }}"
      ansible_ssh_private_key_file: "{{ vault_initial_deployment_ssh_key }}"
```

#### `group_vars/all/main.yml`

- **Purpose**: Unified environment configuration for all hosts
- **Content**: Server configuration, security settings, monitoring, containers
- **Security**: References vault variables for sensitive data

#### `host_vars/vps/main.yml`

- **Purpose**: Host-specific configuration overrides
- **Content**: Feature flags, Docker settings, security policies
- **Precedence**: Takes precedence over group variables

### Variable Reference System

The inventory uses a sophisticated variable reference system:

```yaml
# In group_vars/all/main.yml - references vault variables
vps_server_ip: "{{ vault_vps_server_ip }}"
configure_security_updates_email: "{{ vault_configure_security_updates_email }}"

# In vault.yml - actual sensitive values
vault_vps_server_ip: "192.168.1.100"
vault_configure_security_updates_email: "admin@example.com"
```

## Security Architecture

### Multi-Layer Security

1. **Git Ignore Protection**: Sensitive files are automatically ignored
2. **Ansible Vault Encryption**: Sensitive data is encrypted at rest
3. **Variable Separation**: Clear separation between sensitive and non-sensitive data
4. **Environment Variables**: Non-sensitive configuration in `.env` files
5. **Access Control**: Vault password required for sensitive data access

### Security Best Practices

#### Safe to Commit

- `src/inventory/hosts.yml` (no sensitive data)
- `src/inventory/group_vars/all/main.yml` (references vault variables)
- `src/inventory/host_vars/vps/main.yml` (no sensitive data)
- `secrets/vault.example.yml` (template only)
- `secrets/.env` (non-sensitive environment variables)

#### Never Commit

- `secrets/vault.yml` (encrypted sensitive data)
- `secrets/.vault_pass` (vault password)
- SSH private keys
- Database passwords
- API keys
- Email credentials

### Emergency Procedures

If secrets are accidentally committed:

```bash
# Remove from git history
git filter-branch --force --index-filter \
  'git rm --cached --ignore-unmatch secrets/vault.yml' \
  --prune-empty --tag-name-filter cat -- --all

# Force push to remove from remote
git push origin --force --all
```

---

## Variable Precedence

Understanding variable precedence is crucial for configuration management:

1. **Role defaults** (`src/roles/[role]/defaults/main.yml`)
2. **Base configuration** (`group_vars/all/main.yml`)
3. **Host-specific** (`host_vars/vps/main.yml`)
4. **Playbook variables** (defined in playbook)
5. **Extra variables** (`-e` command line)

### Example Precedence

```yaml
# Role default
configure_security_updates_enabled: false

# Group var override
configure_security_updates_enabled: true

# Host var override (wins)
configure_security_updates_enabled: false
```

---

## Best Practices

### 1. Configuration Organization

- **Separate concerns**: Behavior vs environment values
- **Use vault references**: Always reference vault variables for sensitive data
- **Provide defaults**: Use `| default()` filters for optional values
- **Document structure**: Keep README files updated

### 2. Security Practices

- **Never hardcode secrets**: Always use vault variables
- **Regular audits**: Review committed files for secrets
- **Use templates**: Create `.example.yml` files for documentation
- **Backup passwords**: Keep vault passwords in secure locations

### 3. Development Workflow

```bash
# 1. Set up vault
cp secrets/vault.example.yml secrets/vault.yml
# Edit secrets/vault.yml with real values
ansible-vault encrypt secrets/vault.yml

# 2. Configure environment
source secrets/.env

# 3. Test configuration
ansible-playbook -i src/inventory playbooks/test.yml --ask-vault-pass

# 4. Deploy
ansible-playbook -i src/inventory playbooks/full.yml --ask-vault-pass
```

### 4. Adding New Variables

1. **Non-sensitive defaults**: Add to `group_vars/all/main.yml`
2. **Sensitive data**: Add to `secrets/vault.yml`
3. **Host-specific**: Add to `host_vars/vps/main.yml`
4. **Environment variables**: Add to `secrets/.env`

---

## Migration Guide

### From Old Structure

If migrating from an older structure:

#### Old Structure

```text
src/inventory/group_vars/all/vault.yml  # Old vault location
src/inventory/group_vars/all/defaults.yml
src/inventory/group_vars/all/all.yml
```

#### New Structure

```text
secrets/vault.yml                        # New vault location
src/inventory/group_vars/all/main.yml   # Unified configuration
```

### Migration Steps

1. **Move vault file**:

   ```bash
   mv src/inventory/group_vars/all/vault.yml secrets/vault.yml
   ```

2. **Update ansible.cfg**:

   ```ini
   vault_password_file = secrets/.vault_pass
   ```

3. **Update playbooks**:

   ```yaml
   # Old reference
   - include_vars: src/inventory/group_vars/all/vault.yml
   
   # New reference (automatic via vault)
   # No explicit include needed
   ```

4. **Test configuration**:

   ```bash
   ansible-playbook -i src/inventory playbooks/test.yml --ask-vault-pass
   ```

---

## Troubleshooting

### Common Issues

#### 1. Vault Password Issues

```bash
# Error: Vault password file not found
# Solution: Set ANSIBLE_VAULT_PASSWORD_FILE
export ANSIBLE_VAULT_PASSWORD_FILE=/path/to/secrets/.vault_pass
```

#### 2. Variable Not Found

```bash
# Error: 'vault_variable' is undefined
# Solution: Check vault.yml contains the variable
ansible-vault view secrets/vault.yml | grep vault_variable
```

#### 3. Permission Issues

```bash
# Error: Permission denied for vault file
# Solution: Check file permissions
chmod 600 secrets/vault.yml
chmod 600 secrets/.vault_pass
```

#### 4. Git Ignore Issues

```bash
# Error: Sensitive file committed
# Solution: Check .gitignore and remove from history
git check-ignore secrets/vault.yml
```

### Debug Commands

```bash
# Check vault file structure
ansible-vault view secrets/vault.yml

# Validate inventory
ansible-inventory -i src/inventory --list

# Test variable resolution
ansible -i src/inventory all -m debug -a "var=vault_vps_server_ip" --ask-vault-pass

# Check environment variables
source secrets/.env && env | grep ANSIBLE
```

## Conclusion

This configuration system provides a robust, secure, and maintainable approach to managing infrastructure configuration. The separation of concerns between the `secrets/` and `src/inventory/` directories ensures that sensitive data is properly protected while maintaining flexibility and ease of use.

Key benefits:

- **Security**: Multi-layer protection for sensitive data
- **Organization**: Clear structure and separation of concerns
- **Maintainability**: Centralized configuration management
- **Scalability**: Easy to add new environments or hosts
- **Documentation**: Comprehensive guides and examples
