# Configuration System Documentation

This directory contains the unified configuration system for all hosts in the inventory.

## Structure

```text
group_vars/
├── all/
│   └── main.yml            # Unified environment configuration
└── README.md               # This file
```

## Configuration Philosophy

The configuration system follows these principles:

1. **Single Source of Truth**: All configuration is centralized in `group_vars/all/main.yml`
2. **Vault Integration**: Sensitive data is referenced from vault variables
3. **Environment Separation**: Non-sensitive configuration uses environment variables
4. **Host Overrides**: Host-specific settings are defined in `host_vars/`

## Variable Categories

### Server Configuration

- Server IPs and hostnames
- User accounts and SSH keys
- Environment detection

### Application Configuration

- Traefik settings and paths
- Docker network configuration
- Port mappings and security

### Security Configuration

- Admin passwords (from vault)
- SSL/TLS settings
- Firewall configuration

### Monitoring Configuration

- Prometheus buckets
- Logging settings
- Feature flags

## Variable Reference Pattern

```yaml
# Non-sensitive configuration (can use environment variables)
traefik_version: "{{ lookup('env', 'TRAEFIK_VERSION') | default('latest') }}"

# Sensitive configuration (must use vault variables)
traefik_admin_password: "{{ vault_traefik_admin_password }}"

# Configuration with defaults
traefik_log_level: "{{ lookup('env', 'TRAEFIK_LOG_LEVEL') | default('INFO') }}"
```

## Best Practices

1. **Always use vault variables for sensitive data**
2. **Provide sensible defaults for optional values**
3. **Use environment variables for non-sensitive configuration**
4. **Document complex variable relationships**
5. **Keep configuration DRY (Don't Repeat Yourself)**

## Migration Notes

When adding new variables:

1. **Non-sensitive defaults**: Add to `group_vars/all/main.yml`
2. **Sensitive data**: Add to `secrets/vault.yml`
3. **Host-specific**: Add to `host_vars/vps/main.yml`
4. **Environment variables**: Add to `secrets/.env`
