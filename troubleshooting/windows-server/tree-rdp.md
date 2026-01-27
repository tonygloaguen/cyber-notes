# Tree – RDP impossible (Windows Server)

## Diagramme

```mermaid
flowchart TD
A[RDP KO] --> B{Ping ICMP OK ?}
B -->|Non| B1[Tester reseau, route, firewall] --> Z
B -->|Oui| C{Port 3389 ouvert ?}
C -->|Non| C1[Test-NetConnection -Port 3389] --> C2[Firewall NAT Security Group] --> Z
C -->|Oui| D{Service RDP actif ?}
D -->|Non| D1[Activer Remote Desktop TermService] --> Z
D -->|Oui| E{NLA creds ?}
E -->|Oui| E1[Essayer autre compte verifier groupes] --> Z
E -->|Non| F{Session bloquee max sessions ?}
F -->|Oui| F1[logoff sessions via console] --> Z
F -->|Non| G{Certificat TLS ?}
G -->|Oui| G1[reinitialiser cert RDP verifier Schannel] --> Z
G -->|Non| Z[OK]
```

## Runbook
```powershell
Test-NetConnection SERVER -Port 3389
Get-Service TermService
netsh advfirewall firewall show rule name=all | Select-String -Pattern "Remote Desktop"
```

✅ Droits
- membre de **Remote Desktop Users** ou Administrateurs
- GPO : “Allow log on through Remote Desktop Services”

🧾 Logs
- Event Viewer → Microsoft-Windows-TerminalServices-LocalSessionManager/Operational
- Security (échecs login)
