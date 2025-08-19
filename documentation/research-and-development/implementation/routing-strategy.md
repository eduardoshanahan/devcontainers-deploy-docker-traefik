# Routing Strategy and URL Structure

## Overview

This document defines the routing strategy and URL structure for the Traefik reverse proxy implementation.

## URL Structure Strategy

### **Domain Pattern**

```
Main Domain: edu
```

### **URL Structure Examples**
- **Main Site**: `www.eduardoshanahan.com`
- **Blog**: `blog.eduardoshanahan.com`
- **Articles**: `articles.eduardoshanahan.com`
- **API**: `api.eduardoshanahan.com`
- **Admin**: `admin.eduardoshanahan.com`
- **Traefik Dashboard**: `traefik.eduardoshanahan.com`

## Routing Configuration

### **1. Main Domain Configuration**

```yaml
# Main domain application
services:
  main-site:
    image: main-site:latest
    networks:
      - traefik-public
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.main-site.rule=Host(`www.eduardoshanahan.com`)"
      - "traefik.http.routers.main-site.entrypoints=websecure"
      - "traefik.http.routers.main-site.tls=true"
      - "traefik.http.routers.main-site.tls.certresolver=letsencrypt"
      - "traefik.http.services.main-site.loadbalancer.server.port=8080"
```

### **2. Subdomain Applications**

```yaml
# Blog application
services:
  blog:
    image: blog:latest
    networks:
      - traefik-public
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.blog.rule=Host(`blog.eduardoshanahan.com`)"
      - "traefik.http.routers.blog.entrypoints=websecure"
      - "traefik.http.routers.blog.tls=true"
      - "traefik.http.routers.blog.tls.certresolver=letsencrypt"
      - "traefik.http.services.blog.loadbalancer.server.port=8080"

# Articles application
services:
  articles:
    image: articles:latest
    networks:
      - traefik-public
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.articles.rule=Host(`articles.eduardoshanahan.com`)"
      - "traefik.http.routers.articles.entrypoints=websecure"
      - "traefik.http.routers.articles.tls=true"
      - "traefik.http.routers.articles.tls.certresolver=letsencrypt"
      - "traefik.http.services.articles.loadbalancer.server.port=8080"
```

### **3. API and Admin Subdomains**

```yaml
# API service
services:
  api:
    image: api:latest
    networks:
      - traefik-public
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.api.rule=Host(`api.eduardoshanahan.com`)"
      - "traefik.http.routers.api.entrypoints=websecure"
      - "traefik.http.routers.api.tls=true"
      - "traefik.http.routers.api.tls.certresolver=letsencrypt"
      - "traefik.http.services.api.loadbalancer.server.port=8080"
      - "traefik.http.routers.api.middlewares=api-security"

# Admin panel
services:
  admin:
    image: admin:latest
    networks:
      - traefik-public
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.admin.rule=Host(`admin.eduardoshanahan.com`)"
      - "traefik.http.routers.admin.entrypoints=websecure"
      - "traefik.http.routers.admin.tls=true"
      - "traefik.http.routers.admin.tls.certresolver=letsencrypt"
      - "traefik.http.services.admin.loadbalancer.server.port=8080"
      - "traefik.http.routers.admin.middlewares=admin-auth"
```

## DNS Configuration

### **Required DNS Records**
```
Type    Name                    Value
A       www                     <VPS_IP>
A       blog                    <VPS_IP>
A       articles                <VPS_IP>
A       api                     <VPS_IP>
A       admin                   <VPS_IP>
A       traefik                 <VPS_IP>
CNAME   @                       www.eduardoshanahan.com
```

### **DNS Management**
- **Provider**: Any DNS provider (Cloudflare, Route53, etc.)
- **TTL**: 300 seconds (5 minutes) for quick updates
- **Health Checks**: Optional DNS health checks

## SSL Certificate Strategy

### **Certificate Coverage**
- **Main Domain**: `eduardoshanahan.com`
- **Subdomains**: `www`, `blog`, `articles`, `api`, `admin`, `traefik`
- **Certificate Type**: Individual certificates per subdomain
- **Renewal**: Automatic via Let's Encrypt

### **Certificate Configuration**
```yaml
# Each subdomain gets its own certificate
certificatesResolvers:
  letsencrypt:
    acme:
      email: your-email@domain.com
      storage: /certs/acme.json
      httpChallenge:
        entryPoint: web
```

## Middleware Configuration

### **1. Security Headers Middleware**
```yaml
# Security headers for all applications
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

### **2. API Security Middleware**
```yaml
# API-specific security
api-security:
  headers:
    accessControlAllowMethods:
      - GET
      - POST
      - PUT
      - DELETE
    accessControlAllowHeaders:
      - Authorization
      - Content-Type
    accessControlMaxAge: 86400
```

### **3. Admin Authentication Middleware**
```yaml
# Admin authentication
admin-auth:
  basicAuth:
    users:
      - "admin:$2y$10$hashedpassword"
    removeHeader: true
