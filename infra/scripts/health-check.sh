#!/bin/bash
# health-check.sh
# Concierge IA — Infrastructure Health Check
# Trained in: Ticket #001 (permissions), #002 (services, ports)
# Mental model: Files → Processes → Users → Services → Resources

set -euo pipefail

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

DOMAIN="hostel-sol.local"
PORT=80
PASS=0
FAIL=0

echo "================================================"
echo " Concierge IA — Health Check"
echo " $(date)"
echo "================================================"
echo ""

# ── Layer 2: Sistema Operativo ──────────────────────
echo "[ Layer 2 — Sistema Operativo ]"

# Check disk space
DISK_USAGE=$(df -h / | awk 'NR==2 {print $5}' | tr -d '%')
if [ "$DISK_USAGE" -lt 85 ]; then
    echo -e "  ${GREEN}✓${NC} Disk usage: ${DISK_USAGE}% (threshold: 85%)"
    ((PASS++))
else
    echo -e "  ${RED}✗${NC} Disk usage CRITICAL: ${DISK_USAGE}% — clean up required"
    ((FAIL++))
fi

# Check file permissions on web root
if [ -r /var/www/html/index.html ]; then
    echo -e "  ${GREEN}✓${NC} Web root index.html is readable"
    ((PASS++))
else
    echo -e "  ${RED}✗${NC} Web root index.html NOT readable — check permissions (chown/chmod)"
    ((FAIL++))
fi

echo ""

# ── Layer 3: Network ────────────────────────────────
echo "[ Layer 3 — Network ]"

# Check DNS resolution
if nslookup "$DOMAIN" > /dev/null 2>&1; then
    echo -e "  ${GREEN}✓${NC} DNS resolves: $DOMAIN"
    ((PASS++))
else
    echo -e "  ${RED}✗${NC} DNS FAILED for $DOMAIN — check /etc/hosts"
    ((FAIL++))
fi

# Check what is listening on port 80
PORT_PROCESS=$(ss -tulnp | grep ":${PORT}" | awk '{print $7}' | grep -o '"[^"]*"' | head -1 || echo "nothing")
if echo "$PORT_PROCESS" | grep -q "nginx"; then
    echo -e "  ${GREEN}✓${NC} Port $PORT: nginx is listening"
    ((PASS++))
elif [ "$PORT_PROCESS" = "nothing" ] || [ -z "$PORT_PROCESS" ]; then
    echo -e "  ${RED}✗${NC} Port $PORT: NOTHING listening — nginx may be stopped or failed to bind"
    ((FAIL++))
else
    echo -e "  ${RED}✗${NC} Port $PORT occupied by: $PORT_PROCESS (not nginx) — port conflict"
    ((FAIL++))
fi

echo ""

# ── Layer 4: Services ───────────────────────────────
echo "[ Layer 4 — Services ]"

# Check nginx service state
NGINX_STATE=$(systemctl is-active nginx 2>/dev/null || echo "unknown")
if [ "$NGINX_STATE" = "active" ]; then
    echo -e "  ${GREEN}✓${NC} nginx.service: active (running)"
    ((PASS++))
else
    echo -e "  ${RED}✗${NC} nginx.service: $NGINX_STATE"
    ((FAIL++))
fi

# Check nginx is enabled (survives reboots)
NGINX_ENABLED=$(systemctl is-enabled nginx 2>/dev/null || echo "unknown")
if [ "$NGINX_ENABLED" = "enabled" ]; then
    echo -e "  ${GREEN}✓${NC} nginx.service: enabled (survives reboots)"
    ((PASS++))
else
    echo -e "  ${YELLOW}⚠${NC} nginx.service: $NGINX_ENABLED — will NOT start on reboot"
    ((FAIL++))
fi

# Check nginx config syntax
if nginx -t > /dev/null 2>&1; then
    echo -e "  ${GREEN}✓${NC} nginx config: syntax OK"
    ((PASS++))
else
    echo -e "  ${RED}✗${NC} nginx config: SYNTAX ERROR — run 'nginx -t' for details"
    ((FAIL++))
fi

echo ""

# ── Layer 5: Application ────────────────────────────
echo "[ Layer 5 — Application ]"

# HTTP response check
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "http://$DOMAIN" 2>/dev/null || echo "000")
if [ "$HTTP_CODE" = "200" ]; then
    echo -e "  ${GREEN}✓${NC} HTTP response: 200 OK from http://$DOMAIN"
    ((PASS++))
elif [ "$HTTP_CODE" = "000" ]; then
    echo -e "  ${RED}✗${NC} HTTP: no response (connection refused or timeout)"
    ((FAIL++))
else
    echo -e "  ${YELLOW}⚠${NC} HTTP response: $HTTP_CODE from http://$DOMAIN"
    ((FAIL++))
fi

echo ""

# ── Summary ─────────────────────────────────────────
echo "================================================"
echo " Results: ${PASS} passed / ${FAIL} failed"
if [ "$FAIL" -eq 0 ]; then
    echo -e " Status: ${GREEN}ALL SYSTEMS HEALTHY${NC}"
else
    echo -e " Status: ${RED}$FAIL CHECK(S) FAILED — investigate${NC}"
fi
echo "================================================"

exit $FAIL
