FROM nginx:latest

# Install required packages
RUN apt-get update && apt-get install -y \
    certbot \
    python3-pip \
    python3-certbot-nginx \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Install certbot-dns-azure plugin
RUN pip3 install certbot-dns-azure

# Create required directories
RUN mkdir -p /etc/letsencrypt /var/lib/letsencrypt /etc/azure

# Copy scripts and templates
COPY nginx.template.conf /etc/nginx/templates/default.conf.template
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 80 443

ENTRYPOINT ["/entrypoint.sh"]
