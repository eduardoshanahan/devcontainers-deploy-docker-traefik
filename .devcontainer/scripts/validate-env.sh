#!/bin/bash

# Required variables with their descriptions and validation rules
declare -A required_vars=(
    ["HOST_USERNAME"]="System username|^[a-z_][a-z0-9_-]*[$]?$"
    ["HOST_UID"]="User ID|^[0-9]+$"
    ["HOST_GID"]="Group ID|^[0-9]+$"
)

# Optional variables with default values and validation rules
declare -A optional_vars=(
    ["CONTAINER_HOSTNAME"]="dev|^[a-zA-Z][a-zA-Z0-9-]*$"
    ["EDITOR_CHOICE"]="cursor|^(code|cursor)$"
    ["GIT_USER_NAME"]="Dev User|^[a-zA-Z0-9 ._-]+$"
    ["GIT_USER_EMAIL"]="dev@example.com|^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$"
    ["DOCKER_IMAGE_NAME"]="dev-container|^[a-z0-9][a-z0-9._-]+$"
    ["DOCKER_IMAGE_TAG"]="latest|^[a-zA-Z0-9][a-zA-Z0-9._-]+$"
)

validate_var() {
    local var_name=$1
    local var_value=$2
    local pattern=$3
    local description=$4

    if ! [[ "$var_value" =~ ${pattern} ]]; then
        echo "Error: $var_name is invalid"
        echo "Description: $description"
        echo "Pattern: $pattern"
        echo "Current value: $var_value"
        return 1
    fi
    return 0
}

# Check required variables
errors=0
echo "Validating required variables..."
for var in "${!required_vars[@]}"; do
    IFS="|" read -r description pattern <<< "${required_vars[$var]}"
    value=${!var:-}
    if [ -z "$value" ]; then
        echo "Error: Required variable $var is not set"
        echo "Description: $description"
        ((errors++))
    else
        validate_var "$var" "$value" "$pattern" "$description" || ((errors++))
    fi
done

# Check optional variables
echo -e "\nValidating optional variables..."
for var in "${!optional_vars[@]}"; do
    IFS="|" read -r default pattern <<< "${optional_vars[$var]}"
    value=${!var:-$default}
    validate_var "$var" "$value" "$pattern" "Default: $default" || ((errors++))
done

if [ $errors -gt 0 ]; then
    echo -e "\nFound $errors error(s). Please fix them and try again."
    exit 1
else
    echo -e "\nAll environment variables are valid!"
fi 