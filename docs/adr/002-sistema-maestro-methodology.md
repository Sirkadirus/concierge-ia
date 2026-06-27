# ADR-002: Sistema Maestro de Evaluación por Dominio de Modelos Mentales

**Date:** June 2026  
**Status:** Active — governs all learning and ticket work  
**Source:** Sistema_Maestro_de_Evaluación_por_Dominio_de_Modelos_Mentales_final.docx

---

## Context

Standard DevOps courses teach commands and tools. This project requires building **operational mental models** — the ability to reason about unknown systems before touching the terminal.

## Decision

All ticket work follows the **Sistema Maestro** methodology. Progress is never measured by tickets completed. Progress is measured exclusively by demonstrated operational reasoning quality.

## The Mandatory Diagnostic Flow

Every incident must follow this exact sequence:

```
Step 1 — Layer Identification (BEFORE any command)
Step 2 — Hypothesis formulation with probabilities
Step 3 — Verification plan (cost vs information value)
Step 4 — Execution
Step 5 — Evidence interpretation
Step 6 — Conclusion backed by evidence
Post-Mortem — What would have prevented this?
```

## Advancement Criteria

A topic is only considered mastered when I can:

1. Identify the correct layer of the problem
2. Formulate multiple reasonable hypotheses
3. Prioritize hypotheses by probability
4. Explain what evidence I expect to find
5. Design appropriate verifications
6. Correctly interpret the evidence obtained
7. Reach a conclusion backed by evidence
8. Explain how to prevent the problem
9. Explain why discarded hypotheses were incorrect

**Rule:** 5 consecutive correct diagnoses required to advance maturity level. Counter resets to zero on failure.

## Maturity Levels

| Level | Description |
|---|---|
| 0 | Executing commands without understanding |
| 1 | Correctly identifying the layer |
| 2 | Formulating reasonable hypotheses |
| 3 | Designing effective verifications |
| 4 | Diagnosing correctly and consistently |
| 5 | Diagnosing complex multi-failure systems |

## Scoring per Ticket

| Area | Score |
|---|---|
| Layer identification | 0-5 |
| Hypotheses | 0-5 |
| Prioritization | 0-5 |
| Verification | 0-5 |
| Evidence interpretation | 0-5 |
| Conclusion | 0-5 |
| **Total** | **0-30** |

---

*This ADR is the operating constitution of the entire project.*
