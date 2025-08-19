# SSL/TLS Configuration Strategy

## Overview

This document defines the SSL/TLS configuration strategy using Let's Encrypt for automatic certificate management.

## SSL/TLS Architecture

### **Certificate Management**
- **Provider**: Let's Encrypt
- **Challenge Method**: HTTP-01 challenge
- **Storage**: Docker volumes for persistence
- **Renewal**: Automatic (every 60 days)

### **Domain Strategy**
- **Primary Domains**: Each application gets its own domain
- **Subdomains**: Applications can have multiple subdomains
- **Wildcard Support**: Not required (individual certificates per domain)

## Let's Encrypt Configuration

### **Traefik Let's Encrypt Setup**

```yaml
# traefik.yml configuration
certificatesResolvers:
  letsencrypt:
    acme:
      email: your-email@domain.com
      storage: /certs/acme.json
      httpChallenge:
        entryPoint: web
      # Optional: DNS challenge for wildcard certificates
      # dnsChallenge:
      #   provider: cloudflare
      #   resolvers:
      #     - "1.1.1.1:53"
      #     - "8.8.8.8:53"
```

### **Docker Compose Configuration**

```yaml
version: '3.8'

services:
  traefik:
    image: traefik:v2.10
    container_name: traefik
    restart: unless-stopped
    ports:
      - "80:80"    # HTTP challenge
      - "443:443"  # HTTPS
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock:ro
      - traefik-config:/etc/traefik
      - traefik-certs:/certs  # Certificate storage
    networks:
      - traefik-public
    command:
      - "--api.dashboard=true"
      - "--api.insecure=false"
      - "--providers.docker=true"
      - "--providers.docker.exposedbydefault=false"
      - "--entrypoints.web.address=:80"
      - "--entrypoints.websecure.address=:443"
      # Let's Encrypt configuration
      - "--certificatesresolvers.letsencrypt.acme.httpchallenge=true"
      - "--certificatesresolvers.letsencrypt.acme.httpchallenge.entrypoint=web"
      - "--certificatesresolvers.letsencrypt.acme.email=your-email@domain.com"
      - "--certificatesresolvers.letsencrypt.acme.storage=/certs/acme.json"
      - "--log.level=INFO"

volumes:
  traefik-certs:
    driver: local
```

## Domain Configuration Examples

### **1. Single Domain Application**

```yaml
# Application with single domain
services:
  myapp:
    image: myapp:latest
    networks:
      - traefik-public
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.myapp.rule=Host(`myapp.yourdomain.com`)"
      - "traefik.http.routers.myapp.entrypoints=websecure"
      - "traefik.http.routers.myapp.tls=true"
      - "traefik.http.routers.myapp.tls.certresolver=letsencrypt"
      - "traefik.http.services.myapp.loadbalancer.server.port=8080"
```

### **2. Multiple Subdomains Application**

```yaml
# Application with multiple subdomains
services:
  myapp:
    image: myapp:latest
    networks:
      - traefik-public
    labels:
      # Main application
      - "traefik.enable=true"
      - "traefik.http.routers.myapp.rule=Host(`myapp.yourdomain.com`)"
      - "traefik.http.routers.myapp.entrypoints=websecure"
      - "traefik.http.routers.myapp.tls=true"
      - "traefik.http.routers.myapp.tls.certresolver=letsencrypt"
      - "traefik.http.services.myapp.loadbalancer.server.port=8080"
      
      # API subdomain
      - "traefik.http.routers.myapp-api.rule=Host(`api.myapp.yourdomain.com`)"
      - "traefik.http.routers.myapp-api.entrypoints=websecure"
      - "traefik.http.routers.myapp-api.tls=true"
      - "traefik.http.routers.myapp-api.tls.certresolver=letsencrypt"
      - "traefik.http.services.myapp-api.loadbalancer.server.port=8081"
      
      # Admin subdomain
      - "traefik.http.routers.myapp-admin.rule=Host(`admin.myapp.yourdomain.com`)"
      - "traefik.http.routers.myapp-admin.entrypoints=websecure"
      - "traefik.http.routers.myapp-admin.tls=true"
      - "traefik.http.routers.myapp-admin.tls.certresolver=letsencrypt"
      - "traefik.http.services.myapp-admin.loadbalancer.server.port=8082"
```

### **3. Multiple Applications with Subdomains**

