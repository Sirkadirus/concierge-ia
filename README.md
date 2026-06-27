# Concierge IA

**AI-powered hostel concierge system — DevOps learning portfolio**

This repository serves two purposes simultaneously:
1. A real product being built (WhatsApp + Web MVP for hostels)
2. A verifiable DevOps/Cloud engineering portfolio

---

## Project Architecture (Evolutionary)

```
Phase 1 (Current): Usuario → Nginx → Local Server
Phase 2 (Weeks 5-8): Usuario → Route53 → CloudFront → ALB → EC2 → Docker → PostgreSQL
Phase 3 (Weeks 9-16): Full IaC with Terraform + GitHub Actions CI/CD
Phase 4 (Weeks 17-24): FastAPI + RAG + Claude API + WhatsApp
```

---

## Repository Structure

```
concierge-ia/
├── docs/               # Permanent knowledge base + architecture decisions
│   ├── adr/            # Architecture Decision Records
│   └── 01-linux.md     # Linux Phase 1 knowledge base
├── notes/              # Operational diary — one file per ticket
├── infra/
│   └── scripts/        # Bash automation scripts
├── .env.example
├── .gitignore
└── README.md
```

---

## Learning Methodology

This project follows the **Sistema Maestro de Evaluación por Dominio de Modelos Mentales**:

- Progress is measured by **operational reasoning quality**, not tickets completed
- Every incident follows: `Symptom → Layer → Hypothesis → Verification → Evidence → Conclusion`
- Advancement only occurs after 5 consecutive correct diagnoses

---

## Skills Demonstrated

| Skill | Evidence Location |
|---|---|
| Linux / Bash | `notes/`, `infra/scripts/` |
| Nginx | `notes/ticket-002-*`, `infra/scripts/` |
| Troubleshooting methodology | All `notes/` files |
| Infrastructure scripting | `infra/scripts/*.sh` |
| Architecture documentation | `docs/adr/` |

---

## Current Status

**Phase:** Linux Phase 1 — Completed  
**Active Ticket:** #003 (mid-execution)  
**Maturity Level:** 2 → targeting Level 3  
**Consecutive correct diagnoses:** Active counter  

---

*Author: Jose | Started: June 2026 | Target role: DevOps Jr / Cloud Engineer Jr*
