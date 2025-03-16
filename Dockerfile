FROM nginx:latest

# Install required packages including snapd
RUN apt-get update && apt-get install -y \
    snapd \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Set up the snap environment
RUN mkdir -p /var/lib/snapd/snap && \
    mkdir -p /snap && \
    ln -s /var/lib/snapd/snap /snap

# Install Certbot and the DNS Azure plugin via snap
RUN snap install core && \
    snap install certbot --classic && \
    snap install certbot-dns-azure && \
    snap set certbot trust-plugin-with-root=ok && \
    snap connect certbot:plugin certbot-dns-azure

# Create required directories
RUN mkdir -p /etc/letsencrypt /var/lib/letsencrypt /etc/azure

# Copy scripts and templates
COPY nginx.template.conf /etc/nginx/templates/default.conf.template
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Add snap bin to PATH for entrypoint script
ENV PATH="/snap/bin:${PATH}"

EXPOSE 80 443

ENTRYPOINT ["/entrypoint.sh"]
