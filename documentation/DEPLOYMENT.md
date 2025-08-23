# Deployment Guide

## Overview

This guide covers deploying Traefik to different environments using the automated scripts and manual methods.

## Prerequisites

### 1. Environment Setup

```bash
# Complete environment setup first
./scripts/setup-env.sh
nano .env
```

### 2. SSH Access

```bash
# Test SSH connection
ssh -i ~/.ssh/ovh-eduardo docker_deployment@your-vps-ip
```

### 3. Docker on VPS

```bash
# Verify Docker is running
docker info
```

## Automated Deployment

### Quick Deployment

```bash
# Deploy to current environment
./scripts/deploy.sh
```

The script will:

1. PASS: Load environment variables
2. PASS: Validate configuration
3. PASS: Show deployment summary
4. PASS: Confirm deployment
5. PASS: Run Ansible playbook

### Environment Switching

```bash
# Switch to staging
sed -i 's/TRAEFIK_ENVIRONMENT="development"/TRAEFIK_ENVIRONMENT="staging"/' .env

# Switch to production
sed -i 's/TRAEFIK_ENVIRONMENT="development"/TRAEFIK_ENVIRONMENT="production"/' .env

# Deploy to new environment
./scripts/deploy.sh
```

## Manual Deployment

### 1. Load Environment

```bash
# Source environment variables
source .env

# Verify variables
echo "Environment: $TRAEFIK_ENVIRONMENT"
echo "VPS: $VPS_SERVER_IP"
echo "User: $DEPLOYMENT_USER"
```

### 2. Run Ansible

```bash
# Deploy Traefik
ansible-playbook -i src/inventory src/playbooks/deploy_traefik.yml

# With verbose output
ansible-playbook -i src/inventory src/playbooks/deploy_traefik.yml -vvv

# Dry run (check mode)
ansible-playbook -i src/inventory src/playbooks/deploy_traefik.yml --check
```

## Environment-Specific Deployments

### Development

```bash
# Set environment
export TRAEFIK_ENVIRONMENT="development"

# Deploy
ansible-playbook -i src/inventory src/playbooks/deploy_traefik.yml
```

**Features:**

- Dashboard enabled on port 8080
- Monitoring disabled
- Backup disabled
- Rate limiting disabled

### Staging

```bash
# Set environment
export TRAEFIK_ENVIRONMENT="staging"

# Deploy
ansible-playbook -i src/inventory src/playbooks/deploy_traefik.yml
```

**Features:**

- Dashboard enabled on port 8080
- Monitoring enabled
- Backup enabled
- Rate limiting enabled

### Production

```bash
# Set environment
export TRAEFIK_ENVIRONMENT="production"

# Deploy
ansible-playbook -i src/inventory src/playbooks/deploy_traefik.yml
```

**Features:**

- Dashboard disabled (security)
- Monitoring enabled
- Backup enabled
- Rate limiting enabled
- Standard HTTP/HTTPS ports (80/443)

## Verification

### 1. Check Container Status

```bash
# List running containers
docker ps | grep traefik

# Check container logs
docker logs traefik-development
docker logs traefik-staging
docker logs traefik-production
```

### 2. Test Dashboard Access

```bash
# Development/Staging
curl http://your-vps-ip:8080

# Production (should fail - dashboard disabled)
curl http://your-vps-ip:8080
```

### 3. Check Network Integration

```bash
# List networks
docker network ls | grep traefik

# Check network details
docker network inspect prod-web-network
```

### 4. Verify Configuration

```bash
# Check Traefik config
docker exec traefik-development cat /etc/traefik/traefik.yml

# Check dynamic config
docker exec traefik-development cat /etc/traefik/dynamic/dynamic.yml
```

## Troubleshooting

### Common Issues

#### Deployment Fails

```bash
# Check Ansible output
ansible-playbook -i src/inventory src/playbooks/deploy_traefik.yml -vvv

# Verify environment variables
env | grep -E "(TRAEFIK|VPS|DEPLOYMENT)"

# Check SSH connection
ssh -i $DEPLOYMENT_SSH_KEY $DEPLOYMENT_USER@$VPS_SERVER_IP
```

#### Container Won't Start

```bash
# Check container logs
docker logs traefik-development

# Check container status
docker inspect traefik-development

# Verify configuration files
docker exec traefik-development ls -la /etc/traefik/
```

#### Network Issues

```bash
# Check network exists
docker network ls | grep prod-web-network

# Inspect network
docker network inspect prod-web-network

# Check container network
docker inspect traefik-development | grep -A 10 "NetworkSettings"
```

### Debug Commands

```bash
# Enable debug mode
export ANSIBLE_VERBOSITY=4

# Run with maximum verbosity
ansible-playbook -i src/inventory src/playbooks/deploy_traefik.yml -vvvv

# Check inventory
ansible-inventory --list -i src/inventory

# Test connection
ansible -i src/inventory all -m ping
```

## Rollback

### Quick Rollback

```bash
# Stop current container
docker stop traefik-production

# Start previous version
docker start traefik-production-backup

# Or remove and redeploy
docker rm traefik-production
./scripts/deploy.sh
```

### Configuration Rollback

```bash
# Restore from backup
sudo cp /opt/traefik/backup/traefik.yml.backup /opt/traefik/config/traefik.yml

# Restart container
docker restart traefik-production
```

## Maintenance

### Regular Tasks

1. **Monitor logs** for errors
2. **Check resource usage** (CPU, memory, disk)
3. **Update Traefik version** when needed
4. **Rotate admin passwords** regularly
5. **Backup configuration** before changes

### Updates

```bash
# Update Traefik version
# Edit src/inventory/group_vars/all/main.yml
# Change traefik_version: "3.0.0" to new version

# Redeploy
./scripts/deploy.sh
```

### Monitoring

```bash
# Check container health
docker ps | grep traefik

# Monitor logs
docker logs -f traefik-production

# Check metrics (if enabled)
curl http://your-vps-ip:8080/metrics
```

## Security

### Production Checklist

- PASS: Dashboard disabled
- PASS: Strong admin password
- PASS: Monitoring enabled
- PASS: Backup enabled
- PASS: Rate limiting enabled
- PASS: Security headers enabled
- PASS: TLS configured (if using HTTPS)

### Access Control

```bash
# Limit SSH access
# Edit /etc/ssh/sshd_config on VPS
# Restrict to specific IPs if possible

# Use key-based authentication only
# Disable password authentication
```

### Firewall

```bash
# Verify firewall rules
sudo ufw status

# Only necessary ports open
# 22 (SSH), 80 (HTTP), 443 (HTTPS)
# 8080 (dashboard - development/staging only)
```

## Support

### Getting Help

1. **Check logs** for error messages
2. **Verify configuration** in .env file
3. **Test SSH connection** manually
4. **Review this documentation**
5. **Check Ansible output** for specific errors

### Useful Resources

- [Traefik Documentation](https://doc.traefik.io/traefik/)
- [Ansible Documentation](https://docs.ansible.com/)
- [Docker Documentation](https://docs.docker.com/)
