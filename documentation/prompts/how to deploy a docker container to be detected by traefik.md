# How to Deploy a Docker Container to be Detected by Traefik

## Overview

This guide explains how to deploy Docker containers that will be automatically detected and served by the Traefik reverse proxy. Traefik is configured to automatically discover containers on the `traefik-network` and provide SSL/TLS certificates via Let's Encrypt.

## Prerequisites

- Your Docker container must be connected to the `traefik-network`
- You must have a domain name pointing to the server
- Your container must expose a web service (typically on port 80, 8080, or similar)

## Network Configuration

### Connect to Traefik Network

Your container must be connected to the `traefik-network` for Traefik to discover it:

```bash
# When running with docker run
docker run --network traefik-network ...

# When using docker-compose
networks:
  - traefik-network
```

## Required Labels

Traefik uses Docker labels to configure routing. Here are the essential labels:

### Basic Labels

```yaml
labels:
  # Enable Traefik for this container
  - "traefik.enable=true"
  
  # Define the routing rule (replace 'yourdomain.com' with your actual domain)
  - "traefik.http.routers.your-app.rule=Host(`yourdomain.com`)"
  
  # Specify which port your application listens on inside the container
  - "traefik.http.services.your-app.loadbalancer.server.port=80"
  
  # Enable both HTTP and HTTPS entrypoints
  - "traefik.http.routers.your-app.entrypoints=web,websecure"
  
  # Enable automatic SSL certificate generation
  - "traefik.http.routers.your-app.tls.certresolver=letsencrypt"
```

### Advanced Labels (Optional)

```yaml
labels:
  # Force HTTPS redirect
  - "traefik.http.routers.your-app.tls=true"
  
  # Add middleware for security headers
  - "traefik.http.routers.your-app.middlewares=security-headers"
  
  # Configure health checks
  - "traefik.http.services.your-app.loadbalancer.healthcheck.path=/health"
  - "traefik.http.services.your-app.loadbalancer.healthcheck.interval=10s"
```

## Complete Examples

### Example 1: Simple Nginx Website

```bash
docker run -d \
  --name my-website \
  --network traefik-network \
  -l "traefik.enable=true" \
  -l "traefik.http.routers.mywebsite.rule=Host(`example.com`)" \
  -l "traefik.http.services.mywebsite.loadbalancer.server.port=80" \
  -l "traefik.http.routers.mywebsite.entrypoints=web,websecure" \
  -l "traefik.http.routers.mywebsite.tls.certresolver=letsencrypt" \
  nginx:alpine
```

### Example 2: Docker Compose

```yaml
version: '3.8'

services:
  my-app:
    image: your-app:latest
    container_name: my-app
    networks:
      - traefik-network
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.myapp.rule=Host(`app.example.com`)"
      - "traefik.http.services.myapp.loadbalancer.server.port=8080"
      - "traefik.http.routers.myapp.entrypoints=web,websecure"
      - "traefik.http.routers.myapp.tls.certresolver=letsencrypt"
    ports:
      - "8080:8080"  # Optional: for debugging

networks:
  traefik-network:
    external: true
```

### Example 3: Multiple Domains/Subdomains

```yaml
services:
  my-app:
    image: your-app:latest
    networks:
      - traefik-network
    labels:
      - "traefik.enable=true"
      # Main domain
      - "traefik.http.routers.myapp-main.rule=Host(`example.com`)"
      - "traefik.http.services.myapp-main.loadbalancer.server.port=80"
      - "traefik.http.routers.myapp-main.entrypoints=web,websecure"
      - "traefik.http.routers.myapp-main.tls.certresolver=letsencrypt"
      # Subdomain
      - "traefik.http.routers.myapp-api.rule=Host(`api.example.com`)"
      - "traefik.http.services.myapp-api.loadbalancer.server.port=3000"
      - "traefik.http.routers.myapp-api.entrypoints=web,websecure"
      - "traefik.http.routers.myapp-api.tls.certresolver=letsencrypt"
```

## Port Configuration

### Common Application Ports

