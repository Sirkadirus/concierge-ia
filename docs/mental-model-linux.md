# Mental Model — Linux Incident Diagnosis
# Modelo Mental — Diagnóstico de Incidentes Linux

## The 5 Core Components / Los 5 Componentes Núcleo

System (Sistema)
├── Files    (Archivos)  → ¿Existe? ¿Permisos? ¿Ubicación?
├── Processes (Procesos) → ¿Está vivo? ¿PID? ¿Estado?
├── Users    (Usuarios)  → ¿Quién lo ejecuta? ¿Grupos?
├── Services (Servicios) → ¿Activo? ¿Habilitado? ¿Deps?
└── Resources (Recursos) → ¿CPU? ¿RAM? ¿Disco? ¿Red?

## The 10 Meta-Skills / Las 10 Meta-Habilidades

#1  Layer model         → diagnose top-down, fix bottom-up
#2  MTTD vs MTTR        → detect fast, fix fast
#3  4 Golden Signals    → latency, traffic, errors, saturation
#4  Priority matrix     → P1 critical → P4 minor
#5  Last change rule    → 85% of incidents caused by recent change
#6  Incident comms      → commander, comms lead, resolver
#7  Blameless post-mortem → systems failed, not people
#8  Chaos engineering   → break things on purpose to learn
#9  Tunnel effect       → if stuck 20min, change layer
#10 Master flow         → recognize→measure→prioritize→locate
                          →ask→eliminate→fix→communicate→learn

## Atomic Symptoms Quick Reference
## Referencia Rápida de Síntomas Atómicos

### Files (Archivos)
A1  ENOENT  (2)   → "No such file or directory"
A2  EACCES  (13)  → "Permission denied" (open/unlink)
A3  EROFS   (30)  → "Read-only file system"
A4  ENOSPC  (28)  → "No space left on device" (blocks)
A6  ENOSPC  (28)  → "No space left" (inodes) → df -i
A12 EACCES  (13)  → "Permission denied" (script sin +x)

### Processes (Procesos)
P3  state D       → process unkillable (waiting IO)
P4  state Z       → zombie (parent not calling wait())

### Services (Servicios)
S1  exit-code=1   → service failed to start
S4  inactive dead → Restart=no, process died
S5  dependency    → required service failed first

### Resources (Recursos)
R1  OOM Killer    → process killed → check dmesg
R5  EADDRINUSE    → port already in use → ss -tlnp

### Network (Redes)
N4  EADDRINUSE    → port conflict on bind()
N7  ECONNREFUSED  → nothing listening on that port
N8  ETIMEDOUT     → packet dropped (firewall/unreachable)
