#!/bin/bash
# backup-config.sh
# Concierge IA — Backup nginx configuration before changes

set -euo pipefail

BACKUP_DIR="$HOME/concierge-ia/infra/backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
NGINX_CONFIG="/etc/nginx/sites-available/default"

mkdir -p "$BACKUP_DIR"

echo "Backing up nginx config..."
cp "$NGINX_CONFIG" "$BACKUP_DIR/nginx-default-${TIMESTAMP}.conf"
echo "✓ Saved to: $BACKUP_DIR/nginx-default-${TIMESTAMP}.conf"
echo ""
echo "To restore: sudo cp $BACKUP_DIR/nginx-default-${TIMESTAMP}.conf $NGINX_CONFIG"
echo "Then: nginx -t && sudo systemctl reload nginx"
