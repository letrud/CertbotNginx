#!/bin/bash
# Function to get primary domain from DOMAINS env var
get_primary_domain() {
    echo "$DOMAINS" | cut -d',' -f1 | tr -d ' '
}

# Check required environment variables
if [ -z "${CERTBOT_EMAIL}" ] || [ -z "${DOMAINS}" ]; then
    echo "Error: CERTBOT_EMAIL and DOMAINS environment variables are required"
    exit 1
fi

# Ensure Azure credentials directory exists
mkdir -p /etc/azure

# Check if Azure credentials exist
if [ ! -f "/etc/azure/azure.ini" ]; then
    echo "Error: Azure credentials file not found at /etc/azure/azure.ini"
    echo "Please mount this file with proper credentials"
    exit 1
fi

# Set proper permissions for the credentials file
chmod 600 /etc/azure/azure.ini

# Obtain certificates using certbot's dns-azure plugin
certbot certonly \
    --non-interactive \
    --agree-tos \
    --email "${CERTBOT_EMAIL}" \
    --authenticator dns-azure \
    --dns-azure-credentials /etc/azure/azure.ini \
    --dns-azure-propagation-seconds 120 \
    -d ${DOMAINS//,/ -d } \
    --keep-until-expiring \
    --expand

# Generate nginx config
export PRIMARY_DOMAIN=$(get_primary_domain)
envsubst '$DOMAINS $PRIMARY_DOMAIN' < /etc/nginx/templates/default.conf.template > /etc/nginx/conf.d/default.conf

# Start nginx in foreground
exec nginx -g "daemon off;"
