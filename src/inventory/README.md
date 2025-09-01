# Inventory Directory

This directory contains the Ansible inventory configuration organized following best practices. It provides a hierarchical variable system that separates behavior configuration from environment-specific values.

## Structure

```text
src/inventory/
├── hosts.yml # Host definitions and group memberships
├── known_hosts # SSH known hosts file
├── group_vars/
│ ├── all/
│ │ └── main.yml # Unified configuration
│ └── README.md # Configuration system documentation
├── host_vars/
│ └── vps/
│ └── main.yml # Host-specific variables
├── README.md # Inventory documentation
└── SECURITY.md # Security guidelines
```

## Key Files

### `hosts.yml`

- **Purpose**: Defines hosts and their group memberships
- **Structure**: Single environment configuration (no production/staging/development)
- **Security**: References vault variables for sensitive data

### `group_vars/all/main.yml`

- **Purpose**: Unified configuration for all hosts
- **Content**: Server configuration, security settings, monitoring, containers
- **Security**: References vault variables for sensitive data

### `host_vars/vps/main.yml`

- **Purpose**: Host-specific configuration overrides
- **Content**: Feature flags, Docker settings, security policies
- **Precedence**: Takes precedence over group variables

## Variable Reference System

The inventory uses a sophisticated variable reference system:

```yaml
# In group_vars/all/main.yml - references vault variables
vps_server_ip: "{{ vault_vps_server_ip }}"
configure_security_updates_email: "{{ vault_configure_security_updates_email }}"

# In vault.yml - actual sensitive values
vault_vps_server_ip: "192.168.1.100"
vault_configure_security_updates_email: "admin@example.com"
```

## Variable Precedence

Understanding variable precedence is crucial for configuration management:

1. **Role defaults** (`src/roles/[role]/defaults/main.yml`)
2. **Base configuration** (`group_vars/all/main.yml`)
3. **Host-specific** (`host_vars/vps/main.yml`)
4. **Playbook variables** (defined in playbook)
5. **Extra variables** (`-e` command line)

## Usage

```bash
# Validate inventory
ansible-inventory -i src/inventory --list

# Test variable resolution
ansible -i src/inventory all -m debug -a "var=vault_vps_server_ip" --ask-vault-pass

# Run playbooks
ansible-playbook -i src/inventory playbooks/full.yml --ask-vault-pass
```

## Security

- All sensitive data is stored in `secrets/vault.yml`
- Inventory files reference vault variables, not actual values
- Clear separation between behavior and environment configuration
- Host-specific overrides for feature flags and settings

## Simplified Architecture

This inventory follows a simplified single-environment approach:

- **No environment separation**: Single configuration for all deployments
- **Feature flags**: Use host-specific variables to enable/disable features
- **Unified configuration**: All settings in `group_vars/all/main.yml`
- **Host overrides**: Specific settings in `host_vars/vps/main.yml`

## Key Files

### `hosts.yml`

- **Purpose**: Defines hosts and their group memberships
- **Structure**: Single environment configuration (no production/staging/development)
- **Security**: References vault variables for sensitive data

### `group_vars/all/main.yml`

- **Purpose**: Unified environment configuration for all hosts
- **Content**: Server configuration, security settings, monitoring, containers
- **Security**: References vault variables for sensitive data

### `host_vars/vps/main.yml`

- **Purpose**: Host-specific configuration overrides
- **Content**: Feature flags, Docker settings, security policies
- **Precedence**: Takes precedence over group variables

## Variable Reference System

The inventory uses a sophisticated variable reference system:

```yaml
# In group_vars/all/main.yml - references vault variables
vps_server_ip: "{{ vault_vps_server_ip }}"
configure_security_updates_email: "{{ vault_configure_security_updates_email }}"

# In vault.yml - actual sensitive values
vault_vps_server_ip: "192.168.1.100"
vault_configure_security_updates_email: "admin@example.com"
```

## Variable Precedence

Understanding variable precedence is crucial for configuration management:

1. **Role defaults** (`src/roles/[role]/defaults/main.yml`)
2. **Base configuration** (`group_vars/all/main.yml`)
3. **Host-specific** (`host_vars/vps/main.yml`)
4. **Playbook variables** (defined in playbook)
5. **Extra variables** (`-e` command line)

## Usage

```bash
# Validate inventory
ansible-inventory -i src/inventory --list

# Test variable resolution
ansible -i src/inventory all -m debug -a "var=vault_vps_server_ip" --ask-vault-pass

# Run playbooks
ansible-playbook -i src/inventory playbooks/full.yml --ask-vault-pass
```

## Security

- All sensitive data is stored in `secrets/vault.yml`
- Inventory files reference vault variables, not actual values
- Clear separation between behavior and environment configuration
- Host-specific overrides for feature flags and settings
