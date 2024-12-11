# Nginx Multi-Domain SSL Container

A single container solution that automatically manages SSL certificates for multiple domains using Let's Encrypt and serves them through Nginx.

## Features

- Automatic SSL certificate acquisition and renewal for multiple domains
- Single certificate for all domains (using Subject Alternative Names)
- Strong SSL configuration with modern security settings
- Automatic HTTP to HTTPS redirect
- Minimal dependencies using nginx:alpine as base
- Persistent certificate storage

## Quick Start

### Basic Usage

```bash
# Build the image
docker build -t nginx-certbot .

# Run the container with basic configuration
docker run -d \
    --name nginx-certbot \
    -e CERTBOT_EMAIL=your@email.com \
    -e DOMAINS="example.com,sub1.example.com,sub2.example.com" \
    -p 80:80 \
    -p 443:443 \
    -v letsencrypt:/etc/letsencrypt \
    nginx-certbot
```

### Production Usage

```bash
# Create required directories
mkdir -p /path/to/www
mkdir -p /path/to/logs

# Run with full configuration
docker run -d \
    --name nginx-certbot \
    -e CERTBOT_EMAIL=your@email.com \
    -e DOMAINS="example.com,sub1.example.com,sub2.example.com" \
    -p 80:80 \
    -p 443:443 \
    -v letsencrypt:/etc/letsencrypt \
    -v /path/to/www:/usr/share/nginx/html:ro \
    -v /path/to/logs:/var/log/nginx \
    --restart unless-stopped \
    nginx-certbot
```

### Directory Structure

Your local setup should look like this:
```
/path/to/www/
├── index.html
├── assets/
│   ├── css/
│   ├── js/
│   └── images/
└── ...

/path/to/logs/
├── access.log
└── error.log
```

## Requirements

- Docker
- Domains pointing to your server (correct DNS A records)
- Open ports 80 and 443
- Valid email address for Let's Encrypt notifications

## Environment Variables

- `CERTBOT_EMAIL`: Email address for Let's Encrypt registration and notifications
- `DOMAINS`: Comma-separated list of domains to obtain certificates for

## Volumes

| Container Path | Description |
|----------------|-------------|
| `/etc/letsencrypt` | Certificate storage |
| `/usr/share/nginx/html` | Web root directory |
| `/var/log/nginx` | Nginx log files |

## Certificate Renewal

The container needs to be restarted periodically to check for certificate renewals. You can:
1. Set up a cron job to restart the container weekly:
```bash
0 0 * * 0 docker restart nginx-certbot
```
2. Use Docker's `--restart` policy with external container restarts
3. Use Kubernetes CronJob if running in K8s
4. Use systemd timer if running with systemd

## Notes

- Let's Encrypt has a limit of 100 domains per certificate
- Port 80 needs to be available during certificate issuance/renewal
- All domains must point to your server's IP address
- Certificates are stored in a Docker volume for persistence
- Web files should be readable by nginx (uid 101)

## Security

The configuration includes:
- Modern SSL protocols (TLSv1.2, TLSv1.3)
- Strong cipher suite
- HTTP/2 support
- HSTS enabled
- Session security settings

## File Permissions

If you're mounting local directories, ensure proper permissions:
```bash
# Set ownership for web files
sudo chown -R 101:101 /path/to/www

# Set permissions for logs
sudo chown -R 101:101 /path/to/logs
sudo chmod 755 /path/to/logs
```

## License

MIT