# Ticket #001-Práctica A — Permissions and File Location (Independent Diagnosis)

**Date:** June 2026  
**Reporter:** Sebastián (Tech Lead)  
**Type:** Independent Practice  
**Mental Model Trained:** Files → Processes → Users → Services → Resources  
**Difficulty Level:** 1 (single layer)  
**Status:** Complete

---

## Symptom / Scenario

"The configuration file for the hostel application exists but the service cannot read it. Access is being denied."

## Layer Identified (Before any command)

**Primary:** Sistema Operativo — Permissions/Ownership  
**Reasoning:** "Access denied" on a file that exists = permissions layer. The service layer would show a different error (service not running). The file layer would show "file not found."

**This is how the error message maps to the layer:**
- `file not found` → Layer 2 (SO) — file path/existence
- `permission denied` → Layer 2 (SO) — permissions/ownership  
- `connection refused` → Layer 3 (Network) — port/service
- `service not found` → Layer 4 (Services)

## Hypotheses

| Hypothesis | Description | Probability |
|---|---|---|
| A | File owned by wrong user — service user cannot read it | 55% |
| B | File permissions too restrictive (e.g. 600 when 644 needed) | 35% |
| C | File is in correct location but wrong directory permissions block traversal | 10% |

## Verification Plan

**Command chosen:** `ls -la <path_to_config_file>`  
**Why:** Shows ownership AND permissions in one command. Tests hypotheses A and B simultaneously.  
**Evidence expected:** Either wrong owner (hypothesis A) or wrong permission bits (hypothesis B)  
**Layer:** SO — Permissions  
**Cost:** Low | **Information value:** High (eliminates two hypotheses at once)

## Execution & Evidence

```bash
ls -la /etc/hostel-app/config.yml
# Output: -rw------- 1 root root 512 Jun 2026 config.yml

# Diagnosis: root owns it, permissions block all other users
# The service runs as a non-root user — it cannot read this file

# Fix:
sudo chown appuser:appuser /etc/hostel-app/config.yml
chmod 640 /etc/hostel-app/config.yml

# Verify:
ls -la /etc/hostel-app/config.yml
# Output: -rw-r----- 1 appuser appuser 512 Jun 2026 config.yml
```

## Evidence Interpretation

- `rw-------` + `root root` → Hypothesis A confirmed. The service user has zero access.
- `chown` transferred ownership. `chmod 640` gives owner read/write, group read-only.
- Hypothesis B (wrong permission bits) was also true, but the root cause was hypothesis A.

## Conclusion

**Root cause:** File owned by root, service runs as non-root user.  
**Layer:** Sistema Operativo — Ownership  
**Primary fix:** `chown` to correct service user  
**Secondary fix:** `chmod` to appropriate bits  
**Key distinction:** The ownership problem (A) caused the permissions problem (B). Fixing ownership first reveals whether chmod is even necessary.

## Key Insight Extracted

When you see "permission denied", always check **who owns the file** before checking what the permissions are. Ownership is the prerequisite.

## Post-Mortem

**What signals did I miss?** Nothing — the error message pointed directly to the SO layer.  
**What confused me?** Initially wanted to jump to chmod without checking chown.  
**What did I learn?** The symptom ("access denied") is not the same as the cause (wrong owner). Read ownership before reading permission bits.  
**How would I find this faster next time?** `ls -la` is always the first command when "access denied" appears.

---

## Scoring

| Area | Score | Notes |
|---|---|---|
| Layer identification | 5/5 | Correct, with reasoning |
| Hypotheses | 5/5 | Covered all realistic cases |
| Prioritization | 5/5 | A before B — correct |
| Verification | 5/5 | ls -la tests both hypotheses |
| Evidence interpretation | 4/5 | Good, could be more precise |
| Conclusion | 5/5 | Evidence-backed |
| **Total** | **29/30** | |

**Consecutive correct diagnoses counter:** 1/5
