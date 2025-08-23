# Ansible Vault Usage

## Rule

This project uses Ansible Vault to encrypt sensitive configuration data. All playbooks that access inventory variables require vault password authentication, and vault-encrypted files must never be committed in plaintext.

## Details

### Vault File Location

- **Primary vault file**: `src/inventory/group_vars/all/vault.yml`
- Contains encrypted sensitive data like:
  - Email credentials (`configure_reporting_gmail_password`)
  - SSH keys and deployment credentials
  - API tokens and security keys
  - SMTP configuration details

### Running Playbooks with Vault

When running any Ansible playbook that accesses inventory variables, you must provide the vault password:

```bash
# Standard approach - prompt for password
ansible-playbook playbooks/full.yml --ask-vault-pass

# Using password file (if configured)
ansible-playbook playbooks/full.yml --vault-password-file ~/.vault_pass

# For diagnostic playbooks
ansible-playbook playbooks/diagnose_fail2ban.yml --ask-vault-pass
```

### Vault Password Management

- **Never commit** the vault password to version control
- **Never commit** unencrypted vault files
- Store vault password securely (password manager, secure file, etc.)
- Use consistent vault password across all environments for simplicity

### Creating New Vault Entries

```bash
# Edit existing vault file
ansible-vault edit src/inventory/group_vars/all/vault.yml

# Create new vault file
ansible-vault create src/inventory/group_vars/production/secrets.yml

# Encrypt existing file
ansible-vault encrypt src/inventory/group_vars/staging/credentials.yml
```

### Vault File Structure

The vault file typically contains:

```yaml
---
# Email Configuration (encrypted)
configure_reporting_gmail_user: "your-email@gmail.com"
configure_reporting_gmail_password: "your-app-password"
configure_security_updates_email: "alerts@yourdomain.com"

# SSH and Deployment (encrypted)
initial_deployment_ssh_key: "~/.ssh/your-deployment-key"
deployment_user_password: "encrypted-password-hash"

# API Keys and Tokens (encrypted)
monitoring_webhook_token: "your-webhook-token"
security_api_key: "your-security-api-key"
```

### Troubleshooting Vault Issues

#### **Error: "Attempting to decrypt but no vault secrets found"**

- Solution: Add `--ask-vault-pass` flag to your ansible-playbook command
- This happens when playbooks try to access vault variables without authentication

#### **Error: "Decryption failed"**

- Solution: Verify you're using the correct vault password
- Check that vault file isn't corrupted

#### **Error: "Vault format error"**

- Solution: Re-encrypt the file with `ansible-vault encrypt`
- Ensure file wasn't accidentally saved in plaintext

### Security Best Practices

1. **Regular Password Rotation**: Change vault password periodically
2. **Environment Separation**: Use different vault passwords for prod/staging if needed
3. **Access Control**: Limit who has access to vault passwords
4. **Backup Strategy**: Securely backup vault files and passwords
5. **Audit Trail**: Log vault access and modifications

### Development Workflow

When creating new playbooks or modifying existing ones:

1. **Test without vault first**: Create minimal playbook without vault variables
2. **Add vault access**: Include `--ask-vault-pass` when testing with real config
3. **Document vault dependencies**: Note in playbook comments if vault access required
4. **Provide fallbacks**: Use `| default()` filters for optional vault variables

### Example Playbook Structure

```yaml
---
- name: Example Playbook with Vault Usage
  hosts: all
  become: true
  vars:
    # Use vault variables with fallbacks
    email_user: "{{ configure_reporting_gmail_user | default('') }}"
    email_pass: "{{ configure_reporting_gmail_password | default('') }}"
  tasks:
    - name: Task that needs vault data
      # ... task definition
      when: email_user != '' and email_pass != ''
```

### Integration with CI/CD

For automated deployments:

- Store vault password as encrypted secret in CI system
- Use `--vault-password-file` with secure file path
- Never log vault passwords in CI output
- Rotate vault passwords when team members change

This ensures secure, consistent handling of sensitive data across all project deployments.
