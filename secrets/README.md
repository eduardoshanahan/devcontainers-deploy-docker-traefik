# Secrets Directory

This directory contains all sensitive configuration data for the Ansible infrastructure project.

## Files

- `vault.yml` - Main encrypted Ansible vault file (contains all sensitive data)
- `vault.example.yml` - Example configuration template (safe to commit)
- `vault.decrypted.yml` - Decrypted version for reference (do not commit)
- `.env` - Environment variables and non-sensitive configuration
- `.vault_pass` - Vault password file (do not commit)
- `.gitignore` - Git ignore rules for this directory

## Security

- All files in this directory are ignored by git
- Sensitive data is encrypted with Ansible Vault
- Clear separation between sensitive and non-sensitive data
- Vault passwords should be backed up securely

## Usage

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

## Setup

1. Copy the example file: `cp vault.example.yml vault.yml`
2. Edit `vault.yml` with your real values
3. Encrypt the file: `ansible-vault encrypt vault.yml`
4. Set up your vault password in `.vault_pass`
