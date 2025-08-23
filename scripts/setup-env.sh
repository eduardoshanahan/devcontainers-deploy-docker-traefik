#!/bin/bash
# =============================================================================
# Environment Setup Script for Traefik Deployment
# =============================================================================
# This script helps set up the .env file from the template
# =============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
ENV_FILE="$PROJECT_ROOT/.env"
ENV_EXAMPLE="$PROJECT_ROOT/.env.example"

echo "============================================================================="
echo "TRAEFIK DEPLOYMENT - ENVIRONMENT SETUP"
echo "============================================================================="

# Check if .env already exists
if [ -f "$ENV_FILE" ]; then
    echo "⚠️  .env file already exists at: $ENV_FILE"
    echo "   If you want to recreate it, delete the existing file first."
    echo "   Current .env file will be preserved."
    exit 0
fi

# Check if .env.example exists
if [ ! -f "$ENV_EXAMPLE" ]; then
    echo "❌ Error: .env.example template not found at: $ENV_EXAMPLE"
    echo "   Please ensure the template file exists."
    exit 1
fi

# Create .env from template
echo " Creating .env file from template..."
cp "$ENV_EXAMPLE" "$ENV_FILE"

echo "✅ .env file created successfully at: $ENV_FILE"
echo ""
echo "🔧 Next steps:"
echo "   1. Edit the .env file with your actual values:"
echo "      nano $ENV_FILE"
echo ""
echo "   2. Customize these variables:"
echo "      - VPS_SERVER_IP: Your VPS IP address"
echo "      - DEPLOYMENT_USER: Your deployment username"
echo "      - DEPLOYMENT_SSH_KEY: Path to your SSH key"
echo "      - TRAEFIK_ENVIRONMENT: development, staging, or production"
echo "      - Environment-specific passwords and settings"
echo ""
echo "   3. Switch environments by changing TRAEFIK_ENVIRONMENT:"
echo "      - development: Dashboard enabled, monitoring disabled"
echo "      - staging: Dashboard enabled, monitoring enabled"
echo "      - production: Dashboard disabled, monitoring enabled"
echo ""
echo "   4. Source the environment before running Ansible:"
echo "      source $ENV_FILE"
echo ""
echo "⚠️  IMPORTANT: The .env file is NOT tracked in git for security."
echo "   Keep it safe and don't share it with others."
