FROM nginx:alpine

# Install required packages
RUN apk add --no-cache \
    certbot \
    certbot-nginx \
    bash \
    python3 \
    py3-pip \
    openssl

# Install certbot-dns-azure plugin
RUN pip3 install certbot-dns-azure

# Create required directories
RUN mkdir -p /etc/letsencrypt /var/lib/letsencrypt

# Copy scripts and templates
COPY nginx.template.conf /etc/nginx/templates/default.conf.template
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 80 443

ENTRYPOINT ["/entrypoint.sh"]
