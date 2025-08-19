#!/bin/bash

# Network Security Test Script
# This script provides manual validation of the network security implementation

set -e

echo "========================================"
echo "NETWORK SECURITY MANUAL TEST SCRIPT"
echo "========================================"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Notification script path
NOTIFICATION_SCRIPT="/opt/security-updates/security-update-notify.sh"

# Test functions
test_firewall() {
    echo -e "\n${YELLOW}Testing Firewall Configuration...${NC}"
    
    # Check UFW status
    if ufw status | grep -q "Status: active"; then
        echo -e "${GREEN}✓ UFW is active${NC}"
    else
        echo -e "${RED}✗ UFW is not active${NC}"
        if [ -f "$NOTIFICATION_SCRIPT" ]; then
            "$NOTIFICATION_SCRIPT" "Network Security Test Failed" "UFW firewall is not active"
        fi
        return 1
    fi
    
    # Check for broad network ranges (should NOT exist)
    if ufw status numbered | grep -q "172.16.0.0/12\|192.168.0.0/16\|10.0.0.0/8"; then
        echo -e "${RED}✗ Broad network ranges are still allowed${NC}"
        if [ -f "$NOTIFICATION_SCRIPT" ]; then
            "$NOTIFICATION_SCRIPT" "Network Security Test Failed" "Broad network ranges are still allowed"
        fi
        return 1
    else
        echo -e "${GREEN}✓ Broad network ranges are correctly blocked${NC}"
    fi
    
    # Check for specific network ranges (should exist)
    if ufw status numbered | grep -q "172.20.0.0/16\|172.21.0.0/16\|172.22.0.0/16"; then
        echo -e "${GREEN}✓ Specific network ranges are allowed${NC}"
    else
        echo -e "${RED}✗ Specific network ranges are not allowed${NC}"
        if [ -f "$NOTIFICATION_SCRIPT" ]; then
            "$NOTIFICATION_SCRIPT" "Network Security Test Failed" "Specific network ranges are not allowed"
        fi
        return 1
    fi
}

test_docker_networks() {
    echo -e "\n${YELLOW}Testing Docker Networks...${NC}"
    
    # Check if required networks exist
    for network in web-network db-network monitoring-network; do
        if docker network ls | grep -q "$network"; then
            echo -e "${GREEN}✓ Network $network exists${NC}"
        else
            echo -e "${RED}✗ Network $network does not exist${NC}"
            if [ -f "$NOTIFICATION_SCRIPT" ]; then
                "$NOTIFICATION_SCRIPT" "Network Security Test Failed" "Docker network $network does not exist"
            fi
            return 1
        fi
    done
    
    # Check network configurations
    for network in web-network db-network monitoring-network; do
        subnet=$(docker network inspect "$network" --format '{{.IPAM.Config}}' | grep -o '172\.[0-9]\{1,3\}\.0\.0/16')
        if [ -n "$subnet" ]; then
            echo -e "${GREEN}✓ Network $network has correct subnet: $subnet${NC}"
        else
            echo -e "${RED}✗ Network $network has incorrect subnet${NC}"
            if [ -f "$NOTIFICATION_SCRIPT" ]; then
                "$NOTIFICATION_SCRIPT" "Network Security Test Failed" "Docker network $network has incorrect subnet"
            fi
            return 1
        fi
    done
}

test_network_isolation() {
    echo -e "\n${YELLOW}Testing Network Isolation...${NC}"
    
    # Create test containers
    echo "Creating test containers..."
    docker run -d --name test-web --network web-network alpine tail -f /dev/null
    docker run -d --name test-db --network db-network alpine tail -f /dev/null
    
    # Test cross-network communication (should fail)
    if docker exec test-web ping -c 1 test-db 2>/dev/null; then
        echo -e "${RED}✗ Network isolation failed - containers can communicate across networks${NC}"
        if [ -f "$NOTIFICATION_SCRIPT" ]; then
            "$NOTIFICATION_SCRIPT" "Network Security Test Failed" "Network isolation failed - containers can communicate across networks"
        fi
        return 1
    else
        echo -e "${GREEN}✓ Network isolation working - containers cannot communicate across networks${NC}"
    fi
    
    # Test external connectivity (should succeed)
    if docker exec test-web ping -c 1 8.8.8.8 >/dev/null 2>&1; then
        echo -e "${GREEN}✓ External connectivity working${NC}"
    else
        echo -e "${RED}✗ External connectivity failed${NC}"
        if [ -f "$NOTIFICATION_SCRIPT" ]; then
            "$NOTIFICATION_SCRIPT" "Network Security Test Failed" "External connectivity failed"
        fi
        return 1
    fi
    
    # Cleanup test containers
    docker rm -f test-web test-db >/dev/null 2>&1
}

test_logging() {
    echo -e "\n${YELLOW}Testing Logging Configuration...${NC}"
    
    # Check if log files exist and are writable
    for log_file in /var/log/ufw.log /var/log/docker.log; do
        if [ -f "$log_file" ] && [ -w "$log_file" ]; then
            echo -e "${GREEN}✓ Log file $log_file exists and is writable${NC}"
        else
            echo -e "${RED}✗ Log file $log_file is missing or not writable${NC}"
            if [ -f "$NOTIFICATION_SCRIPT" ]; then
                "$NOTIFICATION_SCRIPT" "Network Security Test Failed" "Log file $log_file is missing or not writable"
            fi
            return 1
        fi
    done
}

# Main execution
main() {
    local exit_code=0
    
    echo -e "\n${YELLOW}Starting network security tests...${NC}"
    
    # Run all tests
    test_firewall || exit_code=1
    test_docker_networks || exit_code=1
    test_network_isolation || exit_code=1
    test_logging || exit_code=1
    
    # Summary
    echo -e "\n${YELLOW}Test Summary:${NC}"
    if [ $exit_code -eq 0 ]; then
        echo -e "${GREEN}✓ All network security tests passed${NC}"
        if [ -f "$NOTIFICATION_SCRIPT" ]; then
            "$NOTIFICATION_SCRIPT" "Network Security Test Passed" "All network security tests passed successfully"
        fi
    else
        echo -e "${RED}✗ Some network security tests failed${NC}"
        if [ -f "$NOTIFICATION_SCRIPT" ]; then
            "$NOTIFICATION_SCRIPT" "Network Security Test Failed" "Some network security tests failed"
        fi
    fi
    
    exit $exit_code
}

# Run main function
main "$@" 