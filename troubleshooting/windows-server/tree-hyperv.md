# Tree – Hyper-V (VM ne démarre pas / réseau VM KO)

## Symptômes
- VM stuck starting
- VM boot failure
- Pas de réseau dans la VM

## Diagramme

```mermaid
flowchart TD
A[Hyper-V issue] --> B{VM demarre ?}
B -->|Non| C[Event Viewer Hyper-V-VMMS Admin] --> D{Stockage OK ?}
D -->|Non| D1[verifier chemins VHDX, permissions, espace disque] --> Z
D -->|Oui| E{Config VM OK ?}
E -->|Non| E1[RAM CPU secure boot Gen1 vs Gen2] --> Z
E -->|Oui| Z

B -->|Oui| F{Reseau VM OK ?}
F -->|Non| G{vSwitch correct ?}
G -->|Non| G1[attacher bon vSwitch External Internal] --> Z
G -->|Oui| H{DHCP IP ok dans VM ?}
H -->|Non| H1[verifier DHCP, VLAN, firewall] --> Z
H -->|Oui| Z
F -->|Oui| Z[OK]
```

## Runbook
- Vérifier vSwitch (External/Internal/Private) et association NIC
- Vérifier VLAN ID si utilisé
- Logs : Hyper-V-VMMS, Hyper-V-Worker
