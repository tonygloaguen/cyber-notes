# Tree – Storage Windows (disque plein / accès SMB / permissions)

## Diagramme

```mermaid
flowchart TD
A[Storage issue] --> B{Disque plein ?}
B -->|Oui| C[Get-Volume Explorer] --> C1[purge logs temp deplacer donnees] --> Z
B -->|Non| D{Acces SMB KO ?}
D -->|Oui| E[Test-NetConnection 445 Get-SmbShare] --> E1[firewall permissions share+NTFS] --> Z
D -->|Non| Z[OK]
```

## Commandes
```powershell
Get-Volume
Get-PSDrive -PSProvider FileSystem
Get-SmbShare
Get-SmbSession
Test-NetConnection <server> -Port 445
```

## Points clés
- Toujours vérifier **Share permissions** ET **NTFS permissions**
- SMB bloqué par firewall = symptôme fréquent
