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

# Obtain certificates using certbot's standalone mode
certbot certonly \
    --non-interactive \
    --agree-tos \
    --email "${CERTBOT_EMAIL}" \
    --standalone \
    --preferred-challenges http \
    -d ${DOMAINS//,/ -d } \
    --keep-until-expiring \
    --expand

# Generate nginx config
export PRIMARY_DOMAIN=$(get_primary_domain)
envsubst '$DOMAINS $PRIMARY_DOMAIN' < /etc/nginx/templates/default.conf.template > /etc/nginx/conf.d/default.conf

# Start nginx in foreground
exec nginx -g "daemon off;"
