# Ticket #001-Ejemplo — Navigation, File Creation, Permissions

**Date:** June 2026  
**Reporter:** Sebastián (Tech Lead)  
**Type:** Guided Example  
**Mental Model Trained:** Files → Processes → Users → Services → Resources  
**Difficulty Level:** 1 (single layer)  
**Status:** Complete

---

## Symptom / Scenario

The web server's HTML file is not accessible. The file exists but the web server cannot read it.

## Layer Identified

**Primary:** Sistema Operativo — Permissions  
**Secondary:** None at this level

## Hypotheses

| Hypothesis | Description | Probability |
|---|---|---|
| A | File has incorrect permissions (not readable by web server user) | 60% |
| B | File is in the wrong directory | 30% |
| C | File does not exist | 10% |

## Verification Plan

**Command chosen:** `ls -la /var/www/html/`  
**Why:** Shows file existence, permissions, and ownership in one command  
**Evidence expected:** File exists with permissions that block read access  
**Layer being validated:** SO — Permissions  
**Cost:** Low | **Information value:** High

## Execution & Evidence

```bash
# Navigate to web root
cd /var/www/html

# Check file and permissions
ls -la
# Output: -rw------- 1 root root 1234 Jun 2026 index.html
# Problem visible: root owns it, permissions block others from reading

# Fix ownership first (chown before chmod — rule)
sudo chown jose:jose index.html

# Then set permissions
chmod 644 index.html

# Verify
ls -la index.html
# Output: -rw-r--r-- 1 jose jose 1234 Jun 2026 index.html
```

## Evidence Interpretation

- `rw-------` means only the owner can read/write. The web server (www-data) cannot read it.
- After `chown`: ownership transferred to jose
- After `chmod 644`: owner can read/write, everyone else can read
- Web server can now serve the file

## Conclusion

**Root cause:** File owned by root with permissions blocking all other users from reading.  
**Layer:** Sistema Operativo — Permissions  
**Fix:** chown to correct user → chmod to correct permissions  
**Evidence:** ls -la confirmed the state before and after

## Key Insight Extracted

`Operation not permitted` on `chmod` = ownership problem, not a permissions problem. You cannot change permissions on a file you don't own. Always `chown` first.

## Prevention

**Alert that would have caught this:** A health check script that verifies file permissions on deployment. → See `infra/scripts/health-check.sh`

## Post-Mortem

**What signals did I miss?** The error message itself — "permission denied" already pointed to the SO layer.  
**What confused me?** The difference between `chown` (who owns it) and `chmod` (what they can do with it).  
**What did I learn?** These are two separate concerns. Ownership first, then permissions.  
**How would I find this faster next time?** Read the error message → identify the layer → go straight to `ls -la` before anything else.

---

## Scoring

| Area | Score | Notes |
|---|---|---|
| Layer identification | 5/5 | Correctly identified SO layer |
| Hypotheses | 4/5 | Good range, missing edge cases |
| Prioritization | 4/5 | Reasonable ordering |
| Verification | 5/5 | ls -la was correct first command |
| Evidence interpretation | 4/5 | Understood the output |
| Conclusion | 5/5 | Clear, evidence-backed |
| **Total** | **27/30** | |

**Maturity level after this ticket:** 1 → working toward 2
