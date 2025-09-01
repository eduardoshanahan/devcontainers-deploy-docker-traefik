# Fully Automated Deployment Strategy

## Overview

This document defines the strategy for creating a completely automated, file-based deployment system where every detail is committed to code and zero manual intervention is required.

## Core Principles

### **1. Zero Manual Intervention**

- No command-line parameters required
- No manual configuration steps
- No environment-specific setup
- Everything committed to version control

### **2. Infrastructure as Code**

- All configuration in files
- Version-controlled deployment
- Reproducible deployments
- Disaster recovery ready

### **3. Single Command Deployment**

- One script to deploy everything
- One script to recreate entire server
- One script to update configuration
- One script to rollback if needed

## File Structure Strategy

### **Complete Project Structure**

```text
project-root/
├── ansible/
│   ├── inventory/
│   │   └── hosts.yml              # Server inventory
│   ├── group_vars/
│   │   └── all.yml                # Global variables
│   ├── host_vars/
│   │   └── server.yml             # Server-specific variables
│   ├── roles/
│   │   ├── traefik/
│   │   ├── applications/
│   │   └── monitoring/
│   ├── playbooks/
│   │   ├── deploy.yml             # Main deployment playbook
│   │   ├── update.yml             # Update playbook
│   │   └── rollback.yml           # Rollback playbook
│   └── ansible.cfg                # Ansible configuration
├── config/
│   ├── domains.yml                # Domain configuration
│   ├── applications.yml           # Application definitions
│   ├── networks.yml               # Network configuration
│   ├── ssl.yml                    # SSL/TLS configuration
│   └── monitoring.yml             # Monitoring configuration
├── scripts/
│   ├── deploy.sh                  # Main deployment script
│   ├── recreate-server.sh         # Server recreation script
│   ├── update.sh                  # Update script
│   └── rollback.sh                # Rollback script
├── templates/
│   ├── docker-compose/
│   │   ├── traefik.yml.j2         # Traefik compose template
│   │   └── applications.yml.j2    # Application compose template
│   └── config/
│       ├── traefik.yml.j2         # Traefik config template
│       └── nginx.yml.j2           # Nginx config template
└── README.md                      # Deployment instructions
```

## Configuration Files Strategy

### **1. Global Configuration (config/domains.yml)**

```yaml
# config/domains.yml
domains:
  main_domain: "eduardoshanahan.com"
  vps_ip: "YOUR_VPS_IP_ADDRESS"
  cloudflare:
    enabled: true
    zone_id: "YOUR_CLOUDFLARE_ZONE_ID"
    api_token: "YOUR_CLOUDFLARE_API_TOKEN"
    ssl_mode: "full_strict"
  
  subdomains:
    www:
      enabled: true
      application: "main-site"
      ssl: true
    blog:
      enabled: true
      application: "wordpress"
      ssl: true
    articles:
      enabled: true
      application: "hugo"
      ssl: true
    api:
      enabled: true
      application: "api-service"
      ssl: true
    admin:
      enabled: true
      application: "admin-panel"
      ssl: true
    traefik:
      enabled: true
      application: "traefik-dashboard"
      ssl: true
      cloudflare_proxy: false  # Direct connection for dashboard
```

### **2. Application Configuration (config/applications.yml)**

