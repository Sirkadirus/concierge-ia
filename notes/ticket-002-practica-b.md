# Ticket #002-Práctica B — Port 80 Conflict

**Date:** June 2026  
**Reporter:** Sebastián (Tech Lead)  
**Type:** Independent Practice  
**Mental Model Trained:** Files → Processes → Users → Services → Resources  
**Difficulty Level:** 2 (two layers: Network + Services)  
**Status:** Complete  
**Score:** 24/30

---

## Symptom / Scenario

"Nginx shows `active (running)` in systemctl status, but users receive `connection refused` on port 80."

## Layer Identified (Before any command)

**Primary:** Layer 3 — Network (port 80 not reachable despite service running)  
**Secondary:** Layer 4 — Services (service says running but isn't serving)  

**Critical reasoning:** This is a TWO-LAYER problem. The service layer (systemd) says "running". The network layer says "connection refused." These contradict each other. The contradiction is the clue: something is wrong between what systemd thinks and what the network sees. Possible causes: wrong port, another process occupying port 80, or Nginx bound only to a specific interface.

## Hypotheses

| Hypothesis | Description | Probability |
|---|---|---|
| A | Firewall (ufw/iptables) blocking port 80 | 50% |
| B | Another process occupying port 80 — Nginx can't bind to it | 40% |
| C | Nginx configured to listen only on localhost (127.0.0.1:80) | 10% |

## Verification Plan

**Command chosen:** `ss -tulnp`  
**Why this command is senior-level thinking:** It simultaneously answers:
- Is anything listening on port 80? (tests hypothesis A and B)
- What process is listening? (identifies the occupier if B is true)
- Is Nginx bound to 0.0.0.0 or only 127.0.0.1? (tests hypothesis C)

One command, three hypotheses tested. This is the optimal choice.

**Cost:** Low | **Information value:** Very High

## Execution & Evidence

```bash
# Step 1: Check what's listening on port 80
ss -tulnp | grep :80
# Output: tcp LISTEN 0 128 0.0.0.0:80 0.0.0.0:* users:(("python3",pid=1847,fd=3))

# Evidence: python3 is occupying port 80, NOT Nginx
# Hypothesis B confirmed (40% → 100%)
# Hypothesis A discarded (firewall would show nothing listening, not python3)
# Hypothesis C discarded (the issue is occupancy, not binding)

# Step 2: Remove the blocker
kill 1847

# Step 3: Restart Nginx (CRITICAL — not just start)
sudo systemctl restart nginx

# Step 4: Verify
ss -tulnp | grep :80
# Output: tcp LISTEN 0 511 0.0.0.0:80 0.0.0.0:* users:(("nginx",pid=2134,fd=6))

curl -I http://hostel-sol.local
# Output: HTTP/1.1 200 OK ✓
```

## Evidence Interpretation

- `python3` on port 80: Nginx tried to bind to port 80 on startup but it was already taken → Nginx "started" according to systemd but couldn't bind → service in degraded state
- After `kill`: port 80 freed
- **KEY INSIGHT:** `kill` alone is NOT sufficient. systemd remembered the failed bind state. Nginx needs `systemctl restart` to reattempt port binding.
- After `systemctl restart`: Nginx successfully binds → serving traffic

## Conclusion

**Root cause:** Python3 process was occupying port 80. Nginx could not bind to the port and entered a degraded state while systemd still reported it as "active (running)."  
**Layers affected:** Layer 3 (Network — port occupied) + Layer 4 (Services — degraded state)  
**Fix sequence:** `ss -tulnp` → identify occupier → `kill PID` → `systemctl restart nginx`  
**Evidence:** ss output showed python3 on port 80 → after kill and restart → nginx on port 80 → HTTP 200

## THE CRITICAL INSIGHT — Most Important in This Ticket

```
Kill alone is NOT enough.

Sequence that FAILS:
kill <PID>
# Port is free, but Nginx is still in failed/degraded state
# systemd does not automatically restart it

Sequence that WORKS:
kill <PID>
systemctl restart nginx
# Port is free AND Nginx reattempts bind AND enters active state
```

systemd maintains state. A service that failed to bind once will not automatically retry just because the port becomes available. You must explicitly restart it.

## Post-Mortem

**What signals did I miss?** The contradiction: "active (running)" + "connection refused" is the diagnostic clue itself. When systemd and the network contradict each other, the answer lives at the intersection.  
**What confused me?** Initially wanted to restart Nginx without checking what was on the port first. That would have failed because Nginx still couldn't bind.  
**What did I learn?** `ss -tulnp` is the first command when you have "service running but port unreachable." Not `systemctl restart` — diagnose first.  
**What alert would have helped?** A monitoring check on port 80 availability (separate from systemd status) would have caught this immediately.  
**How would I find this faster next time?** `ss -tulnp | grep :80` before any service restart. Two seconds to find the occupier.

---

## Scoring

| Area | Score | Notes |
|---|---|---|
| Layer identification | 4/5 | Identified both layers but weighting needed refinement |
| Hypotheses | 4/5 | Good set, probability weighting slightly off |
| Prioritization | 4/5 | ss -tulnp was correct choice |
| Verification | 4/5 | Good command selection |
| Evidence interpretation | 4/5 | Understood python3 occupancy |
| Conclusion | 4/5 | Almost complete — kill-is-not-enough insight came during resolution |
| **Total** | **24/30** | |

**Gap noted:** The kill-restart distinction was not fully anticipated in the hypothesis phase. Growth area: when hypothesizing about port conflicts, always include "what happens to the service after the port is freed?"

**Consecutive correct diagnoses counter:** Reset — score below threshold for advancement
