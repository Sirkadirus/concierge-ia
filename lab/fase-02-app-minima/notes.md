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




# Ticket LAB-004 — Fase 4: Servicio systemd

## Qué se construyó
- Unidad systemd en /etc/systemd/system/concierge-lab.service, gestionando la app como servicio del sistema operativo en lugar de proceso manual atado a una terminal.

## Contenido de la unidad
[Unit]
Description=Aplicación Web Python
After=network.target
[Service]
User=j
WorkingDirectory=/home/j/concierge-ia/lab/fase-02-app-minima
ExecStart=/home/j/concierge-ia/lab/fase-02-app-minima/venv/bin/uvicorn main:app --port 8000
[Install]
WantedBy=multi-user.target

## Decisiones y por qué
- Rutas absolutas obligatorias: systemd no expande `~` ni ejecuta `source activate`, a diferencia de una shell interactiva. Se apunta directo al binario `uvicorn` dentro del venv.
- `User=j`: se mantiene el usuario de desarrollo (no root, no usuario dedicado), decisión consciente para entorno local. Un usuario de servicio dedicado se evaluará en fases de producción real (Fase 10 - AWS).
- `After=network.target`: la app depende de que la red esté disponible antes de intentar bindear el puerto.

## Incidente encontrado durante el ticket
- Al intentar arrancar el servicio, el puerto 8000 ya estaba ocupado por un proceso Uvicorn manual de un ticket anterior (PID 700733).
- Diagnóstico: verificado con `ss -tlnp | grep :8000` antes de asumir la causa.
- Resolución: `kill 700733` (SIGTERM, cierre ordenado) antes de reintentar el arranque del servicio.
- Aprendizaje: no deben convivir la ejecución manual y la gestionada por systemd de la misma app sobre el mismo puerto.

## Verificación de estado sano
- `systemctl status concierge-lab.service` → active (running), Main PID 703420.
- `curl http://localhost:8000/` → {"message":"Aplicación funcionando"} (200 OK, confirmado también en journalctl).
- `journalctl -u concierge-lab` → logs persistentes sin necesidad de terminal interactiva abierta, resolviendo el problema de pérdida de logs identificado en LAB-003.

## Arranque automático
- Se ejecutó `systemctl enable concierge-lab.service` de forma consciente: con esto el servicio arranca automáticamente en cada boot del sistema (symlink creado en multi-user.target.wants/). Sin enable, el servicio existe pero requiere start manual tras cada reinicio.

## Comandos de operación del servicio
```bash
sudo systemctl start concierge-lab
sudo systemctl stop concierge-lab
sudo systemctl restart concierge-lab
sudo systemctl status concierge-lab
journalctl -u concierge-lab -n 50 --no-pager
```

## Commit
feat: convert app into systemd-managed service (Phase 4)
