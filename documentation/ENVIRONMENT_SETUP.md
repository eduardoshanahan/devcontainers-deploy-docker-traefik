# Environment Setup Guide

## Overview

This project uses environment variables for configuration, stored in a `.env` file at the project root. This approach provides:

- **Security**: Sensitive data is not committed to git
- **Flexibility**: Easy switching between environments
- **Standard Practice**: Follows industry conventions
- **Maintainability**: Single file for all configuration

## Quick Setup

### **1. Initial Setup**

```bash
# Run the setup script
./scripts/setup-env.sh

# Edit the .env file with your values
nano .env
```

### **2. Required Variables**

| Variable | Description | Required | Example |
|----------|-------------|----------|---------|
| `VPS_SERVER_IP` | Your VPS IP address | PASS | `vps-153d27d0.vps.ovh.net` |
| `DEPLOYMENT_USER` | Username for deployment | PASS | `docker_deployment` |
| `DEPLOYMENT_SSH_KEY` | Path to your SSH key | PASS | `~/.ssh/ovh-eduardo` |
| `TRAEFIK_ENVIRONMENT` | Target environment | PASS | `development`, `staging`, or `production` |
| `TRAEFIK_ADMIN_PASSWORD` | Dashboard admin password | PASS | `your-secure-password` |

### **3. Environment-Specific Values**

The `.env` file automatically sets different values based on `TRAEFIK_ENVIRONMENT`:

#### **Development**

```bash
export TRAEFIK_ENVIRONMENT="development"
# Results in:
# - Dashboard: Enabled
# - Monitoring: Disabled
# - Backup: Disabled
# - Rate Limiting: Disabled
# - Ports: 8080 (non-conflicting)
```

#### **Staging**

```bash
export TRAEFIK_ENVIRONMENT="staging"
# Results in:
# - Dashboard: Enabled
# - Monitoring: Enabled
# - Backup: Enabled
# - Rate Limiting: Enabled
# - Ports: 8080 (non-conflicting)
```

#### **Production**

```bash
export TRAEFIK_ENVIRONMENT="production"
# Results in:
# - Dashboard: Disabled (security)
# - Monitoring: Enabled
# - Backup: Enabled
# - Rate Limiting: Enabled
# - Ports: 80/443 (standard HTTP/HTTPS)
```

## File Structure

```text
/workspace/
├── .env                    # Your configuration (NOT in git)
├── .env.example           # Template (in git)
├── scripts/
│   ├── setup-env.sh       # Environment setup script
│   └── deploy.sh          # Deployment wrapper
└── src/
    ├── inventory/          # Ansible inventory
    ├── playbooks/          # Ansible playbooks
    └── roles/              # Ansible roles
```

## Usage

### **Loading Environment**

```bash
# Source the .env file
source .env

# Verify variables are loaded
echo "Environment: $TRAEFIK_ENVIRONMENT"
echo "VPS: $VPS_SERVER_IP"
```

### **Switching Environments**

```bash
# Quick switch to staging
sed -i 's/TRAEFIK_ENVIRONMENT="development"/TRAEFIK_ENVIRONMENT="staging"/' .env

# Quick switch to production
sed -i 's/TRAEFIK_ENVIRONMENT="development"/TRAEFIK_ENVIRONMENT="production"/' .env

# Or edit manually
nano .env
```

### **Deployment**

```bash
# Automated deployment (recommended)
./scripts/deploy.sh

# Manual deployment
source .env
ansible-playbook -i src/inventory src/playbooks/deploy_traefik.yml
```

## Security

### **Best Practices**

1. **Never commit `.env`** to version control
2. **Use strong passwords** in production
3. **Rotate credentials** regularly
4. **Limit access** to deployment keys
5. **Use different passwords** for each environment

### **File Permissions**

```bash
# Secure .env file permissions
chmod 600 .env

# Ensure only you can read/write
ls -la .env
# Should show: -rw------- 1 youruser yourgroup .env
```

### **SSH Key Security**

```bash
# Secure SSH key permissions
chmod 600 ~/.ssh/ovh-eduardo
chmod 700 ~/.ssh

# Test SSH connection
ssh -i ~/.ssh/ovh-eduardo docker_deployment@your-vps-ip
```

## Troubleshooting

### **Common Issues**

#### **Environment Variables Not Loaded**

```bash
FAIL: Required environment variables are not set
```

**Solution:**

```bash
# Check if .env exists
ls -la .env

# Source the file
source .env

# Verify variables
echo $TRAEFIK_ENVIRONMENT
```

#### **SSH Connection Failed**

```bash
FAIL: SSH connection to VPS failed
```

**Solution:**

```bash
# Check SSH key permissions
ls -la ~/.ssh/ovh-eduardo

# Test SSH connection manually
ssh -i ~/.ssh/ovh-eduardo docker_deployment@your-vps-ip

# Verify VPS_SERVER_IP is correct
echo $VPS_SERVER_IP
```

#### **Permission Denied**

```bash
FAIL: Permission denied (publickey)
```

**Solution:**

```bash
# Check SSH key path in .env
echo $DEPLOYMENT_SSH_KEY

# Verify key exists
ls -la $DEPLOYMENT_SSH_KEY

# Check key permissions
chmod 600 $DEPLOYMENT_SSH_KEY
```