```yaml
# Multiple applications with subdomains
services:
  app1:
    image: app1:latest
    networks:
      - traefik-public
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.app1.rule=Host(`app1.yourdomain.com`)"
      - "traefik.http.routers.app1.entrypoints=websecure"
      - "traefik.http.routers.app1.tls=true"
      - "traefik.http.routers.app1.tls.certresolver=letsencrypt"
      - "traefik.http.services.app1.loadbalancer.server.port=8080"
      
      # App1 API
      - "traefik.http.routers.app1-api.rule=Host(`api.app1.yourdomain.com`)"
      - "traefik.http.routers.app1-api.entrypoints=websecure"
      - "traefik.http.routers.app1-api.tls=true"
      - "traefik.http.routers.app1-api.tls.certresolver=letsencrypt"
      - "traefik.http.services.app1-api.loadbalancer.server.port=8081"

  app2:
    image: app2:latest
    networks:
      - traefik-public
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.app2.rule=Host(`app2.yourdomain.com`)"
      - "traefik.http.routers.app2.entrypoints=websecure"
      - "traefik.http.routers.app2.tls=true"
      - "traefik.http.routers.app2.tls.certresolver=letsencrypt"
      - "traefik.http.services.app2.loadbalancer.server.port=8080"
      
      # App2 Dashboard
      - "traefik.http.routers.app2-dashboard.rule=Host(`dashboard.app2.yourdomain.com`)"
      - "traefik.http.routers.app2-dashboard.entrypoints=websecure"
      - "traefik.http.routers.app2-dashboard.tls=true"
      - "traefik.http.routers.app2-dashboard.tls.certresolver=letsencrypt"
      - "traefik.http.services.app2-dashboard.loadbalancer.server.port=8082"
```

## Certificate Management

### **Automatic Renewal**
- **Frequency**: Every 60 days (Let's Encrypt standard)
- **Method**: HTTP-01 challenge
- **Storage**: Persistent Docker volume
- **Backup**: Certificate storage volume

### **Certificate Storage**
```bash
# Certificate storage location
/var/lib/docker/volumes/traefik_certs/_data/acme.json
```

### **Certificate Monitoring**
```yaml
# Health check for certificate renewal
- name: Check certificate renewal
  ansible.builtin.command: docker exec traefik traefik healthcheck
  register: traefik_health
  failed_when: traefik_health.rc != 0
```

## Security Considerations

### **1. Certificate Security**
- **Storage**: Encrypted volume for certificate storage
- **Access**: Restricted access to certificate files
- **Backup**: Regular backup of certificate storage

### **2. HTTP to HTTPS Redirect**
```yaml
# Automatic HTTP to HTTPS redirect
entryPoints:
  web:
    address: ":80"
    http:
      redirections:
        entrypoint:
          to: websecure
          scheme: https
          permanent: true
```

### **3. Security Headers**
```yaml
# Security headers middleware
http:
  middlewares:
    security-headers:
      headers:
        frameDeny: true
        sslRedirect: true
        browserXssFilter: true
        contentTypeNosniff: true
        forceSTSHeader: true
        stsIncludeSubdomains: true
        stsPreload: true
        stsSeconds: 31536000
```

## Ansible Implementation

### **1. Let's Encrypt Variables**
```yaml
# defaults/main.yml
traefik_letsencrypt_enabled: true
traefik_letsencrypt_email: "your-email@domain.com"
traefik_letsencrypt_storage: "/certs/acme.json"
traefik_letsencrypt_challenge: "http"
traefik_ssl_redirect: true
traefik_hsts_enabled: true
```

### **2. Certificate Volume Setup**
```yaml
# tasks/certificates.yml
- name: Create certificate storage directory
  ansible.builtin.file:
    path: "{{ traefik_cert_path }}"
    state: directory
    mode: "0755"
    owner: "{{ traefik_user }}"
    group: "{{ traefik_group }}"

- name: Set certificate directory permissions
  ansible.builtin.file:
    path: "{{ traefik_cert_path }}"
    mode: "0600"
    recurse: true
```

### **3. Certificate Monitoring**
```yaml
# tasks/monitoring.yml
- name: Check certificate expiration
  ansible.builtin.command: docker exec traefik traefik healthcheck
  register: cert_check
  failed_when: cert_check.rc != 0
  changed_when: false
```

## Troubleshooting

### **1. Certificate Renewal Issues**
```bash
# Check certificate status
docker exec traefik traefik healthcheck

# View certificate information
docker exec traefik cat /certs/acme.json

# Force certificate renewal
docker exec traefik traefik --configfile=/etc/traefik/traefik.yml
```

### **2. Common Issues**
- **Rate Limiting**: Let's Encrypt has rate limits (50 certificates per week per domain)
- **DNS Issues**: Ensure DNS is properly configured for all domains
- **Port 80**: Must be accessible for HTTP challenge
- **Storage Permissions**: Certificate storage must be writable

## Best Practices

### **1. Domain Management**
- Use descriptive domain names
- Plan subdomain structure in advance
- Document all domain assignments

### **2. Certificate Monitoring**
- Monitor certificate expiration
- Set up alerts for renewal failures
- Regular backup of certificate storage

### **3. Security**
- Enable HSTS headers
- Use secure cipher suites
- Regular security updates

## Next Steps

1. **Configure Let's Encrypt email**
2. **Set up certificate storage**
3. **Test certificate generation**
4. **Implement monitoring**
5. **Create backup strategy**
