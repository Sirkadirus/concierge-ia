# Ticket LAB-001 — Fase 1: Preparar el Entorno Linux Local

## Entorno confirmado
- Python: 3.12.3
- Fecha: 2026-07-06

## Qué se hizo
- Verificado estado limpio del repo (`git status`) antes de crear estructura nueva.
- Creada estructura `lab/fase-01-entorno/`.
- Confirmado runtime Python 3.12.3 como base del laboratorio, alineado con el roadmap real (FastAPI/RAG).

## Decisión (ADR informal)
Se eligió Python como runtime único del laboratorio porque converge directamente con el stack de producción de Concierge IA (FastAPI, RAG, pgvector, Claude API). Ningún código de este laboratorio es descartable.

## Commit
`feat: initialize lab/ structure for DevOps Junior Laboratory (Phase 1)` (6fe4e67)
