# Ticket #002-Ejemplo — Broken Nginx Configuration

**Date:** June 2026  
**Reporter:** Sebastián (Tech Lead)  
**Type:** Guided Example  
**Mental Model Trained:** Files → Processes → Users → Services → Resources  
**Difficulty Level:** 1-2 (service layer + configuration)  
**Status:** Complete

---

## Symptom / Scenario

"Nginx service is running but returns errors. Users cannot access the site."

## Layer Identified (Before any command)

**Primary:** Layer 4 — Services (Nginx configuration error)  
**Secondary:** Layer 5 — Application/Config  

**Reasoning:** "Service is running" eliminates the obvious Layer 4 failure (service stopped). When a service is running but not working correctly, the next suspect is **configuration**. A misconfiguration is not Layer 5 (application code) — it's a special case that sits between Layer 4 and 5.

## Hypotheses

| Hypothesis | Description | Probability |
|---|---|---|
| A | Nginx configuration file has syntax error | 55% |
| B | Nginx is listening on wrong port | 30% |
| C | Document root directory doesn't exist or has wrong path | 15% |

## Verification Plan

**Step 1 — Read the logs first**  
Command: `journalctl -u nginx -n 50 --no-pager`  
Why: Logs will tell us what Nginx thinks is wrong. Cost: Low | Value: Very High

**Step 2 — Test configuration syntax**  
Command: `nginx -t`  
Why: Built-in tool that validates config before applying it. Cost: Low | Value: High

## Execution & Evidence

```bash
# Step 1: Read logs
journalctl -u nginx -n 50 --no-pager
# Output shows: "invalid parameter 'listen 8080 default_server'" type error

# Step 2: Confirm with nginx -t
nginx -t
# Output: nginx: [emerg] invalid parameter... in /etc/nginx/sites-available/default:4

# Step 3: View the problematic file
cat /etc/nginx/sites-available/default
# Found: wrong port configuration

# Step 4: Fix with sed (targeted, surgical change)
sudo sed -i 's/listen 8080/listen 80/' /etc/nginx/sites-available/default

# Step 5: Verify fix
nginx -t
# Output: nginx: configuration file /etc/nginx/nginx.conf test is successful

# Step 6: Reload (not restart — zero downtime)
sudo systemctl reload nginx

# Step 7: Verify service
systemctl status nginx
curl -v http://hostel-sol.local
```

## Evidence Interpretation

- `journalctl` showed exact line and error type → config syntax problem confirmed
- `nginx -t` confirmed the exact location of the error
- `sed -i` applied a surgical fix without manual file editing risk
- `nginx -t` after fix confirmed syntax is now valid
- `reload` vs `restart`: reload applies new config without dropping connections

## Conclusion

**Root cause:** Nginx configuration file had wrong port (8080 instead of 80).  
**Layer:** Configuration (between Layer 4 Services and Layer 5 Application)  
**Diagnostic tool:** `journalctl` → `nginx -t` → `sed` → `nginx -t` → `reload`  
**Key tool introduced:** `nginx -t` — always run this before reloading Nginx

## Key Insights Extracted

1. **journalctl before everything else** — logs tell you what the system thinks is wrong
2. **nginx -t is mandatory** — never reload Nginx without running `-t` first. A bad config can take down the service.
3. **reload vs restart** — `reload` applies new config gracefully. `restart` drops all connections. Use `reload` whenever possible.
4. **sed for surgical fixes** — `sed -i 's/old/new/'` is safer than opening a file in an editor under pressure

## Post-Mortem

**What signals did I missed?** The service status "active (running)" misled — a running service with bad config is a Layer 4/Config problem, not a Layer 3 or Layer 5 problem.  
**What confused me?** The instinct to restart instead of reload.  
**What did I learn?** `nginx -t` is a pre-flight check. Never skip it.  
**How would I find this faster next time?** `journalctl` → `nginx -t` is a two-command diagnostic sequence that catches 80% of Nginx issues in under 30 seconds.

---

## Scoring

| Area | Score | Notes |
|---|---|---|
| Layer identification | 4/5 | Correct layer, config nuance needed |
| Hypotheses | 5/5 | Good range |
| Prioritization | 5/5 | Logs first — correct |
| Verification | 5/5 | nginx -t is the right tool |
| Evidence interpretation | 5/5 | Read the output correctly |
| Conclusion | 5/5 | Evidence-backed |
| **Total** | **29/30** | |

**Consecutive correct diagnoses counter:** 3/5