### **Debug Mode**

```bash
# Enable verbose output
source .env
ansible-playbook -i src/inventory src/playbooks/deploy_traefik.yml -vvv

# Check environment variables
env | grep TRAEFIK
env | grep VPS
env | grep DEPLOYMENT
```

## Advanced Configuration

### **Custom Environment Variables**

You can add custom variables to the `.env` file:

```bash
# Custom variables
export CUSTOM_TRAEFIK_OPTION="value"
export ADDITIONAL_CONFIG="setting"
```

Then reference them in your inventory:

```yaml
# src/inventory/group_vars/all/main.yml
custom_option: "{{ lookup('env', 'CUSTOM_TRAEFIK_OPTION') }}"
```

### **Multiple .env Files**

For complex setups, you can create multiple environment files:

```bash
# Development
cp .env.example .env.dev
nano .env.dev

# Staging
cp .env.example .env.staging
nano .env.staging

# Production
cp .env.example .env.prod
nano .env.prod
```

Then source the appropriate file:

```bash
# Load development
source .env.dev

# Load staging
source .env.staging

# Load production
source .env.prod
```

### **CI/CD Integration**

For automated deployments, set environment variables in your CI system:

```yaml
# .github/workflows/deploy.yml
env:
  VPS_SERVER_IP: ${{ secrets.VPS_SERVER_IP }}
  DEPLOYMENT_USER: ${{ secrets.DEPLOYMENT_USER }}
  DEPLOYMENT_SSH_KEY: ${{ secrets.DEPLOYMENT_SSH_KEY }}
  TRAEFIK_ADMIN_PASSWORD: ${{ secrets.TRAEFIK_ADMIN_PASSWORD }}
  TRAEFIK_ENVIRONMENT: ${{ github.ref_name }}
```

## Maintenance

### **Regular Tasks**

1. **Rotate passwords** every 90 days
2. **Update SSH keys** when team members change
3. **Review access** to deployment credentials
4. **Backup .env** file securely
5. **Test deployments** in development first

### **Updates**

```bash
# Update from template
cp .env.example .env.new
nano .env.new

# Compare with current
diff .env .env.new

# Apply updates
mv .env .env.backup
mv .env.new .env
```

### **Backup**

```bash
# Backup current configuration
cp .env .env.backup.$(date +%Y%m%d)

# Restore from backup
cp .env.backup.20231201 .env
```

## Support

### **Getting Help**

1. **Check this documentation** first
2. **Review error messages** carefully
3. **Verify environment variables** are set
4. **Test SSH connection** manually
5. **Check file permissions** and paths

### **Useful Commands**

```bash
# Check environment
env | grep -E "(TRAEFIK|VPS|DEPLOYMENT)"

# Test SSH
ssh -i $DEPLOYMENT_SSH_KEY $DEPLOYMENT_USER@$VPS_SERVER_IP

# Check Ansible
ansible --version
ansible-inventory --list -i src/inventory

# Validate playbook
ansible-playbook --check -i src/inventory src/playbooks/deploy_traefik.yml
```

## Automated Deployment

### **Quick Deployment**

```bash
# Deploy to current environment
./scripts/deploy.sh
```

The deployment script will:

1. PASS: Load environment variables
2. PASS: Validate configuration
3. PASS: Show deployment summary
4. PASS: Confirm deployment
5. PASS: Run Ansible playbook

### **Environment Switching**

```bash
# Switch to staging
sed -i 's/TRAEFIK_ENVIRONMENT="development"/TRAEFIK_ENVIRONMENT="staging"/' .env

# Switch to production
sed -i 's/TRAEFIK_ENVIRONMENT="development"/TRAEFIK_ENVIRONMENT="production"/' .env

# Deploy to new environment
./scripts/deploy.sh
```

## Production Checklist

### **Security Features**

- PASS: Dashboard disabled
- PASS: Strong admin password
- PASS: Monitoring enabled
- PASS: Backup enabled
- PASS: Rate limiting enabled
- PASS: Security headers enabled
- PASS: TLS configured (if using HTTPS)

## Conclusion

This environment setup guide provides everything needed to configure and manage your Traefik deployment across multiple environments.

### **Key Takeaways**

- Use `.env` files for secure configuration management
- Follow security best practices for production deployments
- Leverage automated scripts for consistent deployments
- Maintain separate configurations for each environment

### **Next Steps**

1. Complete your `.env` file setup
2. Test environment variable loading
3. Verify SSH connectivity to your VPS
4. Run your first deployment

### **Success Indicators**

- Environment variables load without errors
- SSH connection to VPS is successful
- Ansible can connect and run commands
- Deployment completes without issues

## References

- [Ansible Environment Variables](https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_variables.html#using-variables)
- [Docker Environment Variables](https://docs.docker.com/compose/environment-variables/)
- [12-Factor App Methodology](https://12factor.net/config)
- [Environment Variables Best Practices](https://www.envoyproxy.io/docs/envoy/latest/configuration/operations/security)
- [SSH Key Management](https://www.ssh.com/academy/ssh/key)
- [Traefik Documentation](https://doc.traefik.io/traefik/)
