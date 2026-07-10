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


## Fecha de validación
2026-07-10

## Entorno
- SO: Linux (Ubuntu)
- Usuario: j (sin privilegios elevados)
- Puerto: 127.0.0.1:8000 (loopback, solo acceso local)
- Comando de inicio: uvicorn main:app --port 8000

## Checklist de validación formal

| Validación | Estado | Evidencia / Comando |
|------------|--------|---------------------|
| La aplicación inicia correctamente | ✅ | Log: `Application startup complete` |
| El proceso permanece activo | ✅ | `ps aux \| grep uvicorn` → PID 3004160 confirmado |
| El puerto está en escucha | ✅ | `ss -tulnp \| grep 8000` → LISTEN en 127.0.0.1:8000, proceso uvicorn |
| curl recibe respuesta HTTP correcta | ✅ | `curl -v http://127.0.0.1:8000/` → HTTP 200 OK, `{"message":"Aplicación funcionando"}` |
| El endpoint /health responde correctamente | ✅ | `curl http://127.0.0.1:8000/health` → `{"status":"healthy"}` |
| Los logs no contienen errores | ✅ | Salida del servidor: solo líneas INFO, sin ERROR/WARNING/Traceback |
| La configuración se carga correctamente | ⬜ | N/A - sin configuración externa (hardcodeado) |
| El usuario tiene permisos adecuados | ✅ | `ps aux` muestra usuario `j` (puerto >1024, sin necesidad de root) 