| Application Type | Typical Port | Label Configuration |
|------------------|--------------|-------------------|
| Nginx/Apache | 80 | `loadbalancer.server.port=80` |
| Node.js/Express | 3000 | `loadbalancer.server.port=3000` |
| Python Flask | 5000 | `loadbalancer.server.port=5000` |
| Python Django | 8000 | `loadbalancer.server.port=8000` |
| Java Spring Boot | 8080 | `loadbalancer.server.port=8080` |
| PHP-FPM | 9000 | `loadbalancer.server.port=9000` |

### Verify Your Application Port

Check what port your application listens on inside the container:

```bash
# Check the container logs
docker logs your-container-name

# Or exec into the container
docker exec -it your-container-name netstat -tlnp
```

## SSL/TLS Configuration

### Automatic Certificate Generation

Traefik will automatically:
- Request Let's Encrypt certificates for your domains
- Renew certificates before expiration
- Redirect HTTP to HTTPS
- Handle certificate validation via HTTP challenge

### Certificate Requirements

- Domain must be publicly accessible
- Port 80 must be open for Let's Encrypt validation
- Domain must resolve to the server IP

## Testing Your Deployment

### 1. Check Container Status

```bash
# Verify container is running
docker ps | grep your-container-name

# Check container logs
docker logs your-container-name
```

### 2. Check Traefik Discovery

```bash
# Check if Traefik sees your container
docker exec traefik traefik healthcheck
```

### 3. Test Domain Access

```bash
# Test HTTP (should redirect to HTTPS)
curl -I http://yourdomain.com

# Test HTTPS
curl -I https://yourdomain.com
```

## Troubleshooting

### Common Issues

#### Container Not Detected
- **Problem**: Container not on `traefik-network`
- **Solution**: Add `--network traefik-network` to docker run command

#### SSL Certificate Not Generated
- **Problem**: Domain not accessible or port 80 blocked
- **Solution**: Ensure domain resolves to server and port 80 is open

#### Wrong Port Configuration
- **Problem**: Application not accessible on specified port
- **Solution**: Check application logs and verify correct port in labels

#### 404 Errors
- **Problem**: Application not responding on specified port
- **Solution**: Verify application is running and listening on correct port

### Debug Commands

```bash
# Check Traefik logs
docker logs traefik

# Check your application logs
docker logs your-container-name

# Test connectivity from Traefik container
docker exec traefik wget -qO- http://your-container-name:port

# Check Traefik configuration
docker exec traefik cat /traefik.yml
```

## Best Practices

### 1. Container Naming
- Use descriptive container names
- Avoid special characters in router names

### 2. Label Organization
- Use consistent naming for routers and services
- Group related labels together

### 3. Health Checks
- Implement health check endpoints in your applications
- Use Traefik health check labels for better reliability

### 4. Security
- Don't expose unnecessary ports
- Use HTTPS-only when possible
- Implement proper security headers

### 5. Monitoring
- Monitor container logs
- Set up alerts for certificate expiration
- Track application performance

## Example: Complete WordPress Deployment

```yaml
version: '3.8'

services:
  wordpress:
    image: wordpress:latest
    container_name: wordpress
    environment:
      WORDPRESS_DB_HOST: db
      WORDPRESS_DB_USER: wordpress
      WORDPRESS_DB_PASSWORD: wordpress_password
      WORDPRESS_DB_NAME: wordpress
    networks:
      - traefik-network
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.wordpress.rule=Host(`blog.example.com`)"
      - "traefik.http.services.wordpress.loadbalancer.server.port=80"
      - "traefik.http.routers.wordpress.entrypoints=web,websecure"
      - "traefik.http.routers.wordpress.tls.certresolver=letsencrypt"
    depends_on:
      - db

  db:
    image: mysql:5.7
    container_name: wordpress-db
    environment:
      MYSQL_DATABASE: wordpress
      MYSQL_USER: wordpress
      MYSQL_PASSWORD: wordpress_password
      MYSQL_ROOT_PASSWORD: somewordpress
    networks:
      - traefik-network

networks:
  traefik-network:
    external: true
```

## Support

If you encounter issues:
1. Check the troubleshooting section above
2. Review Traefik and application logs
3. Verify network connectivity and port configuration
4. Contact the infrastructure team for assistance

---

**Note**: This guide assumes Traefik is already deployed and running on the `traefik-network`. The Traefik instance is configured with Let's Encrypt integration and automatic container discovery.
