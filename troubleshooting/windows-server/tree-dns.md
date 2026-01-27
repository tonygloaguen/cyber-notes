# Tree – DNS Windows Server (résolution KO / lente / NXDOMAIN)

## Diagramme

```mermaid
flowchart TD
A[DNS KO lent] --> B{Depuis client ou serveur DNS ?}
B -->|Client| C[Client config + test]
B -->|Serveur| D[Serveur zone + forwarders + logs]

C --> C1{DNS client serveur DNS interne ?}
C1 -->|Non| C1a[Fixer DNS primaire DNS interne] --> C2
C1 -->|Oui| C2{Nom interne AD OK ?}
C2 -->|Non| C2a[nslookup domaine + SRV] --> C2b[reparer zone AD + SRV] --> Z
C2 -->|Oui| C3{Nom externe OK ?}
C3 -->|Non| C3a[nslookup google com] --> C3b{Forwarders OK ?}
C3b -->|Non| D2 --> Z
C3b -->|Oui| C3c[Firewall ISP MTU?] --> Z
C3 -->|Oui| Z[OK]

D --> D1{Service DNS up ?}
D1 -->|Non| D1a[Restart service DNS] --> Z
D1 -->|Oui| D2{Forwarders root hints OK ?}
D2 -->|Non| D2a[Configurer forwarders selon politique] --> Z
D2 -->|Oui| D3{Zone interne OK ?}
D3 -->|Non| D3a[verifier zone AD integree, replication, enregistrements] --> Z
D3 -->|Oui| D4{Cache recursion policies ?}
D4 -->|Oui| D4a[Ajuster vider cache si besoin] --> Z
D4 -->|Non| Z
```

## Runbook

### Tests rapides (client)
```powershell
Get-DnsClientServerAddress
nslookup domaine.local
nslookup -type=SRV _ldap._tcp.dc._msdcs.domaine.local
nslookup google.com
```

### Tests rapides (serveur DNS)
```powershell
Get-Service DNS
Get-DnsServerForwarder
Get-DnsServerRecursion
Get-DnsServerZone
Get-DnsServerResourceRecord -ZoneName "domaine.local" -RRType SRV
```

### Actions correctives communes
🔧 Ajouter/valider forwarders
🔧 Vérifier la zone AD intégrée et sa réplication
🔧 Si SRV manquants : redémarrer Netlogon sur DC + registerdns
