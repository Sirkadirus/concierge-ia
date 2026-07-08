# Ticket LAB-002 — Fase 2: App Mínima con FastAPI

## Qué se construyó
- Entorno virtual aislado en `fase-02-app-minima/venv/` (excluido por `.gitignore`, patrón `venv/` recursivo confirmado con `git add -n`).
- Dependencias instaladas: fastapi==0.139.0, uvicorn==0.50.2 (+ transitivas), congeladas en `requirements.txt`.
- `main.py` con dos endpoints:
  - `GET /` → `{"message": "Aplicación funcionando"}`
  - `GET /health` → `{"status": "healthy"}`

## Verificación de estado sano
- Uvicorn corriendo en `http://127.0.0.1:8000`, logs confirman `200 OK` en ambas rutas.
- Verificado con `curl` desde una segunda terminal (evidencia de cliente, no solo del servidor).

## Incidente menor durante el ticket
- Salida de `curl` inicialmente confusa por error de tipeo en terminal, no por fallo de la app. Se resolvió re-ejecutando el comando y confirmando con evidencia nueva antes de concluir.

## Comando para levantar el servidor
```bash
cd ~/concierge-ia/lab/fase-02-app-minima
source venv/bin/activate
uvicorn main:app --reload --port 8000
```

## Commit
`feat: add minimal FastAPI application with Uvicorn ASGI server` (a254b2c)
