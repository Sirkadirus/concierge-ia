# Ticket #001-Práctica B — Ownership Conflict

**Date:** June 2026  
**Reporter:** Sebastián (Tech Lead)  
**Type:** Independent Practice  
**Mental Model Trained:** Files → Processes → Users → Services → Resources  
**Difficulty Level:** 1 (single layer)  
**Status:** Complete

---

## Symptom / Scenario

"Running `chmod` on a configuration file returns: `chmod: changing permissions of 'config.yml': Operation not permitted`"

## Layer Identified (Before any command)

**Primary:** Sistema Operativo — Ownership  
**Critical reasoning:** This is a specific, known error message. `Operation not permitted` on `chmod` is a signature error. It does NOT mean the permissions are wrong. It means you don't OWN the file. You cannot change permissions on a file you don't own, regardless of what permissions it has.

**The error message is a direct diagnostic tool:**
- `chmod: Operation not permitted` → You are not the owner → `chown` is the fix, not `chmod`

## Hypotheses

| Hypothesis | Description | Probability |
|---|---|---|
| A | File is owned by root or another user — current user cannot chmod it | 90% |
| B | Current user lacks sudo privileges | 8% |
| C | File is on a read-only filesystem | 2% |

## Verification Plan

**Command chosen:** `ls -la config.yml`  
**Why:** Will immediately show who owns the file. If it's root, hypothesis A is confirmed.  
**Evidence expected:** `root root` in the ownership column  
**Layer:** SO — Ownership  
**Cost:** Low | **Information value:** Very High

## Execution & Evidence

```bash
ls -la config.yml
# Output: -rw-r--r-- 1 root root 256 Jun 2026 config.yml

# Confirmed: root owns it. Current user (jose) cannot chmod it.

# Fix step 1: transfer ownership
sudo chown jose:jose config.yml

# Fix step 2: now chmod works
chmod 644 config.yml

# Verify:
ls -la config.yml
# Output: -rw-r--r-- 1 jose jose 256 Jun 2026 config.yml
```

## Evidence Interpretation

- `root root` in ownership → Hypothesis A confirmed at 90%
- After `chown jose:jose`: jose now owns the file
- `chmod` now executes without error — proof that ownership was the blocker
- Hypotheses B and C discarded: sudo was available, filesystem is writable

## Conclusion

**Root cause:** File owned by root. Non-root user cannot modify permissions on files they don't own.  
**Layer:** Sistema Operativo — Ownership  
**Fix sequence:** `chown` first → `chmod` second. This order is non-negotiable.  
**Evidence:** `ls -la` showed `root root` → `chown` → `chmod` succeeded

## KEY INSIGHT — Most Important in Phase 1

```
"Operation not permitted" on chmod = OWNERSHIP PROBLEM
The fix is chown, not chmod.
chown always before chmod.
```

This is a pattern that appears constantly in production. A junior engineer who sees this error and knows to immediately check `ls -la` for ownership — without having to think about it — is demonstrating senior-pattern recognition.

## Post-Mortem

**What signals did I miss?** Nothing — the error message was unambiguous once you know what it means.  
**What confused me?** Initially the instinct was to add `sudo` to the `chmod` command. That's the wrong fix — it treats the symptom, not the cause.  
**What did I learn?** Error messages are diagnostic tools. `chmod: Operation not permitted` ≠ "try with sudo chmod". It means "you don't own this."  
**How would I find this faster next time?** The moment I see this error, I run `ls -la` and look at the third and fourth columns (owner and group). Zero thinking required.

---

## Scoring

| Area | Score | Notes |
|---|---|---|
| Layer identification | 5/5 | Identified from error message alone |
| Hypotheses | 5/5 | Correct weighting — A at 90% |
| Prioritization | 5/5 | ls -la was correct first move |
| Verification | 5/5 | Single command confirmed hypothesis |
| Evidence interpretation | 5/5 | root root → chown → chmod chain understood |
| Conclusion | 5/5 | Evidence-backed, prevention included |
| **Total** | **30/30** | |

**Consecutive correct diagnoses counter:** 2/5