```yaml
# config/applications.yml
applications:
  main-site:
    enabled: true
    image: "nginx:alpine"
    port: 80
    volumes:
      - "./sites/main-site:/usr/share/nginx/html"
    environment: {}
    networks:
      - "traefik-public"
      - "main-site-network"
    health_check:
      path: "/"
      interval: "30s"
      timeout: "10s"
      retries: 3

  wordpress:
    enabled: true
    image: "wordpress:latest"
    port: 80
    volumes:
      - "wordpress-data:/var/www/html"
    environment:
      WORDPRESS_DB_HOST: "wordpress-db"
      WORDPRESS_DB_NAME: "wordpress"
      WORDPRESS_DB_USER: "wordpress"
      WORDPRESS_DB_PASSWORD: "{{ env.WORDPRESS_DB_PASSWORD }}"  # From environment
    networks:
      - "traefik-public"
      - "wordpress-network"
    depends_on:
      - "wordpress-db"
    health_check:
      path: "/"
      interval: "30s"
      timeout: "10s"
      retries: 3

  wordpress-db:
    enabled: true
    image: "mysql:5.7"
    port: 3306
    volumes:
      - "wordpress-db-data:/var/lib/mysql"
    environment:
      MYSQL_ROOT_PASSWORD: "{{ env.MYSQL_ROOT_PASSWORD }}"  # From environment
      MYSQL_DATABASE: "wordpress"
      MYSQL_USER: "wordpress"
      MYSQL_PASSWORD: "{{ env.WORDPRESS_DB_PASSWORD }}"  # From environment
    networks:
      - "wordpress-network"
    health_check:
      command: ["mysqladmin", "ping", "-h", "localhost"]
      interval: "30s"
      timeout: "10s"
      retries: 3

  api-service:
    enabled: true
    image: "api-service:latest"
    port: 3000
    volumes:
      - "./api:/app"
    environment:
      DATABASE_URL: "postgresql://user:{{ env.API_DB_PASSWORD }}@api-db:5432/api"  # From environment
      NODE_ENV: "production"
      API_SECRET_KEY: "{{ env.API_SECRET_KEY }}"  # From environment
    networks:
      - "traefik-public"
      - "api-network"
    depends_on:
      - "api-db"
    health_check:
      path: "/health"
      interval: "30s"
      timeout: "10s"
      retries: 3
```

### **3. Network Configuration (config/networks.yml)**

```yaml
# config/networks.yml
networks:
  traefik-public:
    driver: "bridge"
    external: true
    subnet: "172.20.0.0/16"
    
  main-site-network:
    driver: "bridge"
    subnet: "172.21.0.0/16"
    
  wordpress-network:
    driver: "bridge"
    subnet: "172.22.0.0/16"
    
  api-network:
    driver: "bridge"
    subnet: "172.23.0.0/16"
    
  admin-network:
    driver: "bridge"
    subnet: "172.24.0.0/16"
```

### **4. SSL/TLS Configuration (config/ssl.yml)**

```yaml
# config/ssl.yml
ssl:
  provider: "letsencrypt"
  email: "{{ env.LETSENCRYPT_EMAIL }}"  # From environment
  challenge: "http"
  storage: "/certs/acme.json"
  renewal: "automatic"
  redirect_http_to_https: true
  hsts_enabled: true
  hsts_max_age: 31536000
  security_headers:
    frame_deny: true
    ssl_redirect: true
    browser_xss_filter: true
    content_type_nosniff: true
    force_sts_header: true
    sts_include_subdomains: true
    sts_preload: true
```

### **5. Monitoring Configuration (config/monitoring.yml)**

```yaml
# config/monitoring.yml
monitoring:
  enabled: true
  traefik_dashboard:
    enabled: true
    domain: "traefik.eduardoshanahan.com"
    auth:
      username: "admin"
      password: "{{ env.TRAEFIK_DASHBOARD_PASSWORD }}"  # From environment
  
  health_checks:
    enabled: true
    interval: "30s"
    timeout: "10s"
    retries: 3
    
  logging:
    level: "INFO"
    format: "json"
    file: "/var/log/traefik/traefik.log"
    
  metrics:
    enabled: true
    prometheus: true
    prometheus_endpoint: "/metrics"
```

### **6. Traefik Configuration (config/traefik.yml)**

```yaml
# config/traefik.yml
traefik:
  version: "v2.10"
  dashboard:
    enabled: true
    insecure: false
    auth: true
    
  api:
    enabled: true
    insecure: false
    dashboard: true
    
  providers:
    docker:
      enabled: true
      exposed_by_default: false
      network: "traefik-public"
      
  entrypoints:
    web:
      address: ":80"
      http:
        redirections:
          entrypoint:
            to: websecure
            scheme: https
            permanent: true
    websecure:
      address: ":443"
      forwardedHeaders:
        insecure: false
        trustedIPs:
          - "173.245.48.0/20"    # Cloudflare IPv4
          - "2400:cb00::/32"     # Cloudflare IPv6
```

## Environment Variables (Sensitive Data)

### **1. Environment Template (.env.example)**

