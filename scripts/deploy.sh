#!/bin/bash

# =============================================================================
# TRAEFIK DEPLOYMENT SCRIPT
# =============================================================================

set -e
set -o pipefail

echo "=============================================================================="
echo "TRAEFIK DEPLOYMENT - STARTING"
echo "=============================================================================="

# Source environment variables
ENV_FILE="$(dirname "$0")/../.env"
if [ ! -f "$ENV_FILE" ]; then
    echo "ERROR: .env file not found at $ENV_FILE"
    echo "Please run ./scripts/setup-env.sh first"
    exit 1
fi

echo "Loading environment variables from: $ENV_FILE"
source "$ENV_FILE"

# Verify required environment variables
echo "Verifying required environment variables..."
required_vars=(
    "VPS_SERVER_IP"
    "INITIAL_DEPLOYMENT_USER"
    "INITIAL_DEPLOYMENT_SSH_KEY"
    "CONTAINERS_DEPLOYMENT_USER"
    "CONTAINERS_DEPLOYMENT_SSH_KEY"
    "TRAEFIK_ENVIRONMENT"
    "TRAEFIK_ADMIN_PASSWORD"
)

for var in "${required_vars[@]}"; do
    if [ -z "${!var}" ]; then
        echo "ERROR: Required environment variable $var is not set"
        exit 1
    fi
done

echo "All required environment variables are set"

# Display deployment configuration
echo ""
echo "Deployment Configuration:"
echo "   VPS Server: $VPS_SERVER_IP"
echo "   Initial User: $INITIAL_DEPLOYMENT_USER (sudo access)"
echo "   Docker User: $CONTAINERS_DEPLOYMENT_USER (Docker access)"
echo "   Environment: $TRAEFIK_ENVIRONMENT"
echo "   Initial SSH Key: $INITIAL_DEPLOYMENT_SSH_KEY"
echo "   Docker SSH Key: $CONTAINERS_DEPLOYMENT_SSH_KEY"
echo ""

# Prompt for confirmation
read -p "Proceed with Traefik deployment? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Deployment cancelled"
    exit 0
fi

echo "Running Traefik deployment..."

# Run Ansible playbook
cd "$(dirname "$0")/.."
ansible-playbook \
    -i src/inventory/hosts.yml \
    src/playbooks/deploy_traefik.yml

echo ""
echo "=============================================================================="
echo "TRAEFIK DEPLOYMENT - COMPLETED"
echo "=============================================================================="