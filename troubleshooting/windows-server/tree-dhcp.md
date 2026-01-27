# Tree – DHCP Windows Server (pas de bail / mauvaise IP / options manquantes)

## Symptômes
- Clients en APIPA (169.254.x.x)
- Pas de bail, ou baux incohérents
- Mauvaises options (DNS, gateway)
- VLAN : DHCP ne traverse pas

## Diagramme

```mermaid
flowchart TD
A[DHCP KO] --> B{Client en APIPA ?}
B -->|Oui| C[ipconfig all ipconfig renew] --> D{DHCP reachable ?}
D -->|Non| D1[Test-NetConnection DHCP 67 68, reseau VLAN] --> D2[verifier relay IP helper, firewall] --> Z
D -->|Oui| E{Scope OK actif, plage, exclusions ?}
E -->|Non| E1[activer scope, ajuster plage exclusions] --> Z
E -->|Oui| F{Options scope correctes ?}
F -->|Non| F1[option 003 router, 006 DNS, 015 suffix] --> Z
F -->|Oui| G{DHCP autorise AD ?}
G -->|Non| G1[autoriser DHCP dans AD] --> Z
G -->|Oui| Z[OK]
B -->|Non| H{IP obtenue mais mauvaise ?}
H -->|Oui| F
H -->|Non| Z
```

## Runbook (principaux checks)

### Client
```powershell
ipconfig /all
ipconfig /release
ipconfig /renew
```

### Serveur DHCP
```powershell
Get-Service dhcpserver
Get-DhcpServerv4Scope
Get-DhcpServerv4OptionValue
Get-DhcpServerv4Lease -ScopeId <x.x.x.x>
```

### VLAN / Relay
- Sur équipement réseau : vérifier IP helper / DHCP relay vers le serveur
- Vérifier que le firewall autorise UDP 67/68 (selon design)
