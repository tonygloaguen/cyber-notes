# Tree – GPO ne s'applique pas / lente / erreurs SYSVOL

## Symptômes
- Paramètres non appliqués (poste/serveur)
- `gpupdate /force` renvoie erreurs
- Scripts logon absents
- Lenteurs de login liées GPO

## Diagramme

```mermaid
flowchart TD
A[GPO KO] --> B{Machine join domain + DNS OK ?}
B -->|Non| B1[Corriger AD DNS voir tree-ad-logon] --> Z
B -->|Oui| C{Acces SYSVOL OK ?}
C -->|Non| C1[domain SYSVOL Test-NetConnection 445] --> C2[SMB Firewall permissions] --> Z
C -->|Oui| D{Replication SYSVOL OK ?}
D -->|Non| D1[dfsrdiag, Event DFSR] --> D2[corriger replication] --> Z
D -->|Oui| E{GPO linked filtering correct ?}
E -->|Non| E1[GPMC + security filtering + WMI filter] --> E2[corriger scope] --> Z
E -->|Oui| F{Client-side extension erreur ?}
F -->|Oui| F1[Event Viewer GroupPolicy Operational] --> F2[corriger extension ex registry, drive maps] --> Z
F -->|Non| Z[OK]
```

## Runbook

### Côté client
```powershell
gpupdate /force
gpresult /h C:\Temp\gpresult.html
Get-WinEvent -LogName "Microsoft-Windows-GroupPolicy/Operational" -MaxEvents 50
```

### SYSVOL
```powershell
dir \\domaine.local\SYSVOL
Test-NetConnection DC01 -Port 445
```

### Côté DC (replication / DFSR)
```powershell
dcdiag /v
repadmin /replsummary
# selon version/config DFSR:
dfsrdiag ReplicationState
```
