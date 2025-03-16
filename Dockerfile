FROM nginx:alpine

# Install required packages
RUN apk add --no-cache \
    certbot \
    certbot-nginx \
    bash \
    python3 \
    py3-pip \
    py3-certbot \
    py3-setuptools \
    py3-wheel \
    openssl

# Create and use virtual environment for certbot-dns-azure
RUN python3 -m venv /opt/certbot-venv && \
    /opt/certbot-venv/bin/pip install --no-cache-dir certbot-dns-azure

# Create required directories
RUN mkdir -p /etc/letsencrypt /var/lib/letsencrypt /etc/azure

# Copy scripts and templates
COPY nginx.template.conf /etc/nginx/templates/default.conf.template
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 80 443

ENTRYPOINT ["/entrypoint.sh"]