```

## Application Integration Examples

### **1. WordPress Blog**
```yaml
services:
  wordpress:
    image: wordpress:latest
    environment:
      WORDPRESS_DB_HOST: db
      WORDPRESS_DB_NAME: wordpress
      WORDPRESS_DB_USER: wordpress
      WORDPRESS_DB_PASSWORD: password
    networks:
      - traefik-public
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.wordpress.rule=Host(`blog.eduardoshanahan.com`)"
      - "traefik.http.routers.wordpress.entrypoints=websecure"
      - "traefik.http.routers.wordpress.tls=true"
      - "traefik.http.routers.wordpress.tls.certresolver=letsencrypt"
      - "traefik.http.services.wordpress.loadbalancer.server.port=80"
```

### **2. Static Site Generator**
```yaml
services:
  hugo:
    image: nginx:alpine
    volumes:
      - ./hugo/public:/usr/share/nginx/html
    networks:
      - traefik-public
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.hugo.rule=Host(`www.eduardoshanahan.com`)"
      - "traefik.http.routers.hugo.entrypoints=websecure"
      - "traefik.http.routers.hugo.tls=true"
      - "traefik.http.routers.hugo.tls.certresolver=letsencrypt"
      - "traefik.http.services.hugo.loadbalancer.server.port=80"
```

### **3. API Service**
```yaml
services:
  api:
    image: api-service:latest
    environment:
      DATABASE_URL: postgresql://user:pass@db:5432/api
    networks:
      - traefik-public
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.api.rule=Host(`api.eduardoshanahan.com`)"
      - "traefik.http.routers.api.entrypoints=websecure"
      - "traefik.http.routers.api.tls=true"
      - "traefik.http.routers.api.tls.certresolver=letsencrypt"
      - "traefik.http.services.api.loadbalancer.server.port=3000"
      - "traefik.http.routers.api.middlewares=api-security"
```

## Ansible Implementation

### **1. Domain Variables**
```yaml
# defaults/main.yml
traefik_main_domain: "eduardoshanahan.com"
traefik_subdomains:
  - "www"
  - "blog"
  - "articles"
  - "api"
  - "admin"
  - "traefik"
traefik_letsencrypt_email: "your-email@domain.com"
```

### **2. DNS Configuration Task**
```yaml
# tasks/dns.yml
- name: Verify DNS records
  ansible.builtin.uri:
    url: "https://dns.google/resolve?name={{ item }}.{{ traefik_main_domain }}&type=A"
    method: GET
  loop: "{{ traefik_subdomains }}"
  register: dns_check
  failed_when: dns_check.results[0].json.Answer[0].data != ansible_default_ipv4.address
```

### **3. Application Template**
```yaml
# templates/application-compose.yml.j2
version: '3.8'

services:
  {{ app_name }}:
    image: {{ app_image }}
    container_name: {{ app_name }}
    restart: unless-stopped
    networks:
      - traefik-public
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.{{ app_name }}.rule=Host(`{{ app_subdomain }}.{{ traefik_main_domain }}`)"
      - "traefik.http.routers.{{ app_name }}.entrypoints=websecure"
      - "traefik.http.routers.{{ app_name }}.tls=true"
      - "traefik.http.routers.{{ app_name }}.tls.certresolver=letsencrypt"
      - "traefik.http.services.{{ app_name }}.loadbalancer.server.port={{ app_port }}"
      {% if app_middlewares %}
      - "traefik.http.routers.{{ app_name }}.middlewares={{ app_middlewares }}"
      {% endif %}

networks:
  traefik-public:
    external: true
```

## Monitoring and Health Checks

### **1. Domain Health Monitoring**
```yaml
# tasks/monitoring.yml
- name: Check domain accessibility
  ansible.builtin.uri:
    url: "https://{{ item }}.{{ traefik_main_domain }}"
    method: GET
    status_code: 200
  loop: "{{ traefik_subdomains }}"
  register: domain_health
```

### **2. SSL Certificate Monitoring**
```yaml
- name: Check SSL certificate expiration
  ansible.builtin.command: |
    echo | openssl s_client -servername {{ item }}.{{ traefik_main_domain }} -connect {{ item }}.{{ traefik_main_domain }}:443 2>/dev/null | openssl x509 -noout -dates
  loop: "{{ traefik_subdomains }}"
  register: ssl_cert_check
```

## Best Practices

### **1. URL Naming Conventions**

- Use descriptive, memorable subdomain names
- Keep names short and consistent
- Avoid special characters or numbers
- Use lowercase letters only

### **2. Security Considerations**

- Enable HTTPS for all subdomains
- Use security headers middleware
- Implement rate limiting for API endpoints
- Regular SSL certificate monitoring

### **3. Performance Optimization**

- Use appropriate TTL values for DNS records
- Monitor response times for each subdomain
- Implement caching where appropriate
- Regular performance testing

## Troubleshooting

### **1. Common Issues**

- **DNS Resolution**: Check DNS records and propagation
- **SSL Certificates**: Verify Let's Encrypt configuration
- **Routing**: Check Traefik labels and configuration
- **Network**: Verify Docker network connectivity

### **2. Debugging Commands**

```bash
# Check Traefik configuration
docker exec traefik traefik version

# Check routing rules
docker exec traefik traefik healthcheck

# Check SSL certificates
docker exec traefik ls -la /certs/

# Check application connectivity
docker exec traefik curl -I http://localhost:8080
```

## Next Steps

1. **Implement DNS configuration**
2. **Set up SSL certificate management**
3. **Create application templates**
4. **Configure monitoring and health checks**
5. **Test routing and SSL functionality**
