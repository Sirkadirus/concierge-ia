#!/bin/bash
# deploy.sh
# Concierge IA — Deployment Script (Phase 1: Local)
# Trained in: Ticket #002 (nginx -t before reload, reload vs restart)

set -euo pipefail

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

echo "================================================"
echo " Concierge IA — Deploy (Phase 1 Local)"
echo " $(date)"
echo "================================================"

# Step 1: Validate nginx config BEFORE applying anything
echo ""
echo "[1/4] Validating nginx configuration..."
if nginx -t 2>/dev/null; then
    echo -e "  ${GREEN}✓${NC} Config syntax OK"
else
    echo -e "  ${RED}✗${NC} Config syntax ERROR — aborting deploy"
    echo "  Run 'nginx -t' to see the exact error"
    exit 1
fi

# Step 2: Check port 80 is available or owned by nginx
echo ""
echo "[2/4] Checking port 80..."
PORT_OWNER=$(ss -tulnp | grep ':80' | awk '{print $7}' || echo "")
if echo "$PORT_OWNER" | grep -q "nginx" || [ -z "$PORT_OWNER" ]; then
    echo -e "  ${GREEN}✓${NC} Port 80 clear"
else
    echo -e "  ${RED}✗${NC} Port 80 occupied by: $PORT_OWNER"
    echo "  Find the PID with: ss -tulnp | grep :80"
    echo "  Then: kill <PID> && systemctl restart nginx"
    exit 1
fi

# Step 3: Reload nginx (graceful — no connection drops)
echo ""
echo "[3/4] Reloading nginx (graceful reload)..."
sudo systemctl reload nginx
echo -e "  ${GREEN}✓${NC} nginx reloaded"

# Step 4: Verify
echo ""
echo "[4/4] Verifying..."
sleep 1
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://hostel-sol.local || echo "000")
if [ "$HTTP_CODE" = "200" ]; then
    echo -e "  ${GREEN}✓${NC} HTTP 200 OK — deploy successful"
else
    echo -e "  ${RED}✗${NC} HTTP $HTTP_CODE — check logs: journalctl -u nginx -n 20"
    exit 1
fi

echo ""
echo "================================================"
echo -e " ${GREEN}Deploy complete${NC}"
echo "================================================"
