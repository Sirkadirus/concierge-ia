# Linux — Phase 1 Knowledge Base

**Mental model trained:** Files → Processes → Users → Services → Resources  
**Tickets covered:** #001-Ejemplo, #001-A, #001-B, #002-Ejemplo, #002-A, #002-B, #003-Ejemplo  
**Status:** Phase complete

---

## Core Mental Model

```
When something fails, ask in this order:
1. What FILE does this use?
2. What PROCESS executes it?
3. What USER runs it?
4. What SERVICE controls it?
5. What RESOURCE does it consume?
```

---

## 1. Permissions & Ownership

### The Rule: chown before chmod

```bash
# Wrong order — will produce "Operation not permitted"
chmod 755 /var/www/html/index.html   # fails if you don't own it

# Correct order
sudo chown jose:jose /var/www/html/index.html
chmod 755 /var/www/html/index.html
```

**Key insight:** `Operation not permitted` on `chmod` is a reliable signal of an **ownership problem**, not a permissions problem. The error message maps to the cause.

### Permission notation

```
rwxr-xr-x = 755
rw-r--r-- = 644
rwx------ = 700
```

| Symbol | Meaning |
|---|---|
| `r` | read (4) |
| `w` | write (2) |
| `x` | execute (1) |
| `-` | no permission (0) |

---

## 2. Services — systemctl

### The critical distinction: start vs enable

| Command | What it does | When to use |
|---|---|---|
| `systemctl start nginx` | Starts the service **now** | Fix an immediate outage |
| `systemctl enable nginx` | Starts service **on every boot** | Survive reboots |
| `systemctl restart nginx` | Stop + start | Apply config changes |
| `systemctl reload nginx` | Reload config without stopping | Zero-downtime config update |
| `systemctl status nginx` | Check current state | First thing to run |

**Key insight:** `start` and `enable` solve **different problems**. Always ask: "Do I need this fixed now, or do I need it to survive a reboot?" Usually the answer is both.

---

## 3. Logs — journalctl

```bash
# Last 50 lines for nginx
journalctl -u nginx -n 50 --no-pager

# Follow live (like tail -f)
journalctl -u nginx -f

# Since last boot
journalctl -u nginx -b

# All failed services
systemctl list-units --state=failed
```

**Key insight:** Always read logs **before** making changes. The log tells you what the system thinks went wrong. Running `journalctl` before any fix is non-negotiable.

---

## 4. Ports & Network Layer

```bash
# Show all listening ports with process names — most useful command
ss -tulnp

# Check if a specific port is in use
ss -tulnp | grep :80

# Test connectivity to a port
nc -vz localhost 80
```

### Error message → Layer mapping

| Error message | Layer | Meaning |
|---|---|---|
| `connection refused` | Layer 3/4 — Network/Port | Port closed or process not listening |
| `host not found` / `NXDOMAIN` | Layer 3 — DNS | DNS resolution failed |
| `connection timed out` | Layer 3 — Firewall/Routing | Packets blocked or dropped |
| `502 Bad Gateway` | Layer 4/5 — Service/App | Upstream service down |
| `403 Forbidden` | Layer 6 — Data/User | Permission denied by application |

**Key insight:** The error message is a diagnostic tool. Before running any command, the error message already points you toward the correct layer.

---

## 5. Nginx Configuration

```bash
# Test configuration syntax before reloading
nginx -t

# Edit config
sudo nano /etc/nginx/sites-available/default

# Repair a config with sed (example: fix wrong port)
sudo sed -i 's/listen 8080/listen 80/' /etc/nginx/sites-available/default

# Reload after fixing
sudo systemctl reload nginx
```

### Config file structure

```nginx
server {
    listen 80;
    server_name hostel-sol.local;

    location / {
        root /var/www/html;
        index index.html;
    }
}
```

---

## 6. DNS & /etc/hosts

```bash
# Add local domain (for development)
sudo nano /etc/hosts
# Add: 127.0.0.1    hostel-sol.local

# Verify DNS resolution
nslookup hostel-sol.local
dig hostel-sol.local

# Test HTTP response
curl -v http://hostel-sol.local
```

**Key insight:** `/etc/hosts` is checked before DNS. It's the fastest way to map a local domain without a real DNS server.

---

## 7. Process Management

```bash
# Find what process is using a port
ss -tulnp | grep :80

# Find process by name
ps aux | grep python3

# Kill a process gracefully (SIGTERM)
kill <PID>

# Kill forcefully (SIGKILL) — only if SIGTERM doesn't work
kill -9 <PID>
```

### The kill-is-not-enough rule

**Key insight:** Killing a process that was occupying a port does NOT automatically restart the service that needed that port. systemd remembers the failed state and requires an explicit `systemctl restart`.

```bash
# Wrong sequence
kill <PID>
# nginx is still in failed state — systemd hasn't restarted it

# Correct sequence
kill <PID>
sudo systemctl restart nginx
```

---

## 8. Key Distinctions Summary

| Concept A | Concept B | The difference |
|---|---|---|
| `chown` | `chmod` | Ownership vs permissions — chown first |
| `start` | `enable` | Fix now vs survive reboots |
| `kill` | `systemctl restart` | Remove blocker vs restart the service |
| `restart` | `reload` | Full stop/start vs hot config reload |
| `connection refused` | `timeout` | Port closed vs firewall blocking |

---

## 9. Diagnostic Flow (Senior Pattern)

```
Symptom received
      ↓
Read the error message → identify the layer
      ↓
Formulate hypotheses with probabilities
      ↓
Choose verification that tests multiple hypotheses simultaneously
      ↓
Execute → read evidence
      ↓
Interpret: what does this confirm/discard?
      ↓
Conclude with evidence, not assumptions
      ↓
Prevent: what alert would have caught this earlier?
```

---

*Phase 1 complete — advancing to Phase 2: Networking*
