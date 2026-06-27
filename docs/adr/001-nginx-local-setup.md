# ADR-001: Nginx as Local Web Server for Phase 1

**Date:** June 2026  
**Status:** Accepted  
**Decided by:** Jose (with Sebastián as tech lead)

---

## Context

Phase 1 requires a web server running locally on Ubuntu to simulate production infrastructure. The goal is to learn service management, configuration, and troubleshooting before moving to cloud.

## Decision

Use **Nginx** as the web server for Phase 1 local development.

## Reasons

1. Nginx is the most common web server in DevOps job postings
2. It runs as a systemd service — teaches service management patterns that apply to all services
3. Configuration is clean and readable — good for learning nginx -t, reload vs restart
4. Same tool will be used in Phase 2 (EC2) and Phase 3 (Docker) — learning investment compounds
5. journalctl integration provides real-world log reading practice

## Alternatives Considered

- **Apache**: More complex configuration, less common in modern DevOps roles
- **Python HTTP server**: Too simple, doesn't teach service management patterns

## Consequences

- All Phase 1 tickets use Nginx as the service under test
- Scripts in `infra/scripts/` assume Nginx is installed and managed by systemd
- Local domain `hostel-sol.local` configured in `/etc/hosts` → `127.0.0.1`

---

*Reference: `docs/01-linux.md` for operational knowledge derived from this decision*
