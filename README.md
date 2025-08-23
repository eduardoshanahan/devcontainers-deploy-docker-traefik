# Traefik installation with a Docker container, running on a VPS

## Why do I need this project

I want to be able to work in Visual Studio Code or Cursor using devcontainers to develop and deploy a Docker container running Traefik. The objective is to deploy other web applications later, and to have Traefik acting as a reverse proxy.

The deployment is done by way of Ansible scripts. The prerequisite is that the VPS server where this will be deployed is already running Docker, ideally from a setup done using [Docker Installation in a remote Ubuntu VPS with Ansible & Devcontainers](https://github.com/eduardoshanahan/devcontainers-deploy-docker).

The original set of files were created as a clone of [Development Container Template - Just Ansible](https://github.com/eduardoshanahan/devcontainers-ansible).

## Traefik Reverse Proxy Features

This project provides a **completely standalone** Traefik reverse proxy deployment that follows the coding standards and security practices from `devcontainers-deploy-docker` but operates independently.

### Key Principles

- **Completely Independent** - No integration with existing projects
- **Non-Intrusive** - Won't break existing Docker deployments
- **Repeatable** - Can be deployed multiple times safely
- **Container-Aware** - Automatically discovers containers from other projects
- **Standards-Based** - Follows your established coding and security practices

## Quick Start

### **1. Environment Setup**

```bash
# Set up your environment configuration
./scripts/setup-env.sh

# Edit the .env file with your actual values
nano .env
```

### **2. Deploy Traefik**

```bash
# Deploy to current environment (development/staging/production)
./scripts/deploy.sh

# Or manually source and run
source .env
ansible-playbook -i src/inventory src/playbooks/deploy_traefik.yml
```

### **3. Switch Environments**

```bash
# Switch to staging
sed -i 's/TRAEFIK_ENVIRONMENT="development"/TRAEFIK_ENVIRONMENT="staging"/' .env

# Switch to production
sed -i 's/TRAEFIK_ENVIRONMENT="development"/TRAEFIK_ENVIRONMENT="production"/' .env

# Deploy to new environment
./scripts/deploy.sh
```

## Environment Configuration

### **Environment Variables**

The project uses a `.env` file for configuration. **Never commit this file to git** - it contains sensitive information.

#### **Required Variables**

| Variable | Description | Example |
|----------|-------------|---------|
| `VPS_SERVER_IP` | Your VPS IP address | `vps-153d27d0.vps.ovh.net` |
| `DEPLOYMENT_USER` | Username for deployment | `docker_deployment` |
| `DEPLOYMENT_SSH_KEY` | Path to your SSH key | `~/.ssh/ovh-eduardo` |
| `TRAEFIK_ENVIRONMENT` | Target environment | `development`, `staging`, or `production` |
| `TRAEFIK_ADMIN_PASSWORD` | Dashboard admin password | `your-secure-password` |

#### **Environment-Specific Overrides**

The `.env` file automatically sets different values based on `TRAEFIK_ENVIRONMENT`:

**Development:**

- Dashboard: Enabled
- Monitoring: Disabled
- Backup: Disabled
- Rate Limiting: Disabled
- Ports: 8080 (non-conflicting)

**Staging:**

- Dashboard: Enabled
- Monitoring: Enabled
- Backup: Enabled
- Rate Limiting: Enabled
- Ports: 8080 (non-conflicting)

**Production:**

- Dashboard: Disabled (security)
- Monitoring: Enabled
- Backup: Enabled
- Rate Limiting: Enabled
- Ports: 80/443 (standard HTTP/HTTPS)

### **Configuration Files**

The project structure follows Ansible best practices:

```text
/workspace/
├── .env # Your configuration (NOT in git)
├── .env.example # Template (in git)
├── scripts/
│ ├── setup-env.sh # Environment setup script
│ └── deploy.sh # Deployment wrapper
└── src/
├── inventory/ # Ansible inventory
│ ├── hosts.yml # Host definitions
│ └── group_vars/ # Variable definitions
├── playbooks/ # Ansible playbooks
│ └── deploy_traefik.yml
└── roles/ # Ansible roles
└── deploy_traefik/ # Traefik deployment role    
```

## Project Architecture

### **Network Design**

- **Traefik Network**: `prod-web-network` (172.20.0.0/16)
- **Container Discovery**: Automatic via Docker labels
- **Port Management**: Environment-specific port configurations
- **SSL/TLS**: Let's Encrypt integration with automatic renewal

### **Security Features**

- **User Isolation**: Dedicated deployment user
- **Network Isolation**: Separate networks per project
- **SSL/TLS**: End-to-end encryption
- **Access Control**: SSH key-based authentication only

## Deployment Process

### **Automated Deployment**

The `./scripts/deploy.sh` script handles the complete deployment:

1. **Environment Loading**: Sources `.env` file
2. **Validation**: Checks required variables
3. **Summary**: Shows deployment configuration
4. **Confirmation**: Prompts for user approval
5. **Execution**: Runs Ansible playbook

### **Manual Deployment**

For advanced users or debugging:

```bash
# Load environment
source .env

# Verify configuration
ansible-inventory --list -i src/inventory

# Run deployment
ansible-playbook -i src/inventory src/playbooks/deploy_traefik.yml -vvv
```

## Monitoring and Management

### **Dashboard Access**

- **Development/Staging**: Dashboard enabled on port 8080
- **Production**: Dashboard disabled for security
- **Health Checks**: Automatic container health monitoring
- **Logs**: Centralized logging with rotation

### **Maintenance Tasks**

- **Updates**: Version updates via Ansible
- **Backups**: Configuration and certificate backups
- **Monitoring**: Performance and security monitoring
- **Scaling**: Horizontal scaling support

## Troubleshooting

### **Common Issues**

#### **Environment Variables Not Loaded**

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
# Check SSH key permissions
chmod 600 ~/.ssh/ovh-eduardo

# Test SSH connection
ssh -i ~/.ssh/ovh-eduardo docker_deployment@your-vps-ip
```

#### **Deployment Fails**

```bash
# Check Ansible output
ansible-playbook -i src/inventory src/playbooks/deploy_traefik.yml -vvv

# Verify Docker is running
docker info
```

### **Debug Mode**

```bash
# Enable verbose output
export ANSIBLE_VERBOSITY=4

# Run with maximum verbosity
ansible-playbook -i src/inventory src/playbooks/deploy_traefik.yml -vvvv
```

## Development Workflow

### **Local Development**

1. **Setup Environment**: Run `./scripts/setup-env.sh`
2. **Configure Variables**: Edit `.env` file
3. **Test Locally**: Use `--check` mode for dry runs
4. **Deploy**: Run `./scripts/deploy.sh`

### **Environment Switching**

1. **Change Environment**: Edit `TRAEFIK_ENVIRONMENT` in `.env`
2. **Verify Configuration**: Check environment-specific settings
3. **Deploy**: Run deployment script
4. **Validate**: Test functionality in new environment

## Contributing

### **Development Guidelines**

- **Follow Ansible Best Practices**: Use proper modules and error handling
- **Maintain Security**: Never commit sensitive data
- **Test Changes**: Validate in development environment first
- **Document Updates**: Update relevant documentation

### **Code Standards**

- **Ansible**: Follow `.cursor/rules` guidelines
- **Markdown**: Use proper formatting and structure
- **Shell Scripts**: Include error handling and validation
- **Templates**: Use consistent variable naming

## Support and Resources

### **Documentation**

- [Environment Setup Guide](documentation/ENVIRONMENT_SETUP.md)
- [Deployment Guide](documentation/DEPLOYMENT.md)
- [Project Analysis](documentation/research-and-development/)
- [Implementation Details](documentation/research-and-development/implementation/)

### **External Resources**

- [Traefik Documentation](https://doc.traefik.io/traefik/)
- [Ansible Documentation](https://docs.ansible.com/)
- [Docker Documentation](https://docs.docker.com/)
- [Let's Encrypt Documentation](https://letsencrypt.org/docs/)

## Conclusion

This project provides a **production-ready, standalone Traefik deployment** that follows industry best practices and your established coding standards.

### **Key Benefits**

- **Security**: Enterprise-grade security with proper isolation
- **Scalability**: Designed for multi-application deployments
- **Maintainability**: Automated deployment and management
- **Flexibility**: Support for multiple environments

### **Ready for Production**

- **Security Hardened**: Production-ready security configuration
- **Automated**: Complete deployment automation
- **Monitored**: Built-in health checks and logging
- **Documented**: Comprehensive documentation and guides

## Next Steps

1. **Complete Environment Setup**: Run `./scripts/setup-env.sh`
2. **Configure Your Environment**: Edit `.env` with your values
3. **Deploy to Development**: Test in development environment first
4. **Scale to Production**: Deploy to staging, then production
5. **Add Applications**: Deploy web applications behind Traefik

## Deploying Applications Behind Traefik

### **Example Container Labels for SSL**

When you deploy other containers behind Traefik, they need proper Docker labels to get automatic SSL certificates and routing. Here are examples for common use cases:

#### **1. Basic Web Application**

```yaml
# Example: WordPress container
services:
  wordpress:
    image: wordpress:latest
    networks:
      - prod-web-network  # Same network as Traefik
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.wordpress.rule=Host(`blog.yourdomain.com`)"
      - "traefik.http.routers.wordpress.entrypoints=websecure"
      - "traefik.http.routers.wordpress.tls=true"
      - "traefik.http.routers.wordpress.tls.certresolver=letsencrypt"
      - "traefik.http.services.wordpress.loadbalancer.server.port=80"
```

#### **2. API Service**

```yaml
# Example: API container
services:
  api:
    image: your-api:latest
    networks:
      - prod-web-network
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.api.rule=Host(`api.yourdomain.com`)"
      - "traefik.http.routers.api.entrypoints=websecure"
      - "traefik.http.routers.api.tls=true"
      - "traefik.http.routers.api.tls.certresolver=letsencrypt"
      - "traefik.http.services.api.loadbalancer.server.port=3000"
      - "traefik.http.routers.api.middlewares=security-headers"
```

#### **3. Multiple Subdomains for One Application**

```yaml
# Example: Application with multiple subdomains
services:
  myapp:
    image: myapp:latest
    networks:
      - prod-web-network
    labels:
      # Main application
      - "traefik.enable=true"
      - "traefik.http.routers.myapp.rule=Host(`app.yourdomain.com`)"
      - "traefik.http.routers.myapp.entrypoints=websecure"
      - "traefik.http.routers.myapp.tls=true"
      - "traefik.http.routers.myapp.tls.certresolver=letsencrypt"
      - "traefik.http.services.myapp.loadbalancer.server.port=8080"
      
      # Admin subdomain
      - "traefik.http.routers.myapp-admin.rule=Host(`admin.yourdomain.com`)"
      - "traefik.http.routers.myapp-admin.entrypoints=websecure"
      - "traefik.http.routers.myapp-admin.tls=true"
      - "traefik.http.routers.myapp-admin.tls.certresolver=letsencrypt"
      - "traefik.http.services.myapp-admin.loadbalancer.server.port=8080"
```

#### **4. Static Site with Custom Middleware**

```yaml
# Example: Static site with security headers
services:
  static-site:
    image: nginx:alpine
    volumes:
      - ./site:/usr/share/nginx/html
    networks:
      - prod-web-network
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.static.rule=Host(`www.yourdomain.com`)"
      - "traefik.http.routers.static.entrypoints=websecure"
      - "traefik.http.routers.static.tls=true"
      - "traefik.http.routers.static.tls.certresolver=letsencrypt"
      - "traefik.http.services.static.loadbalancer.server.port=80"
      - "traefik.http.routers.static.middlewares=security-headers,rate-limit"
```

### **Required Network Configuration**

All containers must join the `prod-web-network` to communicate with Traefik:

```yaml
networks:
  prod-web-network:
    external: true
    name: prod-web-network
```

### **DNS Configuration Required**

For SSL to work automatically, you need DNS records pointing to your VPS:

```text
Type Name Value
A blog.yourdomain.com <VPS_IP>
A api.yourdomain.com <VPS_IP>
A app.yourdomain.com <VPS_IP>
A www.yourdomain.com <VPS_IP>
```

### **Automatic SSL Benefits**

With this setup, Traefik will automatically:

- Generate SSL certificates via Let's Encrypt
- Renew certificates before expiration
- Apply security headers and HSTS
- Handle HTTP to HTTPS redirects
- Provide rate limiting and monitoring
