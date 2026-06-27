# Ticket #003-Ejemplo — Service Active but Connection Refused (DNS + HTTP Flow)

**Date:** June 2026  
**Reporter:** Sebastián (Tech Lead)  
**Type:** Guided Example  
**Mental Model Trained:** Client → DNS → IP → Route → Port → Service  
**Difficulty Level:** 2 (two layers: Network + Services)  
**Status:** IN PROGRESS — mid-execution

---

## Symptom / Scenario

"Nginx shows `active (running)`. Users report `connection refused`. The domain `hostel-sol.local` is configured."

## Concepts Covered Before Execution

### DNS Resolution Flow
```
User types: http://hostel-sol.local
      ↓
Browser checks /etc/hosts first
      ↓
If not found → asks DNS server (ISP or configured DNS)
      ↓
DNS returns IP address
      ↓
Browser opens TCP connection to IP:80
      ↓
Nginx receives request → serves response
```

### Tools introduced in this ticket
```bash
nslookup hostel-sol.local     # Does DNS resolve this name?
dig hostel-sol.local          # More detailed DNS query
traceroute hostel-sol.local   # Does the packet reach the host?
curl -v http://hostel-sol.local  # Full HTTP request with verbose output
```

### /etc/hosts — the local DNS override
```bash
cat /etc/hosts
# 127.0.0.1    localhost
# 127.0.0.1    hostel-sol.local   ← our entry
```
`/etc/hosts` is checked BEFORE any DNS server. For local development, this is how we map a domain to localhost without a real DNS server.

---

## Layer Identified (Before any command)

**Primary:** Layer 3 — Network  
**Secondary:** Layer 4 — Services  

**Reasoning:** "active (running)" + "connection refused" = the same contradiction pattern as Ticket #002-B. This is a Layer 3/4 boundary problem. The service is up but something is blocking or misconfiguring the network path.

## Hypotheses

| Hypothesis | Description | Probability |
|---|---|---|
| A | Firewall (ufw) blocking port 80 | 50% |
| B | Another process occupying port 80 | 40% |
| C | Nginx bound only to 127.0.0.1 (not 0.0.0.0) | 10% |

**Senior reasoning on command selection:**  
`ss -tulnp` was chosen as the FIRST command because it answers:
- Is anything listening on port 80? (A and B)
- What process is it? (B)
- What address is it bound to? (C)

This is why `ss -tulnp` over three separate commands — it gives maximum information at minimum cost.

---

## STATUS: MID-EXECUTION

**Next step:** Execute `ss -tulnp` and interpret the output.

**What I expect to find:**
- If output shows nothing on port 80 → firewall hypothesis (A) becomes primary
- If output shows another process → process conflict (B) confirmed
- If output shows nginx on 127.0.0.1:80 → binding hypothesis (C) confirmed
- If output shows nginx on 0.0.0.0:80 → problem is above Layer 3 (DNS or /etc/hosts)

---

## TO COMPLETE ON NEXT SESSION

- [ ] Execute `ss -tulnp`
- [ ] Interpret output
- [ ] Confirm/discard hypotheses
- [ ] Execute fix based on evidence
- [ ] Verify with `curl -v http://hostel-sol.local`
- [ ] Write conclusion
- [ ] Write post-mortem
- [ ] Score ticket

---

## Vocabulary — Bilingual Reference

| English | Español |
|---|---|
| DNS resolution | Resolución DNS |
| Port binding | Enlace de puerto / binding |
| Loopback address | Dirección de loopback |
| Connection refused | Conexión rechazada |
| Network interface | Interfaz de red |
| Firewall rule | Regla de firewall |
| Packet routing | Enrutamiento de paquetes |
| TCP handshake | Handshake TCP |
