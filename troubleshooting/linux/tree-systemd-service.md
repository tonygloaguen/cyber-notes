# Tree – systemd service failed

```mermaid
flowchart TD
A[Service down] --> B[systemctl status svc]
B --> C{Exit code reason clair ?}
C -->|Oui| D[corriger config app env] --> Z
C -->|Non| E[journalctl -u svc -b]
E --> F{Dependances ?}
F -->|Oui| F1[systemctl list-dependencies] --> F2[start deps] --> Z
F -->|Non| G{Port deja utilise ?}
G -->|Oui| G1[ss -lntp] --> G2[changer port stop autre service] --> Z
G -->|Non| H{Permissions SELinux AppArmor ?}
H -->|Oui| H1[ausearch aa-status] --> H2[policy permissions] --> Z
H -->|Non| Z[OK]
```

## Runbook
```bash
sudo systemctl status <svc> --no-pager
sudo journalctl -u <svc> -b -n 300 --no-pager
sudo systemctl cat <svc>
sudo systemctl show <svc> -p ExecStart -p Environment -p User -p Group
sudo ss -lntp
```
