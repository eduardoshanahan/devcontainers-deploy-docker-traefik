# Security Guidelines

This document outlines security best practices for the Ansible inventory configuration.

## Safe to Commit

The following files are safe to commit to version control:

- `src/inventory/hosts.yml` (no sensitive data)
- `src/inventory/group_vars/all/main.yml` (references vault variables)
- `src/inventory/host_vars/vps/main.yml` (no sensitive data)
- `src/inventory/README.md` (documentation)
- `src/inventory/SECURITY.md` (this file)

## Never Commit

The following files should NEVER be committed:

- `secrets/vault.yml` (encrypted sensitive data)
- `secrets/.vault_pass` (vault password)
- SSH private keys
- Database passwords
- API keys
- Email credentials
- SSL certificates and private keys

## Security Best Practices

### 1. Variable Separation

- **Sensitive data**: Store in `secrets/vault.yml`
- **Non-sensitive data**: Store in inventory files
- **Environment variables**: Use for non-sensitive configuration

### 2. Vault Usage

- Always encrypt sensitive data with Ansible Vault
- Use descriptive variable names with `vault_` prefix
- Keep vault passwords secure and backed up
- Never commit vault passwords

### 3. Access Control

- Limit access to vault files
- Use appropriate file permissions (600 for vault files)
- Regularly audit who has access to secrets

### 4. Emergency Procedures

If secrets are accidentally committed:

```bash
# Remove from git history
git filter-branch --force --index-filter \
  'git rm --cached --ignore-unmatch secrets/vault.yml' \
  --prune-empty --tag-name-filter cat -- --all

# Force push to remove from remote
git push origin --force --all
```

## Variable Naming Convention

- **Vault variables**: Prefix with `vault_` (e.g., `vault_vps_server_ip`)
- **Configuration variables**: Use descriptive names (e.g., `traefik_dashboard_enabled`)
- **Environment variables**: Use uppercase with underscores (e.g., `TRAEFIK_ENVIRONMENT`)

## Audit Checklist

Regularly review:

- [ ] No hardcoded secrets in inventory files
- [ ] All sensitive data properly vaulted
- [ ] Vault files not committed to git
- [ ] Appropriate file permissions set
- [ ] Access to secrets limited to necessary personnel
- [ ] Vault passwords securely stored and backed up
```