```bash
# .env.example
# Copy this file to .env and fill in your values

# VPS Configuration
TRAEFIK_VPS_IP=YOUR_VPS_IP_ADDRESS

# Cloudflare Configuration
CLOUDFLARE_ZONE_ID=YOUR_CLOUDFLARE_ZONE_ID
CLOUDFLARE_API_TOKEN=YOUR_CLOUDFLARE_API_TOKEN

# Let's Encrypt Configuration
LETSENCRYPT_EMAIL=your-email@eduardoshanahan.com

# Traefik Dashboard
TRAEFIK_DASHBOARD_PASSWORD=your-secure-dashboard-password

# Database Passwords
MYSQL_ROOT_PASSWORD=your-mysql-root-password
WORDPRESS_DB_PASSWORD=your-wordpress-db-password
API_DB_PASSWORD=your-api-db-password

# Application Secrets
API_SECRET_KEY=your-api-secret-key
ADMIN_PANEL_SECRET=your-admin-panel-secret

# Additional Application Secrets
# Add any other sensitive configuration here
```

### **2. Actual Environment File (.env)**

```bash
# .env (not committed to version control)
TRAEFIK_VPS_IP=192.168.1.100
CLOUDFLARE_ZONE_ID=abc123def456
CLOUDFLARE_API_TOKEN=your-actual-cloudflare-token
LETSENCRYPT_EMAIL=admin@eduardoshanahan.com
TRAEFIK_DASHBOARD_PASSWORD=your-actual-dashboard-password
MYSQL_ROOT_PASSWORD=your-actual-mysql-password
WORDPRESS_DB_PASSWORD=your-actual-wordpress-password
API_DB_PASSWORD=your-actual-api-password
API_SECRET_KEY=your-actual-api-secret
ADMIN_PANEL_SECRET=your-actual-admin-secret
```

## Ansible Integration

### **1. Global Variables (group_vars/all.yml)**

```yaml
# group_vars/all.yml
# Load environment variables
traefik_vps_ip: "{{ lookup('env', 'TRAEFIK_VPS_IP') }}"
cloudflare_zone_id: "{{ lookup('env', 'CLOUDFLARE_ZONE_ID') }}"
cloudflare_api_token: "{{ lookup('env', 'CLOUDFLARE_API_TOKEN') }}"
letsencrypt_email: "{{ lookup('env', 'LETSENCRYPT_EMAIL') }}"
traefik_dashboard_password: "{{ lookup('env', 'TRAEFIK_DASHBOARD_PASSWORD') }}"
mysql_root_password: "{{ lookup('env', 'MYSQL_ROOT_PASSWORD') }}"
wordpress_db_password: "{{ lookup('env', 'WORDPRESS_DB_PASSWORD') }}"
api_db_password: "{{ lookup('env', 'API_DB_PASSWORD') }}"
api_secret_key: "{{ lookup('env', 'API_SECRET_KEY') }}"
admin_panel_secret: "{{ lookup('env', 'ADMIN_PANEL_SECRET') }}"

# Load configuration files
domains_config: "{{ lookup('file', 'config/domains.yml') | from_yaml }}"
applications_config: "{{ lookup('file', 'config/applications.yml') | from_yaml }}"
networks_config: "{{ lookup('file', 'config/networks.yml') | from_yaml }}"
ssl_config: "{{ lookup('file', 'config/ssl.yml') | from_yaml }}"
monitoring_config: "{{ lookup('file', 'config/monitoring.yml') | from_yaml }}"
traefik_config: "{{ lookup('file', 'config/traefik.yml') | from_yaml }}"

# Extract variables from config
traefik_main_domain: "{{ domains_config.domains.main_domain }}"
traefik_cloudflare_enabled: "{{ domains_config.domains.cloudflare.enabled }}"
traefik_applications: "{{ applications_config.applications }}"
traefik_networks: "{{ networks_config.networks }}"
traefik_ssl_config: "{{ ssl_config.ssl }}"
traefik_monitoring_config: "{{ monitoring_config.monitoring }}"
```

## Validation Strategy

### **1. Configuration Validation Script (scripts/validate-config.py)**

