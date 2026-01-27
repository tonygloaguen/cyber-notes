# Tree – Performance Linux (CPU / RAM / IO)

## Symptômes
- load average élevé
- latence applicative
- OOM / swap
- IO wait

## Diagramme

```mermaid
flowchart TD
A[Perf issue] --> B{CPU sature ?}
B -->|Oui| C[top htop, pidstat] --> C1[reduire charge limiter optimiser] --> Z
B -->|Non| D{RAM OOM ?}
D -->|Oui| E[free -h, dmesg puis grep -i oom] --> E1[corriger fuite augmenter RAM tuning] --> Z
D -->|Non| F{IO wait ?}
F -->|Oui| G[iostat, iotop] --> G1[disque, fs, app, logs, rotation] --> Z
F -->|Non| H{Reseau ?}
H -->|Oui| I[ss, iperf, mtr] --> I1[MTU, congestion, firewall] --> Z
H -->|Non| Z[OK]
```

## Runbook (commandes)
```bash
uptime
top
vmstat 1 5
free -h
dmesg -T | grep -i oom || true
pidstat -u 1 5 || true
iostat -xz 1 5 || true
iotop -oPa || true
ss -s
```
