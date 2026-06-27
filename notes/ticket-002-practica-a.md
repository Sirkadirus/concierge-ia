# Ticket #002-Práctica A — Stopped Nginx Service

**Date:** June 2026  
**Reporter:** Sebastián (Tech Lead)  
**Type:** Independent Practice  
**Mental Model Trained:** Files → Processes → Users → Services → Resources  
**Difficulty Level:** 1 (single layer — services)  
**Status:** Complete

---

## Symptom / Scenario

"The hostel website is completely unreachable. Users get no response at all — not an error page, just nothing."

## Layer Identified (Before any command)

**Primary:** Layer 4 — Services  
**Reasoning:** "No response at all" (vs "error page") = the service isn't responding. An error page means something IS running. Complete silence means the service is either stopped or not listening.

**Error message → Layer mapping applied:**
- "Connection refused" → Port is closed = service not listening = Layer 3/4
- "No response / timeout" → Service stopped or firewall = Layer 3/4
- "Error page (404/500)" → Service running but returning error = Layer 5

## Hypotheses

| Hypothesis | Description | Probability |
|---|---|---|
| A | Nginx service is stopped | 70% |
| B | Nginx failed to start due to config error | 20% |
| C | Port 80 blocked by firewall | 10% |

## Verification Plan

**Command chosen:** `systemctl status nginx`  
**Why:** Single command reveals: is the service running? Did it fail? What was the last error?  
**Evidence expected:** Service in `inactive (dead)` or `failed` state  
**Layer:** Services  
**Cost:** Low | **Information value:** Very High  

This command tests hypothesis A (stopped) and gives clues for hypothesis B (failed state).

## Execution & Evidence

```bash
systemctl status nginx
# Output: ● nginx.service - A high performance web server
#    Loaded: loaded (/lib/systemd/system/nginx.service; enabled)
#    Active: inactive (dead) since...

# Confirmed: Nginx is stopped. Not failed — just stopped.

# Fix for NOW (hypothesis A confirmed):
sudo systemctl start nginx

# Verify it started:
systemctl status nginx
# Output: Active: active (running)

# Critical follow-up question: Will it survive a reboot?
# Check if enabled:
systemctl is-enabled nginx
# Output: enabled ✓  (already set to start on boot)

# If it had shown "disabled":
# sudo systemctl enable nginx
```

## Evidence Interpretation

- `inactive (dead)` state: Service was stopped, not crashed. No config errors.
- `enabled` in Loaded line: Service IS configured to start on boot — it was manually stopped or stopped due to a one-time event.
- Hypothesis B (config error) discarded — a config error would show `failed` state with error logs.
- Hypothesis C (firewall) discarded — the service wasn't even running, firewall is irrelevant here.

## Conclusion

**Root cause:** Nginx service was stopped.  
**Layer:** Layer 4 — Services  
**Fix:** `systemctl start nginx` (immediate) + verify `enable` status (survive reboots)  
**Evidence:** `systemctl status` showed `inactive (dead)` → `start` → confirmed `active (running)`

## THE CRITICAL DISTINCTION LEARNED

```
systemctl start nginx   = Fix the problem RIGHT NOW
systemctl enable nginx  = Fix the problem AFTER EVERY REBOOT

These are two completely separate concerns.
A service can be:
- Started but NOT enabled → runs now, dies on reboot
- Enabled but NOT started → will run after reboot, not running now
- Both started AND enabled → running now + survives reboots ✓
```

**In production, you almost always need both.**

## Post-Mortem

**What signals did I miss?** "No response at all" was the key — this eliminates application-layer errors immediately.  
**What confused me?** The difference between `enabled` (boot behavior) and `active` (current state).  
**What did I learn?** `systemctl status` gives you both in one output. Read both the `Active:` line AND the `Loaded:` line.  
**How would I find this faster next time?** The moment the site is unreachable: `systemctl status nginx` before anything else. Five seconds to diagnosis.

---

## Scoring

| Area | Score | Notes |
|---|---|---|
| Layer identification | 5/5 | Correct reasoning from symptom |
| Hypotheses | 5/5 | Covered stopped, failed, and firewall |
| Prioritization | 5/5 | A at 70% — correct |
| Verification | 5/5 | systemctl status was optimal |
| Evidence interpretation | 5/5 | Understood inactive vs failed distinction |
| Conclusion | 5/5 | Both start AND enable checked |
| **Total** | **30/30** | |

**Consecutive correct diagnoses counter:** 4/5