```python
#!/usr/bin/env python3
# scripts/validate-config.py

import yaml
import os
import sys
from pathlib import Path

def validate_yaml_file(file_path):
    """Validate YAML file syntax"""
    try:
        with open(file_path, 'r') as f:
            yaml.safe_load(f)
        print(f"PASS {file_path} is valid")
        return True
    except Exception as e:
        print(f"FAIL {file_path} is invalid: {e}")
        return False

def validate_environment_variables():
    """Validate required environment variables"""
    required_vars = [
        'TRAEFIK_VPS_IP',
        'CLOUDFLARE_ZONE_ID',
        'CLOUDFLARE_API_TOKEN',
        'LETSENCRYPT_EMAIL',
        'TRAEFIK_DASHBOARD_PASSWORD',
        'MYSQL_ROOT_PASSWORD',
        'WORDPRESS_DB_PASSWORD',
        'API_DB_PASSWORD',
        'API_SECRET_KEY',
        'ADMIN_PANEL_SECRET'
    ]
    
    missing_vars = []
    for var in required_vars:
        if not os.getenv(var):
            missing_vars.append(var)
    
    if missing_vars:
        print(f"FAIL Missing environment variables: {', '.join(missing_vars)}")
        return False
    else:
        print("PASS All required environment variables are set")
        return True

def main():
    """Main validation function"""
    config_files = [
        'config/domains.yml',
        'config/applications.yml',
        'config/networks.yml',
        'config/ssl.yml',
        'config/monitoring.yml',
        'config/traefik.yml'
    ]
    
    print("DOCUMENT Validating configuration files...")
    config_valid = all(validate_yaml_file(f) for f in config_files)
    
    print("\nDOCUMENT Validating environment variables...")
    env_valid = validate_environment_variables()
    
    if config_valid and env_valid:
        print("\nPASS All validation passed!")
        sys.exit(0)
    else:
        print("\nFAIL Validation failed!")
        sys.exit(1)

if __name__ == "__main__":
    main()
```

## Deployment Scripts

### **1. Environment Setup Script (scripts/setup-env.sh)**

```bash
#!/bin/bash
# scripts/setup-env.sh

set -e

# Check if .env file exists
if [ ! -f .env ]; then
    echo "FAIL .env file not found"
    echo "Please copy .env.example to .env and fill in your values"
    exit 1
fi

# Load environment variables
export $(cat .env | grep -v '^#' | xargs)

# Validate required variables
required_vars=(
    "TRAEFIK_VPS_IP"
    "CLOUDFLARE_ZONE_ID"
    "CLOUDFLARE_API_TOKEN"
    "LETSENCRYPT_EMAIL"
    "TRAEFIK_DASHBOARD_PASSWORD"
    "MYSQL_ROOT_PASSWORD"
    "WORDPRESS_DB_PASSWORD"
    "API_DB_PASSWORD"
    "API_SECRET_KEY"
    "ADMIN_PANEL_SECRET"
)

for var in "${required_vars[@]}"; do
    if [ -z "${!var}" ]; then
        echo "FAIL Required environment variable $var is not set"
        exit 1
    fi
done

echo "PASS Environment variables loaded successfully"
```

### **2. Enhanced Deployment Script (scripts/deploy.sh)**

```bash
#!/bin/bash
# scripts/deploy.sh

set -e

# Load environment variables
source scripts/setup-env.sh

echo "DEPLOY Starting fully automated deployment..."

# Validate configuration
echo "DOCUMENT Validating configuration..."
python3 scripts/validate-config.py

# Run Ansible deployment
echo "CONFIGURE Running Ansible deployment..."
ansible-playbook -i ansible/inventory/hosts.yml ansible/playbooks/deploy.yml

echo "PASS Deployment completed successfully!"
echo "DEPLOY Your applications should be available at:"
echo "   - Main site: https://www.{{ traefik_main_domain }}"
echo "   - Blog: https://blog.{{ traefik_main_domain }}"
echo "   - API: https://api.{{ traefik_main_domain }}"
echo "   - Traefik Dashboard: https://traefik.{{ traefik_main_domain }}"
```

## Benefits of This Approach

### **1. Security**

- Sensitive data in environment variables (no files)
- No secrets committed to version control
- Easy credential rotation
- Secure by design

### **2. Structure**

- Complex configuration in readable YAML files
- Hierarchical organization
- Self-documenting format
- Easy to understand and maintain

### **3. Version Control**

- Non-sensitive data tracked in git
- Clear change history
- Branch-based configuration
- Easy rollback capabilities

### **4. CI/CD Integration**

- Easy secret injection in pipelines
- Environment-specific configuration
- Automated deployment
- Secure credential management

### **5. Maintainability**

- Clear separation of concerns
- Consistent naming conventions
- Comprehensive validation
- Easy troubleshooting

## Next Steps

1. **Create the file structure**
2. **Implement configuration files**
3. **Set up environment variables**
4. **Create Ansible roles**
5. **Implement validation scripts**
6. **Test complete deployment**

This hybrid configuration structure provides the perfect balance of security, maintainability, and functionality for your fully automated deployment system!
