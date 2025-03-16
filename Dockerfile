FROM nginx:latest

# Install required packages
RUN apt-get update && apt-get install -y \
    certbot \
    python3-certbot \
    python3-pip \
    python3-setuptools \
    python3-dev \
    python3-venv \
    gcc \
    libffi-dev \
    libssl-dev \
    && rm -rf /var/lib/apt/lists/*

# Create virtual environment and install plugin
RUN python3 -m venv /opt/certbot-venv && \
    /opt/certbot-venv/bin/pip install --upgrade pip && \
    /opt/certbot-venv/bin/pip install certbot-dns-azure

# Create required directories
RUN mkdir -p /etc/letsencrypt /var/lib/letsencrypt /etc/azure

# Copy scripts and templates
COPY nginx.template.conf /etc/nginx/templates/default.conf.template
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 80 443

ENTRYPOINT ["/entrypoint.sh"]
